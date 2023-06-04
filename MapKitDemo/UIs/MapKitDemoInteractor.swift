//
//  Interactor.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/30.
//

import Foundation
import Combine
import MapKit

enum DisplayMode {
    case search
    case direction
}

protocol MapKitDemoDisplayStateStoring {
    func currentMode() async -> DisplayMode
    func update(mode: DisplayMode) async

    func set(isLoading: Bool) async
    func set(isSearchBarActive: Bool) async

    func suggestedMapItems(at index: Int) async -> MKMapItem?
    func update(suggestedMapItems: [MKMapItem]) async

    func update(currentLookAroundScene: MKLookAroundScene?) async
    func update(currentRegion: MKCoordinateRegion) async
    func update(currentCamera: MKMapCamera?) async

    var annotations: [MKAnnotation] { get async }
    func update(annotations: [MKAnnotation]) async

    func update(currentRoute: MKRoute?) async
    func update(currentSearchText: String?) async
}

final class MapKitDemoInteractor: MapKitDemoBusinessLogic {

    actor StateStore {
        var selectedMapItem: MKMapItem? = nil
        var storedMapItems: [MKMapItem] = []
        var currentAttractionIndex: Int = 0

        func update(selectedMapItem: MKMapItem?) {
            self.selectedMapItem = selectedMapItem
        }

        func storeSelectedMapItem() {
            guard let selectedMapItem else { return }
            storedMapItems.append(selectedMapItem)
        }

        func storedItem(at indexes: [Int]) -> [MKMapItem?] {
            indexes.map { storedMapItems[safe: $0] }
        }

        func update(currentAttractionIndex: Int) {
            self.currentAttractionIndex = currentAttractionIndex
        }
    }

    private let attractionsSearcher: AttractionsSearcher
    private let lookAroundSceneRetriever: SceneRetriever
    private let routeService: RouteService

    private var internalStates: StateStore
    private var displayStates: MapKitDemoDisplayStateStoring

    private let searchRegion: MKCoordinateRegion
    private var searchText = PassthroughSubject<String, Never>()
    private var cancellables: Set<AnyCancellable> = []

    init(
        states: StateStore = StateStore(),
        stateStore: MapKitDemoDisplayStateStoring,
        searchRegion: MKCoordinateRegion = .japan,
        attractionsSearcher: AttractionsSearcher = AttractionsSearcher(),
        lookAroundSceneRetriever: SceneRetriever = SceneRetriever(),
        routeService: RouteService = RouteService()
    ) {
        self.internalStates = states
        self.displayStates = stateStore

        self.attractionsSearcher = attractionsSearcher
        self.lookAroundSceneRetriever = lookAroundSceneRetriever
        self.routeService = routeService

        self.searchRegion = searchRegion

        setupSearchTextObserver()
    }

    func searchBarTextChanged(to searchText: String) {
        self.searchText.send(searchText)
    }

    func tapOnSuggestionsItem(at index: Int) {
        Task {
            guard let item = await displayStates.suggestedMapItems(at: index) else {
                return
            }
            await internalStates.update(selectedMapItem: item)
            await displayStates.update(currentSearchText: item.name)
            await displayStates.update(suggestedMapItems: [])
            await displayStates.update(annotations: makeAnnotations(from: [item]))
            await displayStates.update(currentCamera: MKMapCamera(
                lookingAtCenter: item.placemark.coordinate,
                fromDistance: 1000,
                pitch: 60,
                heading: 0
            ))
            do {
                let scene = try await lookAroundSceneRetriever.fetchScene(with: item)
                await displayStates.update(currentLookAroundScene: scene)
            } catch {
                await displayStates.update(currentLookAroundScene: nil)
            }
        }
    }

    @objc
    func directionButtonTapped() {
        Task {
            let currentMode = await displayStates.currentMode()
            if case .search = currentMode {
                await switchToDirectionMode()
            }

            let sourceIndex = await internalStates.currentAttractionIndex
            let destinationIndex = sourceIndex + 1
            let items = await internalStates.storedItem(at: [sourceIndex, destinationIndex])

            guard
                let sourceItem = items[0],
                let destinationItem = items[1]
            else {
                await endUpDirectionMode()
                return
            }
            
            await displayStates.set(isLoading: true)
            let route = await routeService.generateRoute(from: sourceItem, to: destinationItem)
            await displayStates.update(currentRoute: route)
            await displayStates.set(isLoading: false)

            await internalStates.update(currentAttractionIndex: destinationIndex)
        }
    }

    func saveSelectedMapItem() {
        Task {
            await internalStates.storeSelectedMapItem()
        }
    }

    func openSelectedMapItemInMaps() {
        Task {
            let mapItem = await internalStates.selectedMapItem
            mapItem?.openInMaps()
        }
    }
}

extension MapKitDemoInteractor {

    private func setupSearchTextObserver() {
        // You should consider to create another object to handle this part.
        // I left it here just because it's demo code and I'm too lazy TvT
        searchText
            .debounce(for: .milliseconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self else { return }

                Task { @MainActor in
                    guard !searchText.isEmpty else {
                        await self.displayStates.update(annotations: [])
                        await self.displayStates.update(suggestedMapItems: [])
                        return
                    }

                    let (items, region) = await self.attractionsSearcher.search(
                        for: searchText,
                        in: .travelPointsOfInterest,
                        in: self.searchRegion
                    )
                    guard !items.isEmpty, let region else { return }

                    await self.displayStates.update(suggestedMapItems: items)
                    await self.displayStates.update(annotations: self.makeAnnotations(from: items))
                    await self.displayStates.update(currentRegion: region)
                }
            }
            .store(in: &cancellables)
    }

    private func makeAnnotations(from mapItems: [MKMapItem]) -> [MKAnnotation] {
        mapItems.map { item -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
                .set(\.title, with: item.name)
                .set(\.subtitle, with: item.placemark.title)
                .set(\.coordinate, with: item.placemark.coordinate)
            return annotation
        }
    }

    private func endUpDirectionMode() async {
        await displayStates.update(mode: .search)
        await displayStates.update(currentRoute: nil)
        await displayStates.set(isSearchBarActive: true)
    }

    private func switchToDirectionMode() async {
        await internalStates.update(currentAttractionIndex: 0)

        let items = await internalStates.storedMapItems
        let annotations = makeAnnotations(from: items)
        await displayStates.update(annotations: annotations)

        await displayStates.update(mode: .direction)
        await displayStates.set(isSearchBarActive: false)
        await displayStates.update(currentLookAroundScene: nil)
    }
}
