//
//  AttractionsSearcher.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import Foundation
import MapKit

actor AttractionsSearcher {

    private var currentSearch: MKLocalSearch?

    /// - Parameter queryString: A search string from the text the user enters into `UISearchBar`.
    func search(
        for queryString: String,
        in categories: [MKPointOfInterestCategory],
        in region: MKCoordinateRegion = MKCoordinateRegion(.world)
    ) async -> (results: [MKMapItem], boundingRegion: MKCoordinateRegion?) {

        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter()
        // Confine the map search area.
        searchRequest.region = region
        // Include only point-of-interest results. This excludes results based on address matches.
        searchRequest.resultTypes = [.pointOfInterest]

        do {
            let response = try await search(using: searchRequest)
            return (response.mapItems, response.boundingRegion)
        } catch {
            dump(error, name: "🐛 Exception") // TODO: check if it will print in release build as well
            return ([], nil)
        }
    }
}

extension AttractionsSearcher {

    private func search(using searchRequest: MKLocalSearch.Request) async throws -> MKLocalSearch.Response {
        try await withCheckedThrowingContinuation { continuation in
            currentSearch = MKLocalSearch(request: searchRequest)
            currentSearch?.start { [unowned self] (response, error) in
                guard currentSearch === self.currentSearch else {
                    continuation.resume(throwing: MapKitDemoError(message: "request has changed"))
                    return
                }
                if let response {
                    continuation.resume(returning: response)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: MapKitDemoError(message: "no valid response"))
                }
            }
        }
    }
}
