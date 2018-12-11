// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day11",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day11",
            dependencies: ["Shared"]),
    ]
)
