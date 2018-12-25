// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day25",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day25",
            dependencies: ["Shared"]),
    ]
)
