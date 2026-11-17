#if os(iOS) || os(tvOS) || os(visionOS)
import Observation
import UIKit

extension ObservationBindable where Self: UIControl {
    /// Two-way binding: keeps `keyPath` equal to `model[keyPath: modelKeyPath]`, and writes the
    /// control's value back to the model whenever the control sends `event`.
    ///
    /// ```swift
    /// slider.bind(\.value, to: model, \.volume, sentBy: .valueChanged)
    /// ```
    @MainActor
    public func bind<Model: Observable & AnyObject, Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to model: Model,
        _ modelKeyPath: ReferenceWritableKeyPath<Model, Value>,
        sentBy event: UIControl.Event
    ) {
        bind(keyPath, to: model[keyPath: modelKeyPath])
        let control = WeakReference(self)
        addAction(
            UIAction(identifier: .binding(keyPath)) { _ in
                guard let control = control.value else { return }
                model[keyPath: modelKeyPath] = control[keyPath: keyPath]
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
    /// A text field bound two ways to `model[keyPath: keyPath]`; edits write back as the user
    /// types.
    public convenience init<Model: Observable & AnyObject>(
        text model: Model,
        _ keyPath: ReferenceWritableKeyPath<Model, String>
    ) {
        self.init(frame: .zero)
        bindText(to: model, keyPath)
    }

    /// Binds the text two ways to `model[keyPath: keyPath]`. Model changes wait while the user
    /// is composing marked text, such as an unfinished Japanese word.
    public func bindText<Model: Observable & AnyObject>(
        to model: Model,
        _ keyPath: ReferenceWritableKeyPath<Model, String>
    ) {
        let current: @MainActor () -> String = { model[keyPath: keyPath] }
        sink(.value(\UITextField.text), current) { field, text in
            guard field.markedTextRange == nil, field.text != text else { return }
            field.text = text
        }
        let field = WeakReference(self)
        addAction(
            UIAction(identifier: .binding(\UITextField.text)) { _ in
                guard let field = field.value else { return }
                model[keyPath: keyPath] = field.text ?? ""
            },
            for: .editingChanged
        )
    }
}

#if !os(tvOS)
extension UISwitch {
    /// A switch bound two ways to `model[keyPath: keyPath]`.
    public convenience init<Model: Observable & AnyObject>(
        isOn model: Model,
        _ keyPath: ReferenceWritableKeyPath<Model, Bool>
    ) {
        self.init(frame: .zero)
        (self as UISwitch).bind(\.isOn, to: model, keyPath, sentBy: .valueChanged)
    }
}

extension UISearchBar {
    /// Binds the search text two ways to `model[keyPath: keyPath]`, through `searchTextField`.
    public func bindText<Model: Observable & AnyObject>(
        to model: Model,
        _ keyPath: ReferenceWritableKeyPath<Model, String>
    ) {
        searchTextField.bindText(to: model, keyPath)
    }
}
#endif
#endif
