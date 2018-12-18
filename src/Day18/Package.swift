// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day18",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day18",
            dependencies: ["Shared"]),
    ]
)
