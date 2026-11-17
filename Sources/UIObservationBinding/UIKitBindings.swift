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
        let control = WeakReference(self)
        let writeBack = WriteBackAction(on: self, for: event) {
            guard let control = control.value else { return }
            binding.wrappedValue = control[keyPath: keyPath]
        }
        bind(keyPath, to: { binding.wrappedValue }, writeBack: writeBack)
    }
}

/// A control action that writes the control's value back to a model. Releasing it removes the
/// action from the control, which is how replacing a binding ends its write-back.
@MainActor
private final class WriteBackAction {
    private weak var control: UIControl?
    private let action: UIAction
    private let event: UIControl.Event

    init(
        on control: UIControl,
        for event: UIControl.Event,
        _ write: @escaping @MainActor () -> Void
    ) {
        self.control = control
        self.event = event
        action = UIAction { _ in write() }
        control.addAction(action, for: event)
    }

    isolated deinit {
        control?.removeAction(action, for: event)
    }
}

extension UILabel {
    /// A label whose text tracks `text`: `UILabel(text: "\(cart.count) items")`.
    public convenience init(text: @escaping @autoclosure @MainActor () -> String?) {
        self.init(frame: .zero)
        bind(text: text())
    }

    /// Makes the text track `text`, replacing what `init(text:)` or an earlier call bound. The
    /// binding is keyed on `UILabel` whatever the label's class, so this replaces it on a
    /// subclass too, where `bind(\.text, to:)` would add a second binding.
    public func bind(text: @escaping @autoclosure @MainActor () -> String?) {
        bind(\UILabel.text, to: text, writeBack: nil)
    }
}

extension UIButton {
    /// A system button whose title tracks `title`.
    public convenience init(title: @escaping @autoclosure @MainActor () -> String, action: UIAction)
    {
        self.init(type: .system, primaryAction: action)
        bind(title: title())
    }

    /// Makes the normal-state title track `title`, replacing what `init(title:action:)` or an
    /// earlier call bound.
    public func bind(title: @escaping @autoclosure @MainActor () -> String) {
        sink(.named("title"), title) { button, newTitle in
            button.setTitle(newTitle, for: .normal)
        }
    }
}

extension UITextField {
    /// A text field bound two ways to `text`; edits write back as the user types.
    public convenience init(text: UIBinding<String>) {
        self.init(frame: .zero)
        bind(text: text)
    }

    /// Binds the text two ways to `text`, replacing what `init(text:)` or an earlier call bound.
    /// Changes from the binding wait while the user is composing marked text, such as an
    /// unfinished Japanese word.
    public func bind(text: UIBinding<String>) {
        let weakField = WeakReference(self)
        let writeBack = WriteBackAction(on: self, for: .editingChanged) {
            guard let field = weakField.value else { return }
            text.wrappedValue = field.text ?? ""
        }
        let current: @MainActor () -> String = { text.wrappedValue }
        sink(.value(\UITextField.text), current, writeBack: writeBack) { field, newText in
            guard field.markedTextRange == nil, field.text != newText else { return }
            field.text = newText
        }
    }
}

#if !os(tvOS)
extension UISwitch {
    /// A switch bound two ways to `isOn`.
    public convenience init(isOn: UIBinding<Bool>) {
        self.init(frame: .zero)
        bind(isOn: isOn)
    }

    /// Binds the switch two ways to `isOn`, replacing what `init(isOn:)` or an earlier call
    /// bound, on a subclass too.
    public func bind(isOn: UIBinding<Bool>) {
        bind(\UISwitch.isOn, to: isOn, sentBy: .valueChanged)
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
