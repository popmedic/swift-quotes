// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let libName = "Quotes"
let exeName = "quote"

let package = Package(
    name: "Quotes",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "\(libName)",
            targets: ["\(libName)"]
        ),
        .executable(
            name: "\(exeName)",
            targets: ["\(exeName)"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-tools-support-core.git",
            from: "0.0.1"
        )
    ],
    targets: [
        .target(name: "\(libName)"),
        .executableTarget(
            name: "\(exeName)",
            dependencies: [
                Target.Dependency(stringLiteral: "\(libName)"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core")
            ]
        ),
        .testTarget(
            name: "\(libName)Tests",
            dependencies: [
                Target.Dependency(stringLiteral: "\(libName)")
            ]
        )
    ]
)
