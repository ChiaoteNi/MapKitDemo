//
//  MapItemOptionButtons.swift
//  MapKitDemo
//
//  Created by 倪僑德 on 2024/8/10.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct PresetOptionButtons: View {

    @State
    private var mapItems: [MKMapItem] = []
    private let onOptionDidSelectHandler: ((MKMapItem) -> Void)

    init(
        mapItems: [MKMapItem] = [],
        onOptionDidSelectHandler: @escaping (MKMapItem) -> Void
    ) {
        self.onOptionDidSelectHandler = onOptionDidSelectHandler
        self.mapItems = mapItems
    }

    var body: some View {
        VStack(alignment: .center) {
            ForEach(mapItems, id: \.self) { item in
                Button(action: {
                    onOptionDidSelectHandler(item)
                }) {
                    Text(item.name ?? "")
                        .font(.subheadline)
                        .frame(width: 110)
                        .commonButtonStyle()
                }
            }
            .animation(.easeInOut, value: mapItems)

        }
        .task {
            guard mapItems.isEmpty else { return }
            mapItems = await makeDefaultMapItems()
        }
    }
}

// MARK: - Private functions
@available(iOS 17.0, *)
extension PresetOptionButtons {

    private func makeDefaultMapItems() async -> [MKMapItem] {
        guard #available(iOS 18, *) else {
            return []
        }
        let mapItems = await [
            "I9F5C79B7A59D296F", // Here are some IDs I saved for the demo
            "I78E51C9F47CC4F7B", // All of them could be use on web as well
            "IF4B9F085287510CE",
            "I9B15C5D7679062F9",
            "I5F8E3BF52C658B50",
            "I9F6B7D68751DB87D"
        ]
            .compactMap {
                MKMapItem.Identifier(rawValue: $0) // iOS 18 and later
            }
            .asyncCompactMap { id -> MKMapItem? in
                let request = MKMapItemRequest(mapItemIdentifier: id) // iOS 18 and later
                let mapItem = try? await request.mapItem
                return mapItem
            }
        return mapItems
    }
}

@available(iOS 17.0, *)
#Preview {
    PresetOptionButtons { _ in }
}
