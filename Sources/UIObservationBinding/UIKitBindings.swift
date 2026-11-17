#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit

extension ObservationBindable where Self: UIControl {
    /// Two-way binding: keeps `keyPath` equal to `binding`, and writes the control's value back
    /// through it whenever the control sends `event`.
    ///
    /// ```swift
    /// slider.bind(\.value, to: $model.volume, sentBy: .valueChanged)
    /// ```
    @MainActor
    public func bind<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to binding: UIBinding<Value>,
        sentBy event: UIControl.Event
    ) {
        bind(keyPath, to: binding.wrappedValue)
        let control = WeakReference(self)
        addAction(
            UIAction(identifier: .binding(keyPath)) { _ in
                guard let control = control.value else { return }
                binding.wrappedValue = control[keyPath: keyPath]
            },
            for: event
        )
    }
}

extension UIAction.Identifier {
    /// One identifier per bound key path, so binding it again replaces the earlier action.
    fileprivate static func binding(_ keyPath: AnyKeyPath) -> Self {
        Self("UIObservationBinding \(keyPath)")
    }
}

extension UILabel {
    /// A label whose text tracks `text`: `UILabel(text: "\(cart.count) items")`.
    public convenience init(text: @escaping @autoclosure @MainActor () -> String?) {
        self.init(frame: .zero)
        // Through the concrete type: a key path rooted in an initializer's dynamic Self crashes
        // at runtime ("could not demangle keypath type").
        (self as UILabel).bind(\.text, to: text())
    }
}

extension UIButton {
    /// A system button whose title tracks `title`.
    public convenience init(title: @escaping @autoclosure @MainActor () -> String, action: UIAction)
    {
        self.init(type: .system, primaryAction: action)
        sink(.named("title"), title) { button, title in button.setTitle(title, for: .normal) }
    }
}

extension UITextField {
    /// A text field bound two ways to `text`; edits write back as the user types.
    public convenience init(text: UIBinding<String>) {
        self.init(frame: .zero)
        bind(text: text)
    }

    /// Binds the text two ways to `text`. Changes from the binding wait while the user is
    /// composing marked text, such as an unfinished Japanese word.
    public func bind(text: UIBinding<String>) {
        let current: @MainActor () -> String = { text.wrappedValue }
        sink(.value(\UITextField.text), current) { field, newText in
            guard field.markedTextRange == nil, field.text != newText else { return }
            field.text = newText
        }
        let field = WeakReference(self)
        addAction(
            UIAction(identifier: .binding(\UITextField.text)) { _ in
                guard let field = field.value else { return }
                text.wrappedValue = field.text ?? ""
            },
            for: .editingChanged
        )
    }
}

#if !os(tvOS)
extension UISwitch {
    /// A switch bound two ways to `isOn`.
    public convenience init(isOn: UIBinding<Bool>) {
        self.init(frame: .zero)
        (self as UISwitch).bind(\.isOn, to: isOn, sentBy: .valueChanged)
    }
}

extension UISearchBar {
    /// Binds the search text two ways to `text`, through `searchTextField`.
    public func bind(text: UIBinding<String>) {
        searchTextField.bind(text: text)
    }
}
#endif
#endif
