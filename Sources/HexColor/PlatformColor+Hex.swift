#if os(macOS)
import AppKit

extension NSColor {
    /// An sRGB color from a 24-bit `0xRRGGBB` value: `NSColor(hex: 0x1E90FF)`.
    public convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let components = HexComponents(hex)
        self.init(
            srgbRed: components.red,
            green: components.green,
            blue: components.blue,
            alpha: alpha
        )
    }
}
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit

extension UIColor {
    /// An sRGB color from a 24-bit `0xRRGGBB` value: `UIColor(hex: 0x1E90FF)`.
    public convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let components = HexComponents(hex)
        self.init(
            red: components.red,
            green: components.green,
            blue: components.blue,
            alpha: alpha
        )
    }
}
#endif
