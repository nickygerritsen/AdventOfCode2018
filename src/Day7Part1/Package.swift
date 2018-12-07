// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day7Part1",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day7Part1",
            dependencies: ["Shared"]),
    ]
)
