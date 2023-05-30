//
//  RouteService.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/30.
//

import Foundation
import MapKit

actor RouteService {

    var cachedRoute: [Int: MKRoute] = [:]

    /*
     extension MKDirections.Request {
         var transportType: MKDirectionsTransportType // Default is MKDirectionsTransportTypeAny

         var requestsAlternateRoutes: Bool // if YES and there is more than one reasonable way to route from source to destination,
                                           // allow the route server to return multiple routes. Default is NO.

         // Set either departure or arrival date to hint to the route server when the trip will take place.
         var departureDate: Date?
         var arrivalDate: Date?

         @available(iOS 16.0, *)
         var tollPreference: MKDirections.RoutePreference // Default is MKDirectionsRoutePreferenceAny
         @available(iOS 16.0, *)
         var highwayPreference: MKDirections.RoutePreference // Default is MKDirectionsRoutePreferenceAny
     }
     */
    func generateRoute(
        from sourceItem: MKMapItem,
        to destinationItem: MKMapItem,
        transportType: MKDirectionsTransportType = .automobile,
        tollPreference: MKDirections.RoutePreference = .any,
        highwayPreference: MKDirections.RoutePreference = .any
    ) async -> MKRoute? {

        let request = MKDirections.Request()
        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = transportType
        request.tollPreference = tollPreference
        request.highwayPreference = highwayPreference

        let hash = request.hash
        if let cache = cachedRoute[hash] {
            return cache
        }

        let direction = MKDirections(request: request)
        do {
            let response = try await direction.calculate()
            //        let expectedTravelTime = await direction.calculateETA()

            if let route = response.routes.first {
                cachedRoute[hash] = route
                return route
            }
        } catch {
            dump(error, name: "🐛")
        }
        return nil
    }
}
