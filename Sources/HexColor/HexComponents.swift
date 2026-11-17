/// The sRGB channels of a 24-bit `0xRRGGBB` value, each in `0...1`.
struct HexComponents {
    let red: Double
    let green: Double
    let blue: Double

    init(_ hex: UInt32) {
        precondition(hex <= 0xFF_FFFF, "Expected a 24-bit 0xRRGGBB value; pass alpha separately")
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }
}
