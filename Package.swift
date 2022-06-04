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
        .package(url: "https://github.com/heestand-xyz/RenderKit", from: "2.0.3"),
        .package(url: "https://github.com/heestand-xyz/TextureMap", from: "0.5.2"),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.3.2"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit", "TextureMap", "CoreGraphicsExtensions"], exclude: [
            "Other",
            "MetalShaders/README.md",
            "Documentation.docc",
        ], resources: [
            .process("PIX/PIXs/Content/Resource/P5JS/p5.min.js"),
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"], resources: [
            .process("pix-content-generator-arc.json"),
        ]),
    ]
)
