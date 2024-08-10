//
//  NewViewController.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/30.
//

import UIKit
import MapKit
import CoreLocation
import Combine

protocol MapKitDemoBusinessLogic {
    func directionButtonTapped()

    func searchBarTextChanged(to searchText: String)
    func tapOnSuggestionsItem(at index: Int)
    func saveSelectedMapItem()
    func openSelectedMapItemInMaps()
}

final class MapKitDemoViewController: UIViewController {

    private var loadingView: UIActivityIndicatorView!

    private var searchBar: UISearchBar!
    private var mapView: MKMapView!

    private var directionButton: UIButton!

    private var tableView: UITableView!
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private var tableViewCellHeight: CGFloat = 44

    private lazy var dataSource: UITableViewDiffableDataSource<Int, MKMapItem> = {
        UITableViewDiffableDataSource<Int, MKMapItem>(tableView: self.tableView) { tableView, indexPath, item in
            let cell = tableView.getCell(with: SuggestedSearchTermCell.self, for: indexPath)
            cell.configure(with: item.name ?? "")
            return cell
        }
    }()
    private lazy var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Int, MKMapItem> = {
        dataSource.snapshot()
    }()

    private let lookAroundViewController = MKLookAroundViewController()

    private let interactor: MapKitDemoBusinessLogic
    private let stateStore: MapKitDemoStateStore

    private var cancellables: Set<AnyCancellable> = []

    init() {
        let stateStore = MapKitDemoStateStore()
        let interactor = MapKitDemoInteractor(stateStore: stateStore)

        self.interactor = interactor
        self.stateStore = stateStore
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)

        setupMapView()
        setupSearchBar()
        setupTableView()
        setupLoadingView()
        setupLookAroundViewController()
        setupDirectionButton()

        setupObserver()

        mapView.setRegion(.japan, animated: false)
        searchBar.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.searchTextField.layer.cornerRadius = searchBar.searchTextField.frame.height / 2
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Private functions
extension MapKitDemoViewController {

    private func setupObserver() {
        stateStore.$suggestedMapItems
            .removeDuplicates()
            .sink { [weak self] items in
                guard let self else { return }
                tableViewHeightConstraint.constant = CGFloat(items.count) * tableViewCellHeight

                UIView.animate(withDuration: 0.25) {
                    self.tableView.layoutIfNeeded()
                } completion: { [weak self] _ in
                    guard let self else { return }

                    dataSourceSnapshot.deleteAllItems()
                    dataSourceSnapshot.appendSections([0])
                    dataSourceSnapshot.appendItems(items)
                    dataSource.apply(dataSourceSnapshot, animatingDifferences: false)
                }
            }.store(in: &cancellables)

        stateStore.$annotations
            .withPrevious()
            .sink { [weak self] previous, current in
                guard let self else { return }

                if let previous {
                    mapView.removeAnnotations(previous)
                }
                mapView.addAnnotations(current)
            }.store(in: &cancellables)

        stateStore.$currentCamera
            .compactMap { $0 }
            .sink { [weak self] camera in
                self?.mapView.setCamera(camera, animated: true)
            }.store(in: &cancellables)

        stateStore.$currentRegion
            .sink { [weak self] region in
                self?.mapView.setRegion(region, animated: true)
            }.store(in: &cancellables)

        stateStore.$currentMode
            .removeDuplicates()
            .sink { [weak self] mode in
                guard let self else { return }

                switch mode {
                case .search:
                    directionButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    searchBar.isHidden = false
                    mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
                case .direction:
                    directionButton.setImage(UIImage(systemName: "tram.fill"), for: .normal)
                    searchBar.isHidden = true
                    tableView.isHidden = true
                    mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .muted)
                }
            }.store(in: &cancellables)

        stateStore.$isLoading
            .sink { [weak self] isLoading in
                guard let self else { return }
                    if isLoading {
                        showLoading()
                    } else {
                        hideLoading()
                    }
            }.store(in: &cancellables)

        stateStore.$currentLookAroundScene
            .removeDuplicates()
            .sink { [weak self] scene in
                guard let self else { return }
                lookAroundViewController.scene = scene
                lookAroundViewController.view.isHidden = scene == nil
            }.store(in: &cancellables)

        stateStore.$currentRoute
            .withPrevious()
            .sink { [weak self] previous, current in
                guard let self else { return }

                if let previous, let previous {
                    mapView.removeOverlay(previous.polyline)
                }

                if let current {
                    mapView.addOverlay(current.polyline, level: .aboveRoads)
                    mapView.setVisibleMapRect(current.polyline.boundingMapRect.insetBy(dx: 50, dy: 50), animated: true)
                }
            }.store(in: &cancellables)

        stateStore.$currentSearchText
            .sink { [weak self] searchText in
                self?.searchBar.text = searchText
            }.store(in: &cancellables)

        stateStore.$isSearchBarActive
            .sink { [weak self] isActive in
                guard let self else { return }

                if isActive {
                    searchBar.becomeFirstResponder()
                } else {
                    searchBar.resignFirstResponder()
                }
            }.store(in: &cancellables)
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
            .add(to: view)
            .anchor(\.topAnchor, to: view.safeAreaLayoutGuide.topAnchor)
            .anchor(\.leadingAnchor, to: view.safeAreaLayoutGuide.leadingAnchor)
            .anchor(\.trailingAnchor, to: view.safeAreaLayoutGuide.trailingAnchor)
            .anchor(\.heightAnchor, to: 56)

        searchBar
            .set(\.backgroundImage, with: UIImage())
            .set(\.delegate, with: self)

