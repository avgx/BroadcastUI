// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BroadcastUI",
    defaultLocalization: "en",
    platforms: [
      .iOS(.v15),
      .tvOS(.v15),
      .visionOS(.v1),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BroadcastUI",
            targets: ["BroadcastUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/shogo4405/HaishinKit.swift", from: "1.9.5"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BroadcastUI",
            dependencies: [
                .product(name: "HaishinKit", package: "HaishinKit.swift"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "BroadcastUITests",
            dependencies: ["BroadcastUI"]
        ),
    ]
)
