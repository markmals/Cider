#if os(macOS)
import AppKit
import Testing
import TestSupport
import UIObservationBinding

@MainActor
@Suite("AppKit bindings", .timeLimit(.minutes(1)))
struct AppKitBindingTests {
    init() {
        // Controls send their actions through NSApp, which a test process doesn't create.
        _ = NSApplication.shared
    }

    @Test("a label follows its expression")
    func label() async {
        let model = FormModel()
        let label = NSTextField(label: "\(model.count) items")
        #expect(label.stringValue == "0 items")

        model.count = 2
        await wait { label.stringValue == "2 items" }
        #expect(label.stringValue == "2 items")
    }

    @Test("a text field writes edits back and follows the model")
    func textField() async {
        let model = FormModel()
        let field = NSTextField(text: model, \.query)

        field.stringValue = "pie"
        NotificationCenter.default.post(name: NSControl.textDidChangeNotification, object: field)
        await wait { model.query == "pie" }
        #expect(model.query == "pie")

        model.query = "tart"
        await wait { field.stringValue == "tart" }
        #expect(field.stringValue == "tart")
    }

    @Test("a checkbox writes clicks back and follows the model")
    func checkbox() async {
        let model = FormModel()
        let checkbox = NSButton(checkboxWithTitle: "Enabled", isOn: model, \.isEnabled)
        #expect(checkbox.state == .off)

        checkbox.performClick(nil)
        #expect(model.isEnabled)

        model.isEnabled = false
        await wait { checkbox.state == .off }
        #expect(checkbox.state == .off)
    }

    @Test("a button runs its action and follows its title")
    func button() async {
        let model = FormModel()
        let button = NSButton(title: "Count \(model.count)") { model.count += 1 }

        button.performClick(nil)
        #expect(model.count == 1)
        await wait { button.title == "Count 1" }
        #expect(button.title == "Count 1")
    }

    @Test("a two-way slider writes its value back")
    func slider() async {
        let model = SliderModel()
        let slider = NSSlider(value: 0, minValue: 0, maxValue: 10, target: nil, action: nil)
        slider.bind(\.doubleValue, to: model, \.volume)
        #expect(slider.doubleValue == 5)

        slider.doubleValue = 8
        slider.sendAction(slider.action, to: slider.target)
        #expect(model.volume == 8)
    }
}

@MainActor
@Observable
private final class SliderModel {
    var volume = 5.0
}
#endif
