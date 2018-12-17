// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day17",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day17",
            dependencies: ["Shared"]),
    ]
)
