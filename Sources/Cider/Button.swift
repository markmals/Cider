import UIKit

extension UIButton {
    private final class Action: NSObject {
        private let _action: () -> Void

        init(_ action: @escaping () -> Void) {
            _action = action
            super.init()
        }

        @objc func selector() { _action() }
    }

    
    public convenience init<S>(_ title: S, action: @escaping () -> Void) where S : StringProtocol {
        self.init()
        setTitle(String(title), for: .normal)
        let fire = Action(action)
        addTarget(fire, action: #selector(fire.selector), for: .touchUpInside)
    }
    
    func add(action: @escaping () -> Void, for controlEvents: UIControl.Event? = nil) {
        let fire = Action(action)
        addTarget(fire, action: #selector(fire.selector), for: controlEvents ?? .touchUpInside)
    }
}
