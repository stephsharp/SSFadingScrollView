// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSFadingScrollView",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "SSFadingScrollView",
            targets: ["SSFadingScrollView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SSFadingScrollView",
            dependencies: [],
            path: "SSFadingScrollView")
    ]
)
