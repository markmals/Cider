//
//  PassthroughSubject+emittingValues.swift
//
//
//  Created by Mark Malstrom on 3/11/23.
//

import Combine

extension PassthroughSubject where Failure == Error {
    static func emittingValues<T: AsyncSequence>(
        from sequence: T
    ) -> Self where T.Element == Output {
        let subject = Self()

        Task {
            do {
                for try await value in sequence {
                    subject.send(value)
                }

                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }

        return subject
    }
}

extension PassthroughSubject where Failure == Never {
    static func emittingValues(
        from stream: AsyncStream<Output>
    ) -> Self {
        let subject = Self()

        Task {
            for await value in stream {
                subject.send(value)
            }

            subject.send(completion: .finished)
        }

        return subject
    }
}

extension PassthroughSubject {
    static func emittingValues<E: Error>(
        from stream: AsyncThrowingStream<Output, E>
    ) -> PassthroughSubject<Output, E> {
        let subject = PassthroughSubject<Output, E>()

        Task {
            do {
                for try await value in stream {
                    subject.send(value)
                }

                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error as! E))
            }
        }

        return subject
    }
}