        searchBar.searchTextField
            .set(\.backgroundColor, with: UIColor.systemGray6.withAlphaComponent(0.9))
            .set(\.attributedPlaceholder, with: NSAttributedString(
                string: "Write wherever you want to go",
                attributes: [.foregroundColor: UIColor.systemGray]
            ))
    }

    private func setupTableView() {
        tableView = UITableView()
            .add(to: view)
            .anchor(\.topAnchor, to: searchBar.bottomAnchor)
            .anchor(\.leadingAnchor, to: view.layoutMarginsGuide.leadingAnchor)
            .anchor(\.trailingAnchor, to: view.layoutMarginsGuide.trailingAnchor)
            .anchor(\.bottomAnchor, .lessThanOrEqual, to: view.safeAreaLayoutGuide.bottomAnchor)

        tableViewHeightConstraint = tableView.constraint(
            \.heightAnchor, to: 0,
             priority: .defaultHigh
        )

        tableView
            .set(\.backgroundColor, with: .clear)
            .set(\.separatorStyle, with: .none)
            .set(\.rowHeight, with: tableViewCellHeight)
            .set(\.estimatedRowHeight, with: tableViewCellHeight)
            .set(\.showsVerticalScrollIndicator, with: true)
            .set(\.showsHorizontalScrollIndicator, with: false)
            .set(\.delegate, with: self)
            .register(cellType: SuggestedSearchTermCell.self)

        tableView.dataSource = dataSource
    }

    private func setupMapView() {
        mapView = MKMapView()
            .add(to: view)
            .anchor(\.topAnchor, to: view.topAnchor)
            .anchor(\.leadingAnchor, to: view.leadingAnchor)
            .anchor(\.trailingAnchor, to: view.trailingAnchor)
            .anchor(\.bottomAnchor, to: view.bottomAnchor)
        mapView
            .set(\.showsUserLocation, with: false)
            .set(\.delegate, with: self)
        //            .set(\.preferredConfiguration, with: MKStandardMapConfiguration(elevationStyle: .realistic))
            .set(\.preferredConfiguration, with: MKHybridMapConfiguration(elevationStyle: .realistic))

        mapView.setRegion(.japan, animated: true)
    }

    private func setupLoadingView() {
        loadingView = UIActivityIndicatorView(style: .large)
            .add(to: view)
            .anchor(\.centerXAnchor, to: view.centerXAnchor)
            .anchor(\.centerYAnchor, to: view.centerYAnchor)
            .set(\.hidesWhenStopped, with: true)
    }

    private func setupLookAroundViewController() {
        lookAroundViewController.view
            .add(to: view)
            .anchor(\.topAnchor, to: view.topAnchor, priority: .defaultHigh)
            .anchor(\.bottomAnchor, to: view.bottomAnchor)
            .anchor(\.leadingAnchor, to: view.leadingAnchor)
            .anchor(\.trailingAnchor, to: view.trailingAnchor, priority: .defaultHigh)

        lookAroundViewController.view.constraint(\.heightAnchor, .equal, to: 150)
        lookAroundViewController.view.constraint(\.widthAnchor, .equal, to: 150)

        addChild(lookAroundViewController)
        lookAroundViewController.didMove(toParent: self)

        lookAroundViewController.view.isHidden = true

        //        lookAroundViewController.isNavigationEnabled = false
        //        lookAroundViewController.delegate = self
    }

    private func setupDirectionButton() {
        directionButton = UIButton()
            .add(to: view)
            .anchor(\.bottomAnchor, to: view.safeAreaLayoutGuide.bottomAnchor)
            .anchor(\.trailingAnchor, to: view.safeAreaLayoutGuide.trailingAnchor)
            .anchor(\.widthAnchor, to: 56)
            .anchor(\.heightAnchor, to: 56)
        directionButton
            .set(\.layer.cornerRadius, with: 28)
            .set(\.backgroundColor, with: UIColor.white.withAlphaComponent(0.9))
            .set(\.tintColor, with: .darkGray)
        directionButton.setImage(UIImage(systemName: "tram.fill"), for: .normal)
        directionButton.addTarget(self, action: #selector(directionButtonTapped), for: .touchUpInside)
    }

    @objc
    private func directionButtonTapped() {
        interactor.directionButtonTapped()
    }

    private func showLoading() {
        UIView.animate(withDuration: 0.25) {
            self.loadingView.startAnimating()
            self.loadingView.alpha = 1
        }
    }

    private func hideLoading() {
        UIView.animate(withDuration: 0.25) {
            self.loadingView.stopAnimating()
            self.loadingView.alpha = 0
        }
    }
}


// MARK: - UISearchBarDelegate
extension MapKitDemoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor.searchBarTextChanged(to: searchText)
    }
}

// MARK: - UITableViewDelegate
extension MapKitDemoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor.tapOnSuggestionsItem(at: indexPath.item)
    }
}

// MARK: - MKMapViewDelegate
extension MapKitDemoViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView()
        view.markerTintColor = .orange
        view.glyphText = "⚑"
        view.glyphTintColor = .white
        view.canShowCallout = true
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view.leftCalloutAccessoryView = UIButton(type: .contactAdd)

        if let annotation = annotation as? MKMapFeatureAnnotation,
           let style = annotation.iconStyle {
            view.glyphText = nil
            view.glyphImage = style.image
        }

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control === view.leftCalloutAccessoryView {
            interactor.saveSelectedMapItem()
        } else if control === view.rightCalloutAccessoryView {
            interactor.openSelectedMapItemInMaps()
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlay = overlay as? MKPolyline else {
            fatalError("Unexpected overlay \(overlay) added to the map view")
        }

        let renderer = MKPolylineRenderer(polyline: overlay)
        renderer.strokeColor = .purple
        renderer.lineWidth = 6

        return renderer
    }
}
