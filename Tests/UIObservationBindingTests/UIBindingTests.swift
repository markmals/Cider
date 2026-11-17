import TestSupport
import Testing
import UIObservationBinding

@MainActor
@Suite("UIBinding", .timeLimit(.minutes(1)))
struct UIBindingTests {
    @Test("writes through a struct field land in the model")
    func nestedWritesReachModel() {
        @UIBindable var model = FormModel()

        let showsDrafts = $model.filters.showsDrafts
        showsDrafts.wrappedValue = true

        #expect(model.filters.showsDrafts)
    }

    @Test("local @UIBinding state is observable")
    func localStateIsObservable() async {
        @UIBinding var isPlaying = false
        let counter = WriteCounter()
        counter.bind(\.text, to: isPlaying ? "Pause" : "Play")

        isPlaying = true
        await wait { counter.text == "Pause" }

        #expect(counter.text == "Pause")
    }

    @Test("a binding from $model doesn't retain what created it")
    func bindingRetainsOnlyTheModel() {
        weak var weakOwner: Owner?
        var binding: UIBinding<String>?
        do {
            let owner = Owner()
            binding = owner.$model.query
            weakOwner = owner
        }

        #expect(weakOwner == nil)
        binding?.wrappedValue = "still works"
        #expect(binding?.wrappedValue == "still works")
    }
}

@MainActor
private final class Owner {
    @UIBindable var model = FormModel()
}
