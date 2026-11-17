import Foundation
import TestSupport
import Testing
import UIObservationBinding

@MainActor
@Suite("bind(_:to:)", .timeLimit(.minutes(1)))
struct BindingTests {
    @Test("sets the value immediately, then follows the model")
    func followsModel() async {
        let model = FormModel()
        let counter = WriteCounter()

        counter.bind(\.text, to: "\(model.count) items")
        #expect(counter.text == "0 items")

        model.count = 3
        await wait { counter.text == "3 items" }
        #expect(counter.text == "3 items")
    }

    @Test("coalesces synchronous changes and skips equal values")
    func coalescesAndSkipsEqual() async {
        let model = FormModel()
        let counter = WriteCounter()
        counter.bind(\.text, to: model.title.uppercased())
        #expect(counter.writes == 1)

        model.title = "a"
        model.title = "b"
        await wait { counter.text == "B" }
        model.title = "b"
        await settle()

        #expect(counter.writes == 2)
    }

    @Test("binding a key path again replaces the earlier binding")
    func rebindingReplaces() async {
        let first = FormModel()
        let second = FormModel()
        let counter = WriteCounter()
        counter.bind(\.text, to: first.title)
        counter.bind(\.text, to: second.title)

        first.title = "stale"
        second.title = "fresh"
        await wait { counter.text == "fresh" }
        await settle()

        #expect(counter.text == "fresh")
    }

    @Test("a replaced binding doesn't apply a change that was pending when it was replaced")
    func replacedBindingIgnoresPendingChange() async {
        let first = FormModel()
        let second = FormModel()
        second.title = "fresh"
        let counter = WriteCounter()
        counter.bind(\.text, to: first.title)
        await settle()

        first.title = "stale"
        counter.bind(\.text, to: second.title)
        await settle()

        // The stale value must never land, whichever of the two bindings' turns runs first.
        #expect(counter.text == "fresh")
        #expect(counter.writes == 2)
    }

    @Test("doesn't keep its object alive, and ends when the object goes")
    func objectLifetime() async {
        let model = FormModel()
        weak var weakCounter: WriteCounter?
        autoreleasepool {
            let counter = WriteCounter()
            counter.bind(\.text, to: model.title)
            counter.bind(to: model.count) { counter, count in counter.text = "\(count)" }
            weakCounter = counter
        }
        #expect(weakCounter == nil)

        model.title = "after"
        model.count = 1
        await settle()
    }
}
