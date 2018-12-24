// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day24",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day24",
            dependencies: ["Shared"]),
    ]
)
