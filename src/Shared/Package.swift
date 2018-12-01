// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Shared",
    products: [
        .library(
            name: "Shared",
            targets: ["Shared"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Shared",
            dependencies: []),
    ]
)
