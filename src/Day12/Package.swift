// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day12",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day12",
            dependencies: ["Shared"]),
    ]
)
