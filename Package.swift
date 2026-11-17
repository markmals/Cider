// swift-tools-version: 6.4

import PackageDescription

let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v27), .macCatalyst(.v27), .macOS(.v27), .tvOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Cider", targets: ["Cider"]),
        .library(name: "CocoaObservation", targets: ["CocoaObservation"]),
        .library(name: "Configurable", targets: ["Configurable"]),
        .library(name: "HexColor", targets: ["HexColor"]),
        .library(name: "LatestTask", targets: ["LatestTask"]),
        .library(name: "Layout", targets: ["Layout"]),
        .library(name: "UIObservationBinding", targets: ["UIObservationBinding"]),
    ],
    targets: [
        // Legacy UIKit helpers, frozen pending review; they only build in the Swift 5 language mode.
        .target(name: "Cider", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "CocoaObservation", swiftSettings: strict),
        .testTarget(
            name: "CocoaObservationTests",
            dependencies: ["CocoaObservation", "TestSupport"],
            swiftSettings: strict
        ),
        .target(name: "Configurable", swiftSettings: strict),
        .testTarget(
            name: "ConfigurableTests",
            dependencies: ["Configurable"],
            swiftSettings: strict
        ),
        .target(name: "HexColor", swiftSettings: strict),
        .testTarget(name: "HexColorTests", dependencies: ["HexColor"], swiftSettings: strict),
        .target(name: "LatestTask", swiftSettings: strict),
        .testTarget(
            name: "LatestTaskTests",
            dependencies: ["LatestTask", "TestSupport"],
            swiftSettings: strict
        ),
        .target(name: "Layout", swiftSettings: strict),
        .testTarget(name: "LayoutTests", dependencies: ["Layout"], swiftSettings: strict),
        .target(name: "TestSupport", path: "Tests/TestSupport", swiftSettings: strict),
        .target(name: "UIObservationBinding", swiftSettings: strict),
        .testTarget(
            name: "UIObservationBindingTests",
            dependencies: ["UIObservationBinding", "TestSupport"],
            swiftSettings: strict
        ),
    ],
    swiftLanguageModes: [.v6]
)
