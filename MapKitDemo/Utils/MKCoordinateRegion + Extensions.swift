//
//  MKCoordinateRegion + Extensions.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import Foundation
import MapKit

extension MKCoordinateRegion {

    static var japan: MKCoordinateRegion {
        let maxLat: CLLocationDegrees = 45.581075
        let minLat: CLLocationDegrees = 24.103002
        let maxLong: CLLocationDegrees = 149.056835
        let minLong: CLLocationDegrees = 122.781030

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (maxLat + minLat) / 2,
                longitude: (maxLong + minLong) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: maxLat - minLat,
                longitudeDelta: maxLong - minLong
            )
        )
    }
}
