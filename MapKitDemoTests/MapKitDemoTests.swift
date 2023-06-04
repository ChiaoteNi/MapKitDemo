//
//  MapKitDemoTests.swift
//  MapKitDemoTests
//
//  Created by Chiaote Ni on 2023/5/28.
//

import XCTest
@testable import MapKitDemo

/*
 Here are some examples that demonstrate the potential implementation of writing test cases with this pattern
 */

final class MapKitDemoTests: XCTestCase {

//    var sut: MapKitDemoInteractor!
//    var mockStateStore: MockStateStore!
//    var mockDisplayStateStore: MockDisplayStateStore!
//    var mockAttractionsSearcher: MockAttractionsSearcher!
//    var mockLookAroundSceneRetriever: MockLookAroundSceneRetriever!
//    var mockRouteService: MockRouteService!

    override func setUpWithError() throws {
        // Create your mock objects
        /*
        mockStateStore = MockStateStore()
        mockDisplayStateStore = MockDisplayStateStore()
        mockAttractionsSearcher = MockAttractionsSearcher()
        mockLookAroundSceneRetriever = MockLookAroundSceneRetriever()
        mockRouteService = MockRouteService()
         */

        // Inject the mock objects into your SUT
        /*
        sut = MapKitDemoInteractor(
            states: mockStateStore,
            stateStore: mockDisplayStateStore,
            attractionsSearcher: mockAttractionsSearcher,
            lookAroundSceneRetriever: mockLookAroundSceneRetriever,
            routeService: mockRouteService
        )
         */
    }

    override func tearDownWithError() throws {
//        sut = nil
//        mockStateStore = nil
//        mockDisplayStateStore = nil
//        mockAttractionsSearcher = nil
//        mockLookAroundSceneRetriever = nil
//        mockRouteService = nil

        try super.tearDownWithError()
    }

//    func testDirectionButtonTapped() async throws {
//        // Arrange
//        let currentMode = DisplayMode.search
//        let sourceIndex = 0
//        let destinationIndex = 1
//
//        let item1 = MKMapItem() // TODO: Setup your test data here
//        let item2 = MKMapItem() // TODO: Setup your test data here
//
//        // Set up your mocks to return the expected values
//        let mockDisplayStateStore = MockDisplayStateStore()
//        mockDisplayStateStore.currentModeValue = currentMode
//        // TODO: Setup other mocks
//
//        let sut = MapKitDemoInteractor(stateStore: mockDisplayStateStore)
//
//        // Act
//        await sut.directionButtonTapped()
//
//        // Assert
//        XCTAssertTrue(mockDisplayStateStore.updateModeCalled, "update(mode:) was not called")
//        XCTAssertTrue(mockDisplayStateStore.setIsLoadingCalled, "set(isLoading:) was not called")
//        // TODO: Add more assertions for other mocks
//    }

    // Continue with other test cases...
}

// MARK: - Test Doubles
extension MapKitDemoTests {

//    class MockDisplayStateStore: MapKitDemoDisplayStateStoring {
//        var currentModeCalled = false
//        var updateModeCalled = false
//        var setIsLoadingCalled = false
//        // Add flags for all the methods in the protocol
//
//        var currentModeValue: DisplayMode = .search
//        var isLoadingValue: Bool = false
//        // Add stored values for all the properties in the protocol
//
//        func currentMode() async -> DisplayMode {
//            currentModeCalled = true
//            return currentModeValue
//        }
//
//        func update(mode: DisplayMode) async {
//            updateModeCalled = true
//            currentModeValue = mode
//        }
//
//        func set(isLoading: Bool) async {
//            setIsLoadingCalled = true
//            isLoadingValue = isLoading
//        }
//
//        // Implement all the other methods in the protocol
//    }
}
