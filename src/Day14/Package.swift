// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day14",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day14",
            dependencies: ["Shared"]),
    ]
)
