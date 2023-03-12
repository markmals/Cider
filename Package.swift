// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v14), .macCatalyst(.v14), .watchOS(.v7), .tvOS(.v14)],
    products: [.library(name: "Cider", targets: ["Cider"])],
    targets: [.target(name: "Cider", dependencies: [])]
)
