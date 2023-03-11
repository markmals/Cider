//
//  RunLoopTickPublisher.swift
//
//  Created by Mark Malstrom on 3/4/23.
//

import Combine
import QuartzCore

internal final class RunLoopTickPublisher: Publisher {
    internal typealias Output = Void
    internal typealias Failure = Never

    private let subject = CurrentValueSubject<Output, Failure>(())

    private let ticksLimit: UInt
    private var ticks: UInt = 0

    private var displayLink: CADisplayLink?

    internal init(ticks: UInt) {
        self.ticksLimit = ticks
    }

    internal func receive<S: Subscriber<Output, Failure>>(subscriber: S) {
        displayLink = CADisplayLink(target: self, selector: #selector(step))
            .configure {
                $0.add(
                    to: .current,
                    forMode: RunLoop.Mode.default
                )
            }

        subject.receive(subscriber: subscriber)
    }

    @objc private func step(displaylink: CADisplayLink) {
        Swift.print(ticks)

        if ticks >= ticksLimit {
            displayLink?.invalidate()
            subject.send()
        }

        ticks += 1
    }
}
