// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KeyLinger",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "KeyLinger", targets: ["KeyLinger"])
    ],
    targets: [
        .executableTarget(
            name: "KeyLinger",
            path: "Sources/KeyLinger",
            resources: [.process("Resources")]
        )
    ]
)
