// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day10",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day10",
            dependencies: ["Shared"]),
    ]
)
