// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Herald",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Herald", targets: ["Herald"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Herald", dependencies: []),
        .testTarget(name: "HeraldTests", dependencies: ["Herald"])
    ]
)
