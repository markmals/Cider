import HexColor
import SwiftUI
import Testing

#if os(macOS)
import AppKit

private typealias PlatformColor = NSColor
#else
import UIKit

private typealias PlatformColor = UIColor
#endif

@MainActor
@Suite("HexColor")
struct HexColorTests {
    private func srgbComponents(of color: PlatformColor) -> [Double] {
        #if os(macOS)
        let color = color.usingColorSpace(.sRGB)!
        return [
            color.redComponent, color.greenComponent, color.blueComponent, color.alphaComponent,
        ]
        #else
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
        #endif
    }

    private func expectComponents(_ actual: [Double], _ expected: [Double]) {
        #expect(zip(actual, expected).allSatisfy { abs($0 - $1) < 0.0005 }, "\(actual)")
    }

    @Test("reads 0xRRGGBB as red, green, then blue")
    func platformColorChannelOrder() {
        expectComponents(
            srgbComponents(of: PlatformColor(hex: 0x1E90FF, alpha: 0.5)),
            [30 / 255, 144 / 255, 1, 0.5]
        )
    }

    @Test("Color(hex:) matches the platform color")
    func swiftUIColorChannelOrder() {
        expectComponents(
            srgbComponents(of: PlatformColor(Color(hex: 0x1E90FF, opacity: 0.25))),
            [30 / 255, 144 / 255, 1, 0.25]
        )
    }

    #if os(macOS)
    @Test("rejects values wider than 24 bits instead of dropping a channel")
    func rejectsAlphaInHex() async {
        await #expect(processExitsWith: .failure) {
            _ = Color(hex: 0x1E90_FF80)
        }
    }
    #endif
}
