import SwiftUI

extension Color {
    /// An sRGB color from a 24-bit `0xRRGGBB` value: `Color(hex: 0x1E90FF)`.
    public init(hex: UInt32, opacity: Double = 1) {
        let components = HexComponents(hex)
        self.init(
            .sRGB,
            red: components.red,
            green: components.green,
            blue: components.blue,
            opacity: opacity
        )
    }
}
