// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "auto-confuse",
//    products: [
//        .library(name: "auto-confuse-library", targets: ["CommandLineKit","Rainbow"]),
//    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/IngmarStein/CommandLineKit.git", from: "2.3.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "objc"),
        .target(
            name: "auto-confuse",
            dependencies: ["CommandLineKit","Rainbow","objc"]),
        .testTarget(
            name: "auto-confuseTests",
            dependencies: ["auto-confuse"]),
    ]
)