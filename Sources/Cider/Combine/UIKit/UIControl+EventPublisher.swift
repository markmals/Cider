//
//  UIControl+EventPublisher.swift
//
//  Created by Mark Malstrom on 3/11/23.
//
// h/t @johnsundell@mastodon.social:
// https://www.swiftbysundell.com/articles/building-custom-combine-publishers-in-swift/
//

import Combine
import UIKit

public extension UIControl {
    struct EventPublisher: Publisher {
        public typealias Output = Void
        public typealias Failure = Never

        fileprivate var control: UIControl
        fileprivate var event: Event

        public func receive<S: Subscriber>(
            subscriber: S
        ) where S.Input == Output, S.Failure == Failure {
            let subscription = EventSubscription<S>()
            subscription.target = subscriber
            subscriber.receive(subscription: subscription)

            control.addTarget(
                subscription,
                action: #selector(subscription.trigger),
                for: event
            )
        }
    }
}

private extension UIControl {
    final class EventSubscription<Target: Subscriber>: Subscription where Target.Input == Void {
        var target: Target?

        // This subscription doesn't respond to demand, since it'll
        // simply emit events according to its underlying UIControl
        // instance, but we still have to implement this method
        // in order to conform to the Subscription protocol:
        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            // When our subscription was cancelled, we'll release
            // the reference to our target to prevent any
            // additional events from being sent to it:
            target = nil
        }

        @objc func trigger() {
            // Whenever an event was triggered by the underlying
            // UIControl instance, we'll simply pass Void to our
            // target to emit that event:
            let _ = target?.receive(())
        }
    }
}

public extension UIControl {
    func publisher(for event: Event) -> EventPublisher {
        EventPublisher(
            control: self,
            event: event
        )
    }
}
