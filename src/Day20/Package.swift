// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day20",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day20",
            dependencies: ["Shared"]),
    ]
)
