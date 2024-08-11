//
//  Async + Sequence.swift
//  MapKitDemo
//
//  Created by 倪僑德 on 2024/8/10.
//

import Foundation

extension Sequence {

    // For more different kinds of implementation, please refer to this repo: https://github.com/ChiaoteNi/StructuredCuoncurrencyDemo
    func asyncCompactMap<ElementOfResult>(
        _ transform: @escaping (Element) async throws -> ElementOfResult?
    ) async rethrows -> [ElementOfResult] {

        var results = [ElementOfResult]()
        let tasks = map { element in
            Task { try await transform(element) }
        }
        for task in tasks {
            if let result = try? await task.value {
                results.append(result)
            }
        }
        return results
    }
}
