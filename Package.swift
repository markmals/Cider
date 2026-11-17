// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v14), .macCatalyst(.v14), .macOS(.v26), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(name: "Cider", targets: ["Cider"]),
        .library(name: "Layout", targets: ["Layout"]),
    ],
    targets: [
        // Legacy UIKit helpers, frozen pending review; they only build in the Swift 5 language mode.
        .target(name: "Cider", swiftSettings: [.swiftLanguageMode(.v5)]),
        .target(name: "Layout"),
        .testTarget(name: "LayoutTests", dependencies: ["Layout"]),
    ]
)
