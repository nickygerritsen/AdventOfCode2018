// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day21",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day21",
            dependencies: ["Shared"]),
    ]
)
