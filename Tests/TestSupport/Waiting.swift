/// Spins the main actor until `condition` holds or about a second passes, so observation turns
/// and tasks can land. Callers assert afterward; a timeout fails there.
@MainActor
public func wait(until condition: () -> Bool) async {
    for _ in 0..<500 where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
}

/// Gives a pending observation turn or task the chance to (wrongly) land before asserting none
/// did.
@MainActor
public func settle() async {
    for _ in 0..<25 {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(2))
    }
}
