//
//  MapItemIdentifierDemoView.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI
import MapKit

/*
 Place IDs are unique identifiers for each point of interest in Maps.
 To look up a specific Place ID, visit: https://developer.apple.com/maps/place-id-lookup/
 */

@available(iOS 18.0, *)
struct MapItemIdentifierDemoView: View {

    @State
    private var mapItems: [MKMapItem] = []
    @State
    private var currentMapItem: MKMapItem?

    private let ids: [String] = [
        "I9F5C79B7A59D296F", // Here are some IDs I saved for the demo
        "I78E51C9F47CC4F7B", // All of them could be use on web as well
        "IF4B9F085287510CE",
        "I9B15C5D7679062F9",
        "I5F8E3BF52C658B50"
    ]

    var body: some View {
        mapView()
            .overlay(alignment: .topTrailing) {
                requestItemsButton()
                    .padding(.leading, 10)
            }
            .overlay(alignment: .topLeading) {
                BackButton()
                    .padding(.leading, 10)
            }
            .hideNavigationBar()
    }
}

// MARK: - ViewBuilders
@available(iOS 18.0, *)
extension MapItemIdentifierDemoView {

    @ViewBuilder
    private func mapView() -> some View {
        Map(
            position: .constant(.automatic),
            interactionModes: .all,
            selection: $currentMapItem
        ) {
            ForEach(mapItems, id: \.self) { item in
                Marker(item: item)
            }
            .mapItemDetailSelectionAccessory(.sheet) // callout, sheet, caption, automatic
        }
    }

    @ViewBuilder
    private func requestItemsButton() -> some View {
        CommonButton(title: "Start 🚀") {
            Task {
                mapItems = await makeMapItems(with: ids)
            }
        }
    }

    private func makeMapItems(with identifiers: [String]) async -> [MKMapItem] {
        // The following logic is identical to that in PresetOptionButtons.
        // I intentionally duplicated it here to make this demo clearer.
        await identifiers
            .compactMap { id in
                MKMapItem.Identifier(rawValue: id)  // iOS 18 and later
            }
            .asyncCompactMap { id -> MKMapItem? in
                let request = MKMapItemRequest(mapItemIdentifier: id) // iOS 18 and later
                let mapItem = try? await request.mapItem
                return mapItem
            }
    }
}

@available(iOS 18.0, *)
#Preview {
    MapItemIdentifierDemoView()
}
