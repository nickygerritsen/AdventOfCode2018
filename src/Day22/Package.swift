// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day22",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day22",
            dependencies: ["Shared"]),
    ]
)
