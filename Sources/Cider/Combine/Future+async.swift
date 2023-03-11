//
//  Future+async.swift
//
//  Created by Mark Malstrom on 3/11/23.
//
//  h/t @johnsundell@mastodon.social:
//  https://www.swiftbysundell.com/articles/creating-combine-compatible-versions-of-async-await-apis/
//

import Combine

public extension Future where Failure == Error {
    convenience init(operation: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let output = try await operation()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}

public extension Future where Failure == Never {
    convenience init(operation: @escaping () async -> Output) {
        self.init { promise in
            Task {
                let output = await operation()
                promise(.success(output))
            }
        }
    }
}
