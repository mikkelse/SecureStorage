// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SecureStorage",
    products: [
        .library(
            name: "SecureStorage",
            targets: ["SecureStorage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SecureStorage",
            dependencies: []),
        .testTarget(
            name: "SecureStorageTests",
            dependencies: ["SecureStorage"]),
    ]
)
