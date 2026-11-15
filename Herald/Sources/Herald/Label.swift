import UIKit
import Combine

public extension UILabel {
    convenience init<S>(_ content: S) where S : StringProtocol {
        self.init()
        self.text = String(content)
    }
    
    convenience init<P: Publisher>(_ contentPublisher: P) where P.Output == String, P.Failure == Never {
        self.init(frame: .zero)
        contentPublisher.subscribe(subscriber)
    }
    
    func font(_ font: UIFont?) -> UILabel {
        configure { $0.font = font }
    }
    
    func preferredFont(_ textStyle: UIFont.TextStyle) -> UILabel {
        configure { $0.font = .preferredFont(forTextStyle: textStyle) }
    }
    
    func fontWeight(_ weight: UIFont.Weight?) -> UILabel {
        font(weight != nil ? .systemFont(ofSize: font.pointSize, weight: weight!) : nil)
    }
    
    func textColor(_ color: UIColor?) -> UILabel {
        configure { if let color = color { $0.textColor = color } }
    }
    
    func bold() -> UILabel {
        font(.systemFont(ofSize: font.pointSize, weight: .bold))
    }
    
    func italic() -> UILabel {
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)!
        return font(UIFont(descriptor: descriptor, size: font.pointSize))
    }

    func underlined() -> UILabel {
        let underlineAttributedString = NSAttributedString(
            string: text!,
            attributes: [.underlineStyle: NSUnderlineStyle.single]
        )
        
        return configure { $0.attributedText = underlineAttributedString }
    }
    
    func lineBreak(_ mode: NSLineBreakMode) -> UILabel {
        configure { $0.lineBreakMode = mode }
    }
    
    func lines(_ numberOfLines: Int) -> UILabel {
        configure { $0.numberOfLines = numberOfLines }
    }
    
    var subscriber: AnySubscriber<String, Never> {
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
