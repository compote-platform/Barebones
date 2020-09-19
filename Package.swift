// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let specification = Target.target(name: "BarebonesSpecification", dependencies: [
    .byName(name: "HTMLString"),
], path: "Sources/Specification")
let client = Target.target(name: "BarebonesAPIClient", dependencies: [
    .byName(name: specification.name),
    .byName(name: "PromiseKit"),
    .byName(name: "Curl"),
    .byName(name: "Shell"),
    .byName(name: "Signature"),
], path: "Sources/API/Client")
let core = Target.target(name: "BarebonesCore", dependencies: [
    .byName(name: specification.name),
    .byName(name: "Journal"),
    .byName(name: "Stopwatch"),

    .byName(name: "PromiseKit"),
    .byName(name: "Embassy"),
    .byName(name: "Ambassador"),
], path: "Sources/Core")
let plugins = Target.target(name: "BarebonesPlugins", dependencies: [
    .byName(name: core.name),
    .byName(name: "MemoryAware"),
    .byName(name: "PromiseKit"),
], path: "Sources/Plugins")
let server = Target.target(name: "BarebonesServer", dependencies: [
    .byName(name: core.name),
    .byName(name: plugins.name),
    .byName(name: "Files"),
    .byName(name: "PromiseKit"),
], path: "Sources/Server")
let api = Target.target(name: "BarebonesAPI", dependencies: [
    .byName(name: specification.name),
    .byName(name: core.name),
    .byName(name: plugins.name),
    .byName(name: server.name),
], path: "Sources/API/Server")
let barebones = Target.target(name: "Barebones", dependencies: [
    .byName(name: specification.name),
    .byName(name: client.name),
    .byName(name: core.name),
    .byName(name: plugins.name),
    .byName(name: server.name),
    .byName(name: api.name),
], path: "Sources/Barebones")

let package = Package(
    name: "Barebones",
    platforms: [
        .macOS("10.15"),
        .iOS("13.6"),
    ],
    products: [
        .library(name: specification.name, targets: [specification.name]),
        .library(name: client.name, targets: [client.name]),
        .library(name: core.name, targets: [core.name]),
        .library(name: server.name, targets: [server.name]),
        .library(name: api.name, targets: [api.name]),
        .library(name: barebones.name, targets: [barebones.name]),
    ],
    dependencies: [
        .package(url: "https://github.com/alexaubry/HTMLString", .upToNextMajor(from: "4.0.2")),
        .package(url: "https://github.com/mxcl/PromiseKit", .upToNextMajor(from: "6.13.2")),
        .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/envoy/Embassy", .upToNextMajor(from: "4.1.1")),
        .package(url: "https://github.com/envoy/Ambassador", .upToNextMajor(from: "4.0.5")),

        .package(url: "https://github.com/compote-platform/Shell", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/compote-platform/Curl", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/compote-platform/MemoryAware", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/compote-platform/Stopwatch", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/compote-platform/Journal", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/compote-platform/Signature", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        specification,
        client,
        core,
        plugins,
        server,
        api,
        barebones,
    ]
)

#if !os(Linux) || (os(iOS) || os(macOS))
package.dependencies += [
    .package(url: "https://github.com/swift-server/async-http-client", from: "1.0.0")
]
client.dependencies += [.product(name: "AsyncHTTPClient", package: "async-http-client")]
#endif
