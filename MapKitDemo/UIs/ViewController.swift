//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import UIKit
import MapKit
import CoreLocation

final class ViewController: UIViewController {

    enum Mode {
        case search
        case direction
    }

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

    // Please help me to implement this ViewController with the following requirement
    // - A searchBar on the top upper the mapView
    //   - show the suggestions about search term when user is typing on the searchBar
    //
    // - A Full screen MapView
    //   - show the user's current location on the map
    //   - show the search result on the map
    //   - show the route between user's current location and the search result
    //
    // - Add a labelView just under the searchBar to show the suggestion of search term
    //   - display when we get search results from the searcher
    //     - the cells should only contain a label to show the name of the search results (MKMapItem.name)
    //   - hide when the search text is empty or nil
    //   - hide when user tap on one of the search terms
    //
    // - Add a tiny LookAround view at the botton left side of the screen
    //   - show LookAroundViewController's view
    //   - expend to full screen when user tap on it
    //   - A button on the right bottom side of the LookAroundViewController's view, and the LookAroundViewController's view will back to the original size when user tap on it
    //   - The LookAroundViewController's view should be able to scroll when user scroll on it
    //   - The view will show when the selectedItem is not nil, and vice versa.
    //
    // - A UIButton on the bottom right side of the screen
    //   - when the currentMode is search, change it to direction when user tap on it
    //   - when the currentMode is direction:
    //     - currentAttractionIndex < currentItems.count - 1:
    //       - trigger function gotoNextDestination
    //     - currentAttractionIndex == currentItems.count - 1:
    //      - change the currentMode to search
    //   - when the currentMode changed:
    //     - change the button's icon to:
    //       - 🔎: when the currentMode is search
    //       - 🚈: when the currentMode is direction
    //     - searchBar.isHidden = currentMode == .direction

    private let attractionsSearcher = AttractionsSearcher()
    private let lookAroundSceneRetriever = SceneRetriever()
    private let routeService = RouteService()

    private var currentMode: Mode = .search {
        didSet {
            guard currentMode != oldValue else {
                return
            }
            switch currentMode {
            case .search:
                directionButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                searchBar.isHidden = false
                mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
            case .direction:
                directionButton.setImage(UIImage(systemName: "tram.fill"), for: .normal)
                searchBar.isHidden = true
                selectedMapItem = nil
                displayedMapItems = storedMapItems
                tableView.isHidden = true
                mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .muted)
            }
        }
    }

    private var displayedMapItems: [MKMapItem] = [] {
        didSet {
            guard displayedMapItems != oldValue else {
                return
            }
            tableViewHeightConstraint.constant = CGFloat(displayedMapItems.count) * tableViewCellHeight
            resetAnnotations(with: displayedMapItems)

            UIView.animate(withDuration: 0.25) {
                self.tableView.layoutIfNeeded()
            } completion: { [weak self] _ in
                guard let self else { return }
                
                dataSourceSnapshot.deleteAllItems()
                dataSourceSnapshot.appendSections([0])
                dataSourceSnapshot.appendItems(displayedMapItems)
                dataSource.apply(dataSourceSnapshot, animatingDifferences: false)
            }
        }
    }
    private var selectedMapItem: MKMapItem? = nil {
        didSet {
            guard selectedMapItem != oldValue else {
                return
            }
            guard let selectedMapItem else {
                currentLookAroundScene = nil
                return
            }
            print(selectedMapItem.placemark.coordinate)
            updateCurrentScene(with: selectedMapItem)
            resetAnnotations(with: [selectedMapItem])

            //            let cameraDistance: CLLocationDistance = {
            //                let region = selectedItem.placemark.region as? CLCircularRegion
            //                if let region, region.radius > 200 {
            //                    return 1000
            //                }
            //                return 700
            //            }()

            let camera = MKMapCamera(
                lookingAtCenter: selectedMapItem.placemark.coordinate,
                fromDistance: 1000,//cameraDistance,
                pitch: 60,
                heading: 0
            )
            mapView.setCamera(camera, animated: true)
        }
    }

    private let lookAroundViewController = MKLookAroundViewController()
    private var currentLookAroundScene: MKLookAroundScene? = nil {
        didSet {
            guard currentLookAroundScene != oldValue else {
                return
            }
            lookAroundViewController.scene = currentLookAroundScene
            lookAroundViewController.view.isHidden = currentLookAroundScene == nil
        }
    }

    private var currentAnnotations: [MKAnnotation] = []

    private var storedMapItems: [MKMapItem] = []
    private var currentAttractionIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)

        setupMapView()
        setupSearchBar()
        setupTableView()
        setupLookAroundViewController()
        setupDirectionButton()

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
extension ViewController {

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
        lookAroundViewController.delegate = self
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

