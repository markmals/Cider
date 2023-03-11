//
//  Publisher+asyncMap.swift
//
//  Created by Mark Malstrom on 3/11/23.
//
//  h/t @johnsundell@mastodon.social:
//  https://www.swiftbysundell.com/articles/calling-async-functions-within-a-combine-pipeline/
//

import Combine

public extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            .init { await transform(value) }
        }
    }

    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            .init { try await transform(value) }
        }
    }

    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) ->
        Publishers.FlatMap<
            Future<T, Error>,
            Publishers.SetFailureType<Self, Error>
        >
    {
        flatMap { value in
            .init { try await transform(value) }
        }
    }
}
