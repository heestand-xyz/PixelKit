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
        .package(url: "https://github.com/heestand-xyz/RenderKit", from: "1.1.1"),
        .package(url: "https://github.com/heestand-xyz/TextureMap", from: "0.1.0"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit", "TextureMap"], path: "Source", exclude: [
            "PIX/PIXs/Output/Syphon Out/SyphonOutPIX.swift",
            "PIX/PIXs/Content/Resource/Syphon In/SyphonInPIX.swift",
            "Other",
            "Shaders/README.md",
            "Documentation.docc",
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"])
    ]
)
