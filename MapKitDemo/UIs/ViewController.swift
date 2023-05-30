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

    private lazy var dataSource: UITableViewDiffableDataSource<Int, MKMapItem>
    private lazy var dataSourceSnapshot: NSDiffableDataSourceSnapshot<Int, MKMapItem>

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

    private let lookAroundViewController = MKLookAroundViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - Private functions
extension ViewController {

    private func setupSearchBar() {
    }

    private func setupTableView() {
    }

    private func setupMapView() {
    }

    private func setupLookAroundViewController() {
    }

    private func setupDirectionButton() {
    }
}
