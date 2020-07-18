// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BarebonesServer",
    platforms: [
        .macOS("10.15"),
        .iOS("13.6"),
    ],
    products: [
        .library(name: "BarebonesServer", targets: ["BarebonesServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/alexaubry/HTMLString", .upToNextMajor(from: "4.0.2")),
        .package(url: "https://github.com/mxcl/PromiseKit", .upToNextMajor(from: "6.13.2")),
        .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/envoy/Embassy", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/envoy/Ambassador", .upToNextMajor(from: "4.0.5")),
    ],
    targets: [
        .target(name: "BarebonesServer", dependencies: [
            "HTMLString",
            "Files",
            "PromiseKit",
            "Embassy",
            "Ambassador",
        ]),
    ]
)
