// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "latest-resource-ability",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "LatestResourceAbility",
            targets: ["LatestResourceAbility"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/miejoy/ability.git", branch: "main"),
        .package(url: "https://github.com/miejoy/logger.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "LatestResourceAbility",
            dependencies: [
                .product(name: "Ability", package: "ability"),
                .product(name: "Logger", package: "logger"),
            ]
        ),
        .testTarget(
            name: "LatestResourceAbilityTests",
            dependencies: ["LatestResourceAbility"],
            resources: [
                .copy("latest-resource")
            ]
        ),
    ]
)
