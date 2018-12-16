// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day16",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day16",
            dependencies: ["Shared"]),
    ]
)
