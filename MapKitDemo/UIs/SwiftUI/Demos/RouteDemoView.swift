//
//  RouteDemoView.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2024/8/11.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct RouteDemoView: View {

    enum RouteStyle: String, CaseIterable {
        case line
        case dot

        var title: String {
            rawValue.capitalized
        }
    }

    @State
    private var mapItems: [MKMapItem] = []
    @State
    private var cameraPosition: MapCameraPosition = .automatic
    @State
    private var routeStyle: RouteStyle = .line
    @State
    private var routes: [MKRoute] = []

    private let colors: [Color] = [.purple, .orange, .cyan, .indigo, .pink]

    @State
    private var currentTask: Task<(), Never>?

    var body: some View {
        mapView(routeStyle: routeStyle)
            .overlay(alignment: .topTrailing) {
                presetOptionButtons()
                    .padding(.trailing, 10)
            }
            .overlay(alignment: .topLeading) {
                BackButton()
                    .padding(.leading, 10)
            }
            .overlay(alignment: .bottom, content: {
                routeStyleOption()
            })
            .hideNavigationBar()
            .animation(.easeInOut, value: cameraPosition)
            .onChange(of: mapItems) { oldValue, newValue in
                cameraPosition = makeCameraPosition(with: mapItems)

                currentTask?.cancel()
                currentTask = Task {
                    let result = await makeRoutes(with: mapItems)
                    guard !Task.isCancelled else { return }
                    routes = result
                }
            }
    }
}

// MARK: - Private functions
@available(iOS 17.0, *)
extension RouteDemoView {

    // MARK: ViewBuilders

    @ViewBuilder
    private func mapView(routeStyle: RouteStyle) -> some View {
        Map(
            position: $cameraPosition,
            interactionModes: .all,
            selection: .constant(nil)
        ) {
            ForEach(mapItems, id: \.self) { mapItem in
                Marker(item: mapItem)
            }
            ForEach(routes, id: \.self) { route in
                MapPolyline(route)
                    .stroke(
                        colors.randomElement() ?? .blue,
                        style: makeStrokeStyle(with: routeStyle)
                    )
            }
        }
    }

    @ViewBuilder
    private func presetOptionButtons() -> some View {
        PresetOptionButtons{ item in
            if let index = mapItems.firstIndex(of: item) {
                mapItems.remove(at: index)
            }
            mapItems.append(item)
        }
    }

    @ViewBuilder
    private func routeStyleOption() -> some View {
        HStack {
            ForEach(RouteStyle.allCases, id: \.self) { style in
                CommonButton(title: style.title) {
                    routeStyle = style
                }
                .foregroundColor(routeStyle == style ? .blue : .gray)
            }
        }
    }

    // MARK: Helper functions

    private func makeCameraPosition(with mapItems: [MKMapItem]) -> MapCameraPosition {
        let boundingBoxOfItems = mapItems.reduce(into: MKMapRect.null) { result, item in
            let coordinate = item.placemark.coordinate
            let point = MKMapPoint(coordinate)
            let boundingBox = MKMapRect(
                origin: point,
                size: MKMapSize(width: 10, height: 10)
            )
            result = result.union(boundingBox)
        }
        let region = MKCoordinateRegion(boundingBoxOfItems)
        return MapCameraPosition.region(region)
    }

    private func makeRoutes(with mapItems: [MKMapItem]) async -> [MKRoute] {
        var currentItem: MKMapItem?
        let result = await mapItems.asyncCompactMap { item -> [MKRoute]? in
            guard let lastItem = currentItem else {
                currentItem = item
                return nil
            }
            let directionRequest = MKDirections.Request()
            directionRequest.source = lastItem
            directionRequest.destination = item
            directionRequest.transportType = .automobile

            let direction = MKDirections(request: directionRequest)
            let response = try? await direction.calculate()
            return response?.routes
        }
        return result.flatMap { $0 }
    }

    private func makeStrokeStyle(with routeStyle: RouteStyle) -> StrokeStyle {
        switch routeStyle {
        case .line:
            StrokeStyle(
                lineWidth: 5,
                lineCap: .square
            )
        case .dot:
            StrokeStyle(
                lineWidth: 3,
                lineCap: .round,
                lineJoin: .round,
                dash: [1, 6],
                dashPhase: 1
            )
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    RouteDemoView()
}
