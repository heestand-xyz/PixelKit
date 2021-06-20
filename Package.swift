// swift-tools-version:5.5

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
        .package(url: "https://github.com/heestand-xyz/RenderKit", from: "1.0.0"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit"], path: "Source", exclude: [
            "PIX/PIXs/Output/Syphon Out/SyphonOutPIX.swift",
            "PIX/PIXs/Content/Resource/Syphon In/SyphonInPIX.swift",
            "Other",
            "Shaders/README.md",
        ]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"])
    ]
)
