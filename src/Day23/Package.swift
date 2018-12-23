// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day23",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day23",
            dependencies: ["Shared"]),
    ]
)
