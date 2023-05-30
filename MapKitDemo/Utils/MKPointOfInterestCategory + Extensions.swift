//
//  MKPointOfInterestCategory + Extensions.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import Foundation
import MapKit

extension Array where Element == MKPointOfInterestCategory {

    static var travelPointsOfInterest: [MKPointOfInterestCategory] {[
        .amusementPark,
        .aquarium,
        .airport,
        .bakery,
        .brewery,
        .beach,
        .cafe,
        .carRental,
        .campground,
        .hotel,
        .library,
        .museum,
        .marina,
        .nationalPark,
        .nightlife,
        .park,
        .publicTransport,
        .restaurant,
        .theater,
        .university,
        .winery,
        .zoo
    ]}

    static var transports: [MKPointOfInterestCategory] {[
        .airport,
        .publicTransport,
        .marina
    ]}

    static var outdoors: [MKPointOfInterestCategory] {[
        .beach,
        .campground,
        .nationalPark,
        .park,
        .zoo
    ]}

    static var indoors: [MKPointOfInterestCategory] {[
        .aquarium,
        .bakery,
        .brewery,
        .cafe,
        .library,
        .museum,
        .restaurant,
        .winery
    ]}
}


