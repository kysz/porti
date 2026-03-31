// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Porti",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "PortiCore",
            targets: ["PortiCore"]
        ),
        .executable(
            name: "porti-spike",
            targets: ["porti-spike"]
        ),
        .executable(
            name: "PortiApp",
            targets: ["PortiApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.3"),
    ],
    targets: [
        .target(
            name: "PortiCore"
        ),
        .executableTarget(
            name: "porti-spike",
            dependencies: ["PortiCore"]
        ),
        .executableTarget(
            name: "PortiApp",
            dependencies: [
                "PortiCore",
                .product(name: "Sparkle", package: "Sparkle"),
            ]
        ),
        .testTarget(
            name: "PortiCoreTests",
            dependencies: ["PortiCore"]
        ),
    ]
)
