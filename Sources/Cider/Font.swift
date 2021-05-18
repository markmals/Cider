import UIKit

extension UIFont {
    public func bolded() -> UIFont {
        .boldSystemFont(ofSize: pointSize)
    }
    
    public func italicized() -> UIFont {
        .italicSystemFont(ofSize: pointSize)
    }
    
    public func weighted(as weight: Weight) -> UIFont {
        .systemFont(ofSize: pointSize, weight: weight)
    }
    
    public func monospaced(as weight: Weight) -> UIFont {
        .monospacedSystemFont(ofSize: pointSize, weight: weight)
    }
    
    public func monospaced() -> UIFont {
        monospaced(as: weight)
    }
    
    public func monospacedDigit(as weight: Weight) -> UIFont {
        .monospacedDigitSystemFont(ofSize: pointSize, weight: weight)
    }
    
    public func monospacedDigit() -> UIFont {
        monospacedDigit(as: weight)
    }
    
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }
    
    private var traits: [UIFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
            ?? [:]
    }
}

extension String {
    public func underlined() -> NSAttributedString {
        .init(
            string: self,
            attributes: [.underlineStyle: NSUnderlineStyle.single]
        )
    }
}
