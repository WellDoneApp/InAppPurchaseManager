// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InAppPurchaseManager",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "InAppPurchaseManager",
            targets: ["InAppPurchaseManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apphud/ApphudSDK", exact: "3.2.8"),
    ],
    targets: [
        .target(
            name: "InAppPurchaseManager",
            dependencies: ["ApphudSDK"],
            resources: [.process("Resources")]
        ),
    ]
)
