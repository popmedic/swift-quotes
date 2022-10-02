// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Quotes",
    dependencies: [],
    targets: [
        .target(name: "Quotes"),
        .executableTarget(
            name: "quote",
            dependencies: [
                "Quotes"
            ]
        ),
        .testTarget(
            name: "QuotesTests",
            dependencies: [
                "Quotes"
            ]
        )
    ]
)
