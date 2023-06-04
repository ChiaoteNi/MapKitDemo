//
//  StateStore.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/30.
//

import Foundation
import Combine
import MapKit

@MainActor
final class MapKitDemoStateStore: ObservableObject {
    @Published var currentMode: DisplayMode = .search
    @Published var isLoading: Bool = false
    @Published var isSearchBarActive: Bool = false

    @Published var currentSearchText: String? = nil
    @Published var suggestedMapItems: [MKMapItem] = []

    @Published var currentLookAroundScene: MKLookAroundScene? = nil
    @Published var currentRegion: MKCoordinateRegion = .japan
    @Published var currentCamera: MKMapCamera?
    @Published var annotations: [MKAnnotation] = []

    @Published var currentRoute: MKRoute? = nil
    @Published var currentMapRect: MKMapRect? = nil
}

extension MapKitDemoStateStore: MapKitDemoDisplayStateStoring {

    func set(isLoading: Bool) async {
        self.isLoading = isLoading
    }

    func set(isSearchBarActive: Bool) async {
        self.isSearchBarActive = isSearchBarActive
    }

    func currentMode() async -> DisplayMode {
        currentMode
    }

    func update(mode: DisplayMode) async {
        self.currentMode = mode
    }

    func suggestedMapItems(at index: Int) async -> MKMapItem? {
        suggestedMapItems[safe: index]
    }

    func update(suggestedMapItems: [MKMapItem]) async {
        self.suggestedMapItems = suggestedMapItems
    }

    func update(currentLookAroundScene: MKLookAroundScene?) async {
        self.currentLookAroundScene = currentLookAroundScene
    }

    func update(currentRegion: MKCoordinateRegion) async {
        self.currentRegion = currentRegion
    }

    func update(currentCamera: MKMapCamera?) async {
        self.currentCamera = currentCamera
    }

    func update(annotations: [MKAnnotation]) async {
        self.annotations = annotations
    }

    func update(currentRoute: MKRoute?) async {
        self.currentRoute = currentRoute
    }

    func update(currentSearchText: String?) async {
        self.currentSearchText = currentSearchText
    }
}
