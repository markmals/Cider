import UIKit

public protocol Renderable: UIViewController {
    func render(subview: () -> UIView)
}

extension Renderable {
    public func render(subview: () -> UIView) {
        self.subview = subview()
        self.view.addSubview(self.subview!)
        self.subview?.pin(to: self.view, insets: .zero)
    }
    
    var subview: UIView? {
        get { objc_getAssociatedObject(self, &renderableKey) as? UIView }
        set { objc_setAssociatedObject(self, &renderableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

private var renderableKey = 1
