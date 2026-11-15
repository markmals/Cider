import UIKit

extension UIView {
    @_functionBuilder
    public struct ViewBuilder {
        public static func buildBlock(_ views: UIView...) -> [UIView] {
            views
        }
        
        public static func buildBlock(_ view: UIView) -> UIView {
            view
        }
        
        public static func buildBlock(_ view: UIView) -> [UIView] {
            [view]
        }
        
        public static func buildExpression(_ view: UIView) -> UIView {
            view
        }
        
        public static func buildExpression(_ view: [UIView]) -> [UIView] {
            view
        }
        
        public static func buildOptional(_ view: UIView?) -> UIView {
            view ?? UIView()
        }
        
//        public static func buildOptional(_ views: [UIView]?) -> [UIView] {
//            views ?? []
//        }
        
        public static func buildEither(first views: [UIView]) -> [UIView] {
            views
        }

        public static func buildEither(second views: [UIView]) -> [UIView] {
            views
        }
    }
    
    public func addSubview(@ViewBuilder _ content: () -> UIView) {
        let subview = content()
        addSubview(subview)
        subview.pin(to: self, insets: .zero)
    }
    
    public func backgroundColor(_ color: UIColor) -> Self {
        configure { $0.backgroundColor = color }
    }
}
