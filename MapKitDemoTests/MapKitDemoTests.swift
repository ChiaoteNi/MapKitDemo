//
//  MapKitDemoTests.swift
//  MapKitDemoTests
//
//  Created by Chiaote Ni on 2023/5/28.
//

import XCTest
@testable import MapKitDemo

final class MapKitDemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let sut = AttractionsSearcher()
        let response = await sut.search(for: "中正", in: .travelPointsOfInterest)
        dump(response)
        print("End")
    }
}
