// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day15",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day15",
            dependencies: ["Shared"]),
    ]
)
