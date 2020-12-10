// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toolbar",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Toolbar",
            targets: ["Toolbar"]),
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
