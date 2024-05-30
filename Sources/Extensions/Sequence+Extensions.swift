//
//  Sequence+Extensions.swift
//
//  Created by Artur on 3.04.24.
//  Copyright © 2024. All rights reserved.
//

public extension Sequence {
    
    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            guard let value = try await transform(element) else {
                continue
            }

            values.append(value)
        }

        return values
    }
    
    func concurrentCompactMap<T>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping (Element) async -> T?
    ) async -> [T] {
        let tasks = map { element in
            Task(priority: priority) {
                await transform(element)
            }
        }

        return await tasks.asyncCompactMap { task in
            await task.value
        }
    }
    
    func asyncFlatMap<T: Sequence>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        var values = [T.Element]()
        
        for element in self {
            try await values.append(contentsOf: transform(element))
        }
        
        return values
    }
    
    func concurrentFlatMap<T: Sequence>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @escaping (Element) async -> T
    ) async -> [T.Element] {
        let tasks = map { element in
            Task(priority: priority) {
                await transform(element)
            }
        }
        
        return await tasks.asyncFlatMap { task in
            await task.value
        }
    }
}
