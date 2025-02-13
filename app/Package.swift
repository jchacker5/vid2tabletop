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
    dependencies: [],
    targets: [
        .target(
            name: "Vid2Tabletop",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
) 