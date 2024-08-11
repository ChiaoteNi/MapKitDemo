//
//  MapItemDetailDemoView.swift
//  MapKitDemo
//
//  Created by 倪僑德 on 2024/8/10.
//

import SwiftUI
import MapKit

@available(iOS 18.0, *)
struct MapItemDetailDemoView: View {

    @State
    private var currentMapItem: MKMapItem?
    @State
    private var showDetailSheet: Bool = false // It's not always required

    var body: some View {
        mapView()
            .overlay(alignment: .topTrailing) {
                presetOptionButtons()
                    .padding(.trailing, 10)
            }
            .overlay(alignment: .topLeading) {
                BackButton()
                    .padding(.leading, 10)
            }
            .hideNavigationBar()

            /*
             `mapItemDetailSheet` is not just a function of Map
             Instead, you're able to invoke it from any kinds of view
             Basically, it's just a present function for the MapItemDetailSheet
             */

            // Case 1 - Basic usage
            .mapItemDetailSheet(item: $currentMapItem, displaysMap: true)

//            // Case 2 - Handle presentation control separately
//            .mapItemDetailSheet( // iOS 18 and later
//                isPresented: $showDetailSheet,
//                item: currentMapItem,
//                displaysMap: true // To display the map inside the presenting detail view
//            )
    }
}

// MARK: - ViewBuilders
@available(iOS 18.0, *)
extension MapItemDetailDemoView {

    @ViewBuilder
    private func mapView() -> some View {
        Map(
            position: .constant(.automatic),
            interactionModes: .all,
            selection: $currentMapItem
        ) {
            if let currentMapItem {
                Marker(item: currentMapItem)
            }
        }
    }

    @ViewBuilder
    private func presetOptionButtons() -> some View {
        PresetOptionButtons{ item in
            currentMapItem = item
            showDetailSheet = true // For case 2
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    MapItemDetailDemoView()
}
