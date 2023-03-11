//
//  NSLayoutConstraint+Builder.swift
//
//  Created by Mark Malstrom on 3/6/23.
//
// h/t @johnsundell@mastodon.social:
// https://www.swiftbysundell.com/articles/building-dsls-in-swift/
//

import UIKit

public extension NSLayoutConstraint {
    @resultBuilder
    enum Builder {
        public static func buildBlock(_ constraints: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
            constraints.flatMap { $0 }
        }

        public static func buildExpression(_ constraint: NSLayoutConstraint) -> [NSLayoutConstraint] {
            return [constraint]
        }

        public static func buildOptional(_ constraint: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
            constraint ?? []
        }

        public static func buildEither(first constraint: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
            constraint
        }

        public static func buildEither(second constraint: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
            constraint
        }
    }
}

public func + <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> (NSLayoutAnchor<Anchor>, CGFloat) {
    return (lhs, rhs)
}

public func == <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalTo: lhs, constant: rhs)
}

public func == (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(equalToConstant: rhs)
}

public func <= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualToConstant: rhs)
}

public func >= (lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualToConstant: rhs)
}

public func - <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: CGFloat) -> (NSLayoutAnchor<Anchor>, CGFloat) {
    return (lhs, -rhs)
}

public func == <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs.0, constant: rhs.1)
}

public func == <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(equalTo: rhs)
}

public func >= <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs.0, constant: rhs.1)
}

public func >= <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(greaterThanOrEqualTo: rhs)
}

public func <= <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: (NSLayoutAnchor<Anchor>, CGFloat)) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs.0, constant: rhs.1)
}

public func <= <Anchor: AnyObject>(lhs: NSLayoutAnchor<Anchor>, rhs: NSLayoutAnchor<Anchor>) -> NSLayoutConstraint {
    lhs.constraint(lessThanOrEqualTo: rhs)
}

public extension UIView {
    func layout(@NSLayoutConstraint.Builder using closure: (UIView) -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
    }

    func frame(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.layout {
            if let width {
                $0.widthAnchor == width
            }

            if let height {
                $0.heightAnchor == height
            }
        }
    }

    func frame(size: CGFloat? = nil) {
        self.frame(width: size, height: size)
    }

    func frame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        self.layout {
            if let minWidth {
                $0.widthAnchor >= minWidth
            }

            if let maxWidth {
                $0.widthAnchor <= maxWidth
            }

            if let minHeight {
                $0.widthAnchor >= minHeight
            }

            if let maxHeight {
                $0.widthAnchor <= maxHeight
            }
        }
    }

    func padding(_ insets: UIEdgeInsets) {
        self.layoutMargins = insets
    }

    func padding(_ length: CGFloat) {
        self.padding(.init(top: length, left: length, bottom: length, right: length))
    }

    internal func padding(_ edges: NSDirectionalRectEdge = .all, _ length: CGFloat? = nil) {
        if let length = length {
            switch edges {
            case .all: self.padding(length)
            case .top: self.layoutMargins.top = length
            case .bottom: self.layoutMargins.bottom = length
            case .leading: self.layoutMargins.left = length
            case .trailing: self.layoutMargins.right = length
            default: break
            }
        }
    }

    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }

    static func spacer() -> UIView {
        let view = UIView(frame: .zero)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        return view
    }
}

public extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { allSubviews, subview -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap { $0.constraints })
        removedSubviews.forEach { $0.removeFromSuperview() }
    }

    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { addArrangedSubview($0) }
    }

    func replaceArrangedSubviews(with subviews: [UIView]) {
        self.removeAllArrangedSubviews()
        self.addArrangedSubviews(subviews)
    }
}
