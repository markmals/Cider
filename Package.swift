// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Cider",
    platforms: [.iOS(.v13)],
    products: [.library(name: "Cider", targets: ["Cider"])],
    dependencies: [.package(url: "https://github.com/SnapKit/SnapKit", .branch("develop"))],
    targets: [.target(name: "Cider", dependencies: ["SnapKit"])]
)
