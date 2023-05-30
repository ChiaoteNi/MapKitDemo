//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import UIKit
import MapKit
import CoreLocation

/*
 public extension UIView {

     // MARK: - Add to targetView
     @discardableResult
     func add(to superView: UIView) -> Self {
         superView.addSubview(self)
         return self
     }

     // MARK: - NSLayoutAnchor

     @discardableResult
     func anchorEqualToSuperView<LayoutType: NSLayoutAnchor<AnchorType>, AnchorType>(
         _ keyPath: KeyPath<UIView, LayoutType>,
         constant: CGFloat = 0,
         multiplier: CGFloat? = nil,
         priority: UILayoutPriority = .required
     ) -> Self {
         if let superview {
             return anchor(
                 keyPath, .equal, to: superview[keyPath: keyPath],
                 constant: constant,
                 multiplier: multiplier,
                 priority: priority
             )
         }
         return self
     }

     @discardableResult
     func anchor<LayoutType: NSLayoutAnchor<AnchorType>, AnchorType>(
         _ keyPath: KeyPath<UIView, LayoutType>,
         _ relation: NSLayoutConstraint.Relation = .equal,
         to anchor: LayoutType,
         constant: CGFloat = 0,
         multiplier: CGFloat? = nil,
         priority: UILayoutPriority = .required
     ) -> Self {

         constraint(keyPath, relation, to: anchor, constant: constant, multiplier: multiplier, priority: priority)
         return self
     }

     @discardableResult
     func constraint
     <LayoutType: NSLayoutAnchor<AnchorType>, AnchorType>(
         _ keyPath: KeyPath<UIView, LayoutType>,
         _ relation: NSLayoutConstraint.Relation = .equal,
         to anchor: LayoutType,
         constant: CGFloat = 0,
         multiplier: CGFloat? = nil,
         priority: UILayoutPriority = .required
     ) -> NSLayoutConstraint {

         let constraint: NSLayoutConstraint

         if let multiplier = multiplier,
            let dimension = self[keyPath: keyPath] as? NSLayoutDimension,
            let anchor = anchor as? NSLayoutDimension {

             switch relation {
             case .equal:
                 constraint = dimension.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
             case .greaterThanOrEqual:
                 constraint = dimension.constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
             case .lessThanOrEqual:
                 constraint = dimension.constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
             @unknown default:
                 constraint = dimension.constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
             }
         } else {
             switch relation {
             case .equal:
                 constraint = self[keyPath: keyPath].constraint(equalTo: anchor, constant: constant)
             case .greaterThanOrEqual:
                 constraint = self[keyPath: keyPath].constraint(greaterThanOrEqualTo: anchor, constant: constant)
             case .lessThanOrEqual:
                 constraint = self[keyPath: keyPath].constraint(lessThanOrEqualTo: anchor, constant: constant)
             @unknown default:
                 constraint = self[keyPath: keyPath].constraint(equalTo: anchor, constant: constant)
             }
         }
         translatesAutoresizingMaskIntoConstraints = false
         constraint.priority = priority
         constraint.isActive = true

         return constraint
     }

     // MARK: - NSLayoutDimension

     @discardableResult
     func anchor(
         _ anchor: KeyPath<UIView, NSLayoutDimension>,
         _ relation: NSLayoutConstraint.Relation = .equal,
         to constant: CGFloat,
         priority: UILayoutPriority = .required
     ) -> Self {

         constraint(anchor, relation, to: constant, priority: priority)
         return self
     }

     @discardableResult
     func constraint(
         _ keyPath: KeyPath<UIView, NSLayoutDimension>,
         _ relation: NSLayoutConstraint.Relation = .equal,
         to constant: CGFloat = 0,
         priority: UILayoutPriority = .required
     ) -> NSLayoutConstraint {

         let constraint: NSLayoutConstraint

         switch relation {
         case .equal:
             constraint = self[keyPath: keyPath].constraint(equalToConstant: constant)
         case .greaterThanOrEqual:
             constraint = self[keyPath: keyPath].constraint(greaterThanOrEqualToConstant: constant)
         case .lessThanOrEqual:
             constraint = self[keyPath: keyPath].constraint(lessThanOrEqualToConstant: constant)
         @unknown default:
             constraint = self[keyPath: keyPath].constraint(equalToConstant: constant)
         }
         constraint.priority = priority
         constraint.isActive = true
         return constraint
     }
 }

 */

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
