#if os(iOS) || os(tvOS) || os(visionOS)
import Testing
import TestSupport
import UIKit
import UIObservationBinding

@MainActor
@Suite("UIKit bindings", .timeLimit(.minutes(1)))
struct UIKitBindingTests {
    @Test("a label follows its expression")
    func label() async {
        let model = FormModel()
        let label = UILabel(text: "\(model.count) items")
        #expect(label.text == "0 items")

        model.count = 2
        await wait { label.text == "2 items" }
        #expect(label.text == "2 items")
    }

    @Test("a text field writes edits back and follows the model")
    func textField() async {
        @UIBindable var model = FormModel()
        let field = UITextField(text: $model.query)

        field.text = "pie"
        field.sendActions(for: .editingChanged)
        #expect(model.query == "pie")

        model.query = "tart"
        await wait { field.text == "tart" }
        #expect(field.text == "tart")
    }

    @Test("a switch writes toggles back and follows the model")
    func toggle() async {
        @UIBindable var model = FormModel()
        let toggle = UISwitch(isOn: $model.isEnabled)
        #expect(!toggle.isOn)

        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)
        #expect(model.isEnabled)

        model.isEnabled = false
        await wait { !toggle.isOn }
        #expect(!toggle.isOn)
    }

    @Test("rebinding a control writes edits to the new binding only")
    func rebindingReplacesAction() {
        @UIBindable var first = FormModel()
        @UIBindable var second = FormModel()
        let field = UITextField(text: $first.query)
        field.bind(text: $second.query)

        field.text = "pie"
        field.sendActions(for: .editingChanged)

        #expect(first.query == "")
        #expect(second.query == "pie")
    }

    // The initializer forms its key path inside UIObservationBinding and this test forms an
    // equal one here; the write-back must be replaced all the same, in optimized builds too.
    @Test("rebinding a switch built by UISwitch(isOn:) moves its write-back to the new binding")
    func rebindingInitializedSwitchReplacesAction() {
        @UIBindable var first = FormModel()
        @UIBindable var second = FormModel()
        let toggle = UISwitch(isOn: $first.isEnabled)
        toggle.bind(\.isOn, to: $second.isEnabled, sentBy: .valueChanged)

        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)

        #expect(!first.isEnabled)
        #expect(second.isEnabled)
    }

    @Test("rebinding a control one way ends its earlier binding's write-back")
    func oneWayRebindEndsAction() {
        @UIBindable var first = FormModel()
        let second = FormModel()
        let field = UITextField(text: $first.query)
        field.bind(\.text, to: second.title)

        field.text = "typed"
        field.sendActions(for: .editingChanged)

        #expect(first.query == "")
    }

    @Test("a button runs its action and follows its title")
    func button() async {
        let model = FormModel()
        let button = UIButton(
            title: "Count \(model.count)",
            action: UIAction { _ in model.count += 1 }
        )

        button.sendActions(for: .primaryActionTriggered)
        #expect(model.count == 1)
        await wait { button.title(for: .normal) == "Count 1" }
        #expect(button.title(for: .normal) == "Count 1")
    }
}
#endif
