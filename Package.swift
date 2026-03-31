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
            dependencies: ["PortiCore"]
        ),
        .testTarget(
            name: "PortiCoreTests",
            dependencies: ["PortiCore"]
        ),
    ]
)
