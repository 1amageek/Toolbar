// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toolbar",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "Toolbar",
            targets: ["Toolbar"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Toolbar",
            dependencies: []),
        .testTarget(
            name: "ToolbarTests",
            dependencies: ["Toolbar"]),
    ]
)
