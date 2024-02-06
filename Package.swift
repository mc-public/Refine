// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Refine",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Refine",
            targets: ["Refine"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Refine"),
        .testTarget(
            name: "RefineTests",
            dependencies: ["Refine"]),
    ]
)
