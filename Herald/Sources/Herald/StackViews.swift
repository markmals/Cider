import UIKit
import Combine

extension UIStackView {
    public convenience init(axis: NSLayoutConstraint.Axis,
                     alignment: UIStackView.Alignment = .fill,
                     isBaselineRelativeArrangement: Bool = false,
                     distribution: UIStackView.Distribution = .fill,
                     isLayoutMarginsRelativeArrangement: Bool = false,
                     spacing: CGFloat = 0,
                     @UIView.ViewBuilder arrangedSubviewsBuilder: () -> [UIView]) {
        
        self.init(arrangedSubviews: arrangedSubviewsBuilder())

        self.alignment = alignment
        self.axis = axis
        self.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        self.distribution = distribution
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        self.spacing = spacing
    }
    
    public func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    public func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }
    
    public func replaceArrangedSubviews(@UIView.ViewBuilder arrangedSubviewsBuilder: () -> [UIView]) {
        removeAllArrangedSubviews()
        addArrangedSubviews(arrangedSubviewsBuilder())
    }
    
    public func replaceArrangedSubviews(with subviews: [UIView]) {
        removeAllArrangedSubviews()
        addArrangedSubviews(subviews)
    }
    
    public func render<P: Publisher>(
        onValue valuePublisher: P,
        @UIView.ViewBuilder content: @escaping (P.Output) -> [UIView]
    ) -> AnyCancellable where P.Failure == Never {
        valuePublisher
            .sink { [weak self] value in
                self?.replaceArrangedSubviews(with: content(value))
            }
    }
}

extension UIView {
    public static func spacer() -> UIView {
        UIView().configure {
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
        }
    }
}