    private func updateCurrentScene(with item: MKMapItem) {
        Task { @MainActor in
            do {
                self.currentLookAroundScene = try await lookAroundSceneRetriever.fetchScene(with: item)
            } catch {
                self.currentLookAroundScene = nil
            }
        }
    }

    private func resetAnnotations(with items: [MKMapItem]) {
        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations = items.map { item -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
                .set(\.title, with: item.name)
                .set(\.subtitle, with: item.placemark.title)
                .set(\.coordinate, with: item.placemark.coordinate)
            return annotation
        }
        mapView.addAnnotations(currentAnnotations)
    }

    private func retrieveImage(for item: MKMapItem) async -> UIImage? {
        do {
            guard let scene = try await lookAroundSceneRetriever.fetchScene(with: item) else {
                return nil
            }
            let image = try await lookAroundSceneRetriever.generateSnapshot(
                for: scene,
                with: CGSize(width: 500, height: 500)
            )
            return image
        } catch {
            print(error)
            return nil
        }
    }

    private func goToNextAttraction() async {
        let sourceIndex = currentAttractionIndex
        let destinationIndex = currentAttractionIndex + 1
        currentAttractionIndex = destinationIndex

        guard
            destinationIndex < displayedMapItems.count,
            let sourceItem = storedMapItems[safe: sourceIndex],
            let destinationItem = storedMapItems[safe: destinationIndex],
            let route = await routeService.generateRoute(
                from: sourceItem,
                to: destinationItem
            )
        else {
            return
        }

        mapView.addOverlay(route.polyline, level: .aboveRoads)
        mapView.setVisibleMapRect(route.polyline.boundingMapRect.insetBy(dx: -30, dy: -30), animated: true)
    }

    @objc
    private func directionButtonTapped() {
        switch currentMode {
        case .direction:
            if currentAttractionIndex < displayedMapItems.count - 1 {
                Task { @MainActor in
                    await goToNextAttraction()
                }
            } else {
                currentMode = .search
            }
        case .search:
            currentAttractionIndex = 0
            currentMode = .direction
            Task { @MainActor in
                await goToNextAttraction()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task { @MainActor in
            if searchText.isEmpty {
                displayedMapItems = []
                return
            }

            let (items, region) = await attractionsSearcher.search(for: searchText, in: .travelPointsOfInterest, in: .japan)
            guard !items.isEmpty, let region else { return }

            displayedMapItems = items
            mapView.setRegion(region, animated: true)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = displayedMapItems[indexPath.item]
        searchBar.text = selectedItem.name
        searchBar.resignFirstResponder()

        // clear all suggestion and hide the tableView
        displayedMapItems = []
        self.selectedMapItem = selectedItem
    }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
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

        if let selectedMapItem, annotation.title == selectedMapItem.name {
            //            let text = """
            //             \(String(describing: selectedItem.placemark.title))
            //             \(String(describing: selectedItem.placemark.subLocality))
            //             \(String(describing: selectedItem.placemark.subThoroughfare))
            //             \(String(describing: selectedItem.placemark.subAdministrativeArea))
            //             \(String(describing: selectedItem.phoneNumber))
            //             \(String(describing: selectedItem.url))
            //             \(String(describing: selectedItem.pointOfInterestCategory))
            //             \(selectedItem.placemark)
            //             """
            //            dump(text, name: "🎊")
            //            print("🫐", text)
            Task { @MainActor in
                if let scene = try? await lookAroundSceneRetriever.fetchScene(with: selectedMapItem) {
                    view.glyphImage = try? await lookAroundSceneRetriever.generateSnapshot(
                        for: scene,
                        with: CGSize(width: 50, height: 50)
                    )
                }
            }
        }
        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control === view.leftCalloutAccessoryView {
            print("🐛")
            guard let selectedMapItem else { return }
            storedMapItems.append(selectedMapItem)
            self.selectedMapItem = nil
        }
        if control === view.rightCalloutAccessoryView {
            print("🫐")
            guard let selectedMapItem else { return }
            //            Task { @MainActor in
            let launchOptions: [String : Any] = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: mapView.region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: mapView.region.span),
                //                    MKLaunchOptionsMapTypeKey: mapView.
            ]
            let result = selectedMapItem.openInMaps(launchOptions: launchOptions)
            print("✨", result)
            //            }
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

// MARK: - MKLookAroundViewControllerDelegate
extension ViewController: MKLookAroundViewControllerDelegate {

}
