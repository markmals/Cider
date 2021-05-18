import UIKit
import Combine

extension UILabel {
    public var subscriber: AnySubscriber<String, Never> {
        AnySubscriber(UILabelTextSubscriber(self))
    }

    private class UILabelTextSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = Never

        private var label: UILabel?
        init(_ label: UILabel) { self.label = label }

        func receive(subscription: Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: String) -> Subscribers.Demand {
            label?.text = input
            return .unlimited
        }

        func receive(completion: Subscribers.Completion<Never>) {
            label = nil
        }
    }
}
