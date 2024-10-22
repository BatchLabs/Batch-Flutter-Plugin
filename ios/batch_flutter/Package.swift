// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "batch_flutter",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "batch-flutter", targets: ["batch_flutter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/BatchLabs/Batch-iOS-SDK", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "batch_flutter",
            dependencies: [
                .product(name: "Batch", package: "Batch-iOS-SDK"),
            ]
        ),
        .testTarget(
            name: "batch_flutter_test",
            dependencies: ["batch_flutter"]
        ),
    ]
)
