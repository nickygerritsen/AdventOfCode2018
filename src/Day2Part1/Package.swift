// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Day2Part1",
        dependencies: [
            .package(path: "../Shared")
        ],
    targets: [
        .target(
            name: "Day2Part1",
            dependencies: ["Shared"]),
    ]
)
