//
//  SpotAreaDemoView.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct SpotAreaDemoView: View {

    enum ShapeType: String, CaseIterable {
        case circle
        case polygon

        var title: String {
            rawValue.capitalized
        }
    }

    @State
    private var currentMapItem: MKMapItem?
    @State
    private var cameraPosition: MapCameraPosition = .automatic
    @State
    private var shapeType: ShapeType = .polygon

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
            .overlay(alignment: .bottom, content: {
                shapeTypeOption()
            })
            .hideNavigationBar()
            .animation(.easeInOut, value: cameraPosition)
            .onChange(of: currentMapItem) { oldValue, newValue in
                cameraPosition = currentMapItem.map {
                    MapCameraPosition.item($0, allowsAutomaticPitch: true)
                } ?? .automatic
            }
    }
}

// MARK: - ViewBuilders
@available(iOS 17.0, *)
extension SpotAreaDemoView {

    @ViewBuilder
    private func mapView() -> some View {
        Map(
            position: $cameraPosition,
            interactionModes: .all,
            selection: $currentMapItem
        ) {
            if let item = currentMapItem {
                switch shapeType {
                case .circle:
                    MapCircle(center: item.placemark.coordinate, radius: 30)
                        .foregroundStyle(Color.purple.opacity(0.5))
                        .mapOverlayLevel(level: .aboveLabels) // aboveRoads, aboveLabels
                case .polygon:
                    let center = item.placemark.coordinate
                    let edgePoints: [CLLocationCoordinate2D] = [
                        center.coordinate(atDistance: 50, bearing: 0),
                        center.coordinate(atDistance: 50, bearing: 120),
                        center.coordinate(atDistance: 50, bearing: 240)
                    ]
                    MapPolygon(coordinates: edgePoints)
                        .foregroundStyle(Color.orange.opacity(0.5))
                        .mapOverlayLevel(level: .aboveRoads) // aboveRoads, aboveRoads
                }
            }
        }
    }

    @ViewBuilder
    private func presetOptionButtons() -> some View {
        PresetOptionButtons{ item in
            currentMapItem = item
        }
    }

    @ViewBuilder
    private func shapeTypeOption() -> some View {
        HStack {
            ForEach(ShapeType.allCases, id: \.self) { type in
                CommonButton(title: type.title) {
                    shapeType = type
                }
                .foregroundColor(shapeType == type ? .blue : .gray)
            }
        }
    }
}

private extension CLLocationCoordinate2D {
    /// Returns a new coordinate at a specified distance and bearing (angle) from the current coordinate.
    ///
    /// - Parameters:
    ///   - distanceMeters: The distance to the new coordinate in meters.
    ///   - bearingDegrees: The bearing (angle) to the new coordinate in degrees.
    /// - Returns: A `CLLocationCoordinate2D` representing the new coordinate.
    func coordinate(atDistance distanceMeters: CLLocationDistance, bearing bearingDegrees: Double) -> CLLocationCoordinate2D {
        // Convert meters to nautical miles
        let distanceInNauticalMiles = distanceMeters / 1852.0
        // Convert degrees to radians
        let bearingRadians = bearingDegrees * .pi / 180

        let newLatitude = latitude + (distanceInNauticalMiles / 60) * cos(bearingRadians)
        let newLongitude = longitude + (distanceInNauticalMiles / 60) * sin(bearingRadians)
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
}

@available(iOS 18.0, *)
#Preview {
    SpotAreaDemoView()
}
