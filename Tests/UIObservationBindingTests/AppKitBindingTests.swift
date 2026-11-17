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
        @UIBindable var model = FormModel()
        let field = NSTextField(text: $model.query)

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
        @UIBindable var model = FormModel()
        let checkbox = NSButton(checkboxWithTitle: "Enabled", isOn: $model.isEnabled)
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
        @UIBindable var model = FormModel()
        let slider = NSSlider(value: 0, minValue: 0, maxValue: 10, target: nil, action: nil)
        slider.bind(\.doubleValue, to: $model.volume)
        #expect(slider.doubleValue == 5)

        slider.doubleValue = 8
        slider.sendAction(slider.action, to: slider.target)
        #expect(model.volume == 8)
    }

    @Test("rebinding a control one way ends its earlier binding's write-back")
    func oneWayRebindEndsAction() {
        @UIBindable var first = FormModel()
        let second = FormModel()
        let slider = NSSlider(value: 0, minValue: 0, maxValue: 10, target: nil, action: nil)
        slider.bind(\.doubleValue, to: $first.volume)
        slider.bind(\.doubleValue, to: second.volume)

        slider.doubleValue = 8
        slider.sendAction(slider.action, to: slider.target)

        #expect(first.volume == 5)
    }

    @Test("rebinding a text field one way ends its earlier binding's write-back")
    func oneWayRebindEndsTextWriteBack() {
        @UIBindable var first = FormModel()
        let second = FormModel()
        let field = NSTextField(text: $first.query)
        field.bind(\.stringValue, to: second.title)

        field.stringValue = "typed"
        NotificationCenter.default.post(name: NSControl.textDidChangeNotification, object: field)

        #expect(first.query == "")
    }

    @Test("a subclassed label rebinds through bind(label:)")
    func subclassedLabelRebinds() async {
        let first = FormModel()
        let second = FormModel()
        second.title = "second"
        let label = TitleField(label: first.title)
        label.bind(label: second.title)
        await settle()

        first.title = "stale"
        await settle()

        #expect(label.stringValue == "second")
    }

    @Test("a subclassed switch rebinds through bind(isOn:)")
    func subclassedSwitchRebinds() async {
        @UIBindable var first = FormModel()
        @UIBindable var second = FormModel()
        let toggle = FeatureSwitch(isOn: $first.isEnabled)
        toggle.bind(isOn: $second.isEnabled)
        await settle()

        first.isEnabled = true
        await settle()
        #expect(toggle.state == .off)

        toggle.state = .on
        toggle.sendAction(toggle.action, to: toggle.target)
        #expect(second.isEnabled)
    }
}

private final class TitleField: NSTextField {}

private final class FeatureSwitch: NSSwitch {}
#endif
