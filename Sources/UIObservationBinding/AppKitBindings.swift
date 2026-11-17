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
        let control = WeakReference(self)
        let target = takeOverAction {
            guard let control = control.value else { return }
            binding.wrappedValue = control[keyPath: keyPath]
        }
        bind(keyPath, to: { binding.wrappedValue }, writeBack: target)
    }

    @MainActor
    fileprivate func bindState(
        _ state: ReferenceWritableKeyPath<Self, NSControl.StateValue>,
        to isOn: UIBinding<Bool>
    ) {
        let control = WeakReference(self)
        let target = takeOverAction {
            guard let control = control.value else { return }
            isOn.wrappedValue = control[keyPath: state] == .on
        }
        bind(state, to: { isOn.wrappedValue ? .on : .off }, writeBack: target)
    }

    /// Points the control's `target` and `action` at `handler`. The control holds its target
    /// weakly: the caller keeps the returned target alive, and releasing it ends the action.
    @MainActor
    fileprivate func takeOverAction(_ handler: @escaping @MainActor () -> Void) -> ActionTarget {
        let target = ActionTarget(handler)
        self.target = target
        action = #selector(ActionTarget.performAction(_:))
        return target
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

    // Not perform(_:): #selector would resolve that to NSObject's performSelector:. Prefixed in
    // Objective-C because the control keeps this action after a one-way rebind releases its
    // target, and AppKit offers a targetless action to the responder chain.
    @objc(cider_performAction:) func performAction(_ sender: Any?) {
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
        let weakField = WeakReference(self)
        let writeBack: @MainActor () -> Void = {
            guard let field = weakField.value else { return }
            text.wrappedValue = field.stringValue
        }
        let changes = NotificationCenter.default.addObserver(
            forName: NSControl.textDidChangeNotification,
            object: self,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated(writeBack)
        }
        let current: @MainActor () -> String = { text.wrappedValue }
        sink(
            .value(\NSTextField.stringValue),
            current,
            writeBack: NotificationObservation(changes)
        ) { field, newText in
            let isComposing = (field.currentEditor() as? NSTextView)?.hasMarkedText() ?? false
            guard !isComposing, field.stringValue != newText else { return }
            field.stringValue = newText
        }
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
        bindingStore.add(takeOverAction(action))
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
