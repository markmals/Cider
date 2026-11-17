import AppKit
import CocoaObservation
import Observation

@MainActor
@Observable
final class ProbeModel {
    var value = 0
    var unrelated = 0
    var showsDetail = false
    var detail = 0
}

final class ProbeController: ObservingViewController {
    let model: ProbeModel
    var read: (ProbeModel) -> Int = { $0.value }
    var afterRender: ((ProbeController) -> Void)?
    private(set) var renders: [Int] = []

    init(model: ProbeModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = NSView()
    }

    override func updateProperties() {
        super.updateProperties()
        renders.append(read(model))
        afterRender?(self)
    }
}

final class ProbeView: ObservingView {
    let model: ProbeModel
    private(set) var renders: [Int] = []

    init(model: ProbeModel) {
        self.model = model
        super.init(frame: .zero)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    override func updateProperties() {
        super.updateProperties()
        renders.append(model.value)
    }
}

/// Spins the main actor until `condition` holds or about a second elapses, so the async
/// `Observations` turn can land. Callers assert afterward; a timeout fails there.
@MainActor
func wait(until condition: () -> Bool) async {
    for _ in 0..<500 where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
}

/// Gives a pending observation turn the chance to (wrongly) land before asserting none did.
@MainActor
func settle() async {
    for _ in 0..<25 {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
}

@MainActor
func makeWindow() -> NSWindow {
    NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
        styleMask: [.titled],
        backing: .buffered,
        defer: true
    )
}
