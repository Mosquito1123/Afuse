// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "auto-confuse",
    products: [
        .executable(name: "auto-confuse-executable", targets: ["auto-confuse-executable"]),
        .library(name: "confuse", targets: ["confuse"]),
        .library(name: "objc_confuse", targets: ["objc_confuse"]),

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/IngmarStein/CommandLineKit.git", from: "2.3.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.0.0"),
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.5.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "objc_confuse"),
        .target(
            name: "confuse",
            dependencies: ["objc_confuse","XcodeProj"]),
        .target(
            name: "auto-confuse-executable",
            dependencies: ["CommandLineKit","Rainbow","confuse","SwiftShell","XcodeProj"]),
        .testTarget(
            name: "auto-confuseTests",
            dependencies: ["confuse"]),
    ]
)
