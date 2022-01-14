// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/RenderKit", from: "2.0.0"),
        .package(url: "https://github.com/heestand-xyz/TextureMap", from: "0.1.1"),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.2.1"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit", "TextureMap", "CoreGraphicsExtensions"], exclude: [
            "Other",
            "Shaders/README.md",
            "Documentation.docc",
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"], resources: [
            .process("pix-content-generator-arc.json"),
        ]),
    ]
)
