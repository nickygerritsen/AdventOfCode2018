// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day13",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day13",
            dependencies: ["Shared"]),
    ]
)
