// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v27), .macCatalyst(.v27), .macOS(.v27), .tvOS(.v27), .visionOS(.v27)],
    products: [
        .library(name: "Cider", targets: ["Cider"]),
        .library(name: "CocoaObservation", targets: ["CocoaObservation"]),
        .library(name: "Layout", targets: ["Layout"]),
    ],
    targets: [
        // Legacy UIKit helpers, frozen pending review; they only build in the Swift 5 language mode.
        .target(name: "Cider", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "CocoaObservation"),
        .testTarget(name: "CocoaObservationTests", dependencies: ["CocoaObservation"]),
        .target(name: "Layout"),
        .testTarget(name: "LayoutTests", dependencies: ["Layout"]),
    ]
)
