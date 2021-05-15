// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v13)],
    products: [.library(name: "Cider", targets: ["Cider"])],
    dependencies: [],
    targets: [.target(name: "Cider", dependencies: [])]
)
