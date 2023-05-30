//
//  SceneRetriever.swift
//  MapKitDemo
//
//  Created by Chiaote Ni on 2023/5/28.
//

import Foundation
import MapKit

actor SceneRetriever {

    enum SceneRetrievalError: Error {
        case requiredItemNameNotFound
    }

    var cachedScenes: [String: MKLookAroundScene?] = [:] // Not all position is with MKLookAroundScene

    func fetchScene(with mapItem: MKMapItem) async throws -> MKLookAroundScene? {
        guard let name = mapItem.name else {
            throw SceneRetrievalError.requiredItemNameNotFound
        }

        if let cache = cachedScenes[name] {
            return cache
        }
        let request = MKLookAroundSceneRequest(mapItem: mapItem)
        do {
            let result = try await request.scene

            if cachedScenes[name] == nil {
                // Sure it's ok the override the current cache with the new one.
                // The implementation here is just to highlight a potential issue cause by the reentrancy of actor
                cachedScenes[name] = result
            }
            return result
        } catch {
            throw error
        }
    }

    func generateSnapshot(for scene: MKLookAroundScene, with size: CGSize) async throws -> UIImage {
        let options = MKLookAroundSnapshotter.Options()
        options.size = size
        // Turn off all point of interest labels in the snapshot.
        options.pointOfInterestFilter = .includingAll

        return try await MKLookAroundSnapshotter(scene: scene, options: options).snapshot.image
    }
}
