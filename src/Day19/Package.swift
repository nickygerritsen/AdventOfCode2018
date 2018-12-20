// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day19",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day19",
            dependencies: ["Shared"]),
    ]
)
