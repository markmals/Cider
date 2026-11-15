import UIKit

extension UIImageView {
    public func contentMode(_ mode: UIView.ContentMode) -> Self {
        configure { $0.contentMode = mode }
    }
}
