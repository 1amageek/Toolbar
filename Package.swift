// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Toolbar",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "Toolbar",
            targets: ["Toolbar"]
        ),
    ],
    targets: [
        .target(
            name: "Toolbar"
        ),
        .testTarget(
            name: "ToolbarTests",
            dependencies: ["Toolbar"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
