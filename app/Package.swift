// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Vid2Tabletop",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Vid2Tabletop",
            targets: ["Vid2Tabletop"]),
    ],
    dependencies: [
        .package(url: "https://github.com/youtube/youtube-ios-player-helper.git", from: "1.0.4"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"), // For efficient data processing
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"), // For optimized data structures
        .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.3.1"),
    ],
    targets: [
        .target(
            name: "Vid2Tabletop",
            dependencies: [
                .product(name: "YouTubeiOSPlayerHelper", package: "youtube-ios-player-helper"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "PythonKit", package: "PythonKit")
            ],
            resources: [
                .process("Resources"),
                .copy("Models") // Directory containing YOLO models
            ]
        ),
        .testTarget(
            name: "Vid2TabletopTests",
            dependencies: ["Vid2Tabletop"])
    ]
) 