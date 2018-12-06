// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day6Part1",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day6Part1",
            dependencies: ["Shared"]),
    ]
)
