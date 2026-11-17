#if os(macOS)
import AppKit

extension ObservationBindable where Self: NSControl {
    /// Two-way binding: keeps `keyPath` equal to `binding`, and writes the control's value back
    /// through it whenever the control sends its action. This takes over the control's `target`
    /// and `action`.
    ///
    /// ```swift
    /// slider.bind(\.doubleValue, to: $model.volume)
    /// ```
    @MainActor
    public func bind<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<Self, Value>,
        to binding: UIBinding<Value>
    ) {
        bind(keyPath, to: binding.wrappedValue)
        let control = WeakReference(self)
        setAction {
            guard let control = control.value else { return }
            binding.wrappedValue = control[keyPath: keyPath]
        }
    }

    @MainActor
    fileprivate func bindState(
        _ state: ReferenceWritableKeyPath<Self, NSControl.StateValue>,
        to isOn: UIBinding<Bool>
    ) {
        bind(state, to: isOn.wrappedValue ? .on : .off)
        let control = WeakReference(self)
        setAction {
            guard let control = control.value else { return }
            isOn.wrappedValue = control[keyPath: state] == .on
        }
    }

    @MainActor
    fileprivate func setAction(_ handler: @escaping @MainActor () -> Void) {
        let target = ActionTarget(handler)
        self.target = target
        action = #selector(ActionTarget.performAction(_:))
        bindingStore.set(target, for: .named("action"))
    }
}

/// An `NSControl` target that runs a closure; controls hold their target weakly, so the
/// binding store keeps it alive.
@MainActor
private final class ActionTarget: NSObject {
    private let handler: @MainActor () -> Void

    init(_ handler: @escaping @MainActor () -> Void) {
        self.handler = handler
    }

    // Not perform(_:): #selector would resolve that to NSObject's performSelector:.
    @objc func performAction(_ sender: Any?) {
        handler()
    }
}

extension NSTextField {
    /// A non-editable label whose text tracks `label`: `NSTextField(label: "\(cart.count) items")`.
    public convenience init(label: @escaping @autoclosure @MainActor () -> String) {
        self.init(labelWithString: "")
        // Through the concrete type: a key path rooted in an initializer's dynamic Self crashes
        // at runtime ("could not demangle keypath type").
        (self as NSTextField).bind(\.stringValue, to: label())
    }

    /// An editable field bound two ways to `text`; edits write back as the user types.
    public convenience init(text: UIBinding<String>) {
        self.init(string: "")
        bind(text: text)
    }

    /// Binds the text two ways to `text`, without touching the field's `target`, `action` or
    /// `delegate`. Changes from the binding wait while the user is composing marked text, such
    /// as an unfinished Japanese word.
    public func bind(text: UIBinding<String>) {
        let current: @MainActor () -> String = { text.wrappedValue }
        sink(.value(\NSTextField.stringValue), current) { field, newText in
            let isComposing = (field.currentEditor() as? NSTextView)?.hasMarkedText() ?? false
            guard !isComposing, field.stringValue != newText else { return }
            field.stringValue = newText
        }
        let field = WeakReference(self)
        let writeBack: @MainActor () -> Void = {
            guard let field = field.value else { return }
            text.wrappedValue = field.stringValue
        }
        let changes = NotificationCenter.default.addObserver(
            forName: NSControl.textDidChangeNotification,
            object: self,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated(writeBack)
        }
        bindingStore.set(NotificationObservation(changes), for: .named("textChanges"))
    }
}

/// Removes a block-based notification observer when released; the notification center would
/// otherwise keep calling it.
private final class NotificationObservation {
    private let observer: any NSObjectProtocol

    init(_ observer: any NSObjectProtocol) {
        self.observer = observer
    }

    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}

extension NSButton {
    /// A push button whose title tracks `title`.
    public convenience init(
        title: @escaping @autoclosure @MainActor () -> String,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(title: "", target: nil, action: nil)
        (self as NSButton).bind(\.title, to: title())
        setAction(action)
    }

    /// A checkbox bound two ways to `isOn`.
    public convenience init(checkboxWithTitle title: String, isOn: UIBinding<Bool>) {
        self.init(checkboxWithTitle: title, target: nil, action: nil)
        (self as NSButton).bindState(\.state, to: isOn)
    }
}

extension NSSwitch {
    /// A switch bound two ways to `isOn`.
    public convenience init(isOn: UIBinding<Bool>) {
        self.init(frame: .zero)
        (self as NSSwitch).bindState(\.state, to: isOn)
    }
}
#endif
