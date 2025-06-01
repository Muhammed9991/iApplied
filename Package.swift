// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IAppliedPackage",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Theme", targets: ["Theme"]),
        .library(name: "Jobs", targets: ["Jobs"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "AppDatabase", targets: ["AppDatabase"]),
        .library(name: "Root", targets: ["Root"]),
        .library(name: "CV", targets: ["CV"]),
    ],

    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.3.0"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb", from: "0.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.20.2"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.4"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Root",
            dependencies: [
                "AppDatabase",
                "Jobs",
                "CV",
                "Theme",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("package-list.json"),
            ]

        ),

        .target(name: "Theme"),

        .target(
            name: "CV",
            dependencies: [
                "AppDatabase",
                "Theme",
                "Models",
                .product(name: "SwiftUINavigation", package: "swift-navigation"),
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),

        .target(
            name: "Jobs",
            dependencies: [
                "AppDatabase",
                "Theme",
                "Models",
                .product(name: "SwiftUINavigation", package: "swift-navigation"),
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .testTarget(
            name: "JobsTest",
            dependencies: [
                "Jobs",
            ]
        ),
        .target(
            name: "Models",
            dependencies: [
                "Theme",
                .product(name: "SharingGRDB", package: "sharing-grdb"),
            ]
        ),

        .target(
            name: "AppDatabase",
            dependencies: [
                "Models",
                .product(name: "SharingGRDB", package: "sharing-grdb"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "AppStoreSnapshotTests",
            dependencies: [
                "AppDatabase",
                "Theme",
                "Models",
                "Jobs",
                "CV",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SharingGRDB", package: "sharing-grdb"),
            ],
            exclude: [
                "__Snapshots__",
            ],
        ),
    ]
)
