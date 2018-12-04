// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Day4Part2",
    dependencies: [
        .package(path: "../Shared")
    ],
    targets: [
        .target(
            name: "Day4Part2",
            dependencies: ["Shared"]),
    ]
)
