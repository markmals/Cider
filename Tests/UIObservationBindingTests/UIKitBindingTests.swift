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
        let model = FormModel()
        let field = UITextField(text: model, \.query)

        field.text = "pie"
        field.sendActions(for: .editingChanged)
        #expect(model.query == "pie")

        model.query = "tart"
        await wait { field.text == "tart" }
        #expect(field.text == "tart")
    }

    @Test("a switch writes toggles back and follows the model")
    func toggle() async {
        let model = FormModel()
        let toggle = UISwitch(isOn: model, \.isEnabled)
        #expect(!toggle.isOn)

        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)
        #expect(model.isEnabled)

        model.isEnabled = false
        await wait { !toggle.isOn }
        #expect(!toggle.isOn)
    }

    @Test("rebinding a control writes edits to the new model only")
    func rebindingReplacesAction() {
        let first = FormModel()
        let second = FormModel()
        let field = UITextField(text: first, \.query)
        field.bindText(to: second, \.query)

        field.text = "pie"
        field.sendActions(for: .editingChanged)

        #expect(first.query == "")
        #expect(second.query == "pie")
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
