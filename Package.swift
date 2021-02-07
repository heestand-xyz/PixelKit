// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"]),
//        .executable(name: "PixelKit CommandLab", targets: ["PixelKitCommandLab"])
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/RenderKit.git", .branch("swiftui")),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["RenderKit"], path: "Source", exclude: [
//            "PIX/PIXs/Effects/Single/DeepLabPIX.swift",
            "PIX/PIXs/Output/SyphonOutPIX.swift",
            "PIX/PIXs/Content/Resource/SyphonInPIX.swift",
//            "Other/Bridging-Header-iOS.h",
//            "Other/Bridging-Header-macOS.h",
//            "Other/BridgingHeader.h",
            "PIX/Auto/PIXUIs.stencil",
            "PIX/Auto/PIXAuto.stencil",
            "PIX/PIXs/Content/Generator/Metal/ContentGeneratorMetalPIX.metal.txt",
            "PIX/PIXs/Effects/Single/Metal/EffectSingleMetalPIX.metal.txt",
            "PIX/PIXs/Effects/Merger/Metal/EffectMergerMetalPIX.metal.txt",
            "PIX/PIXs/Effects/Multi/Metal/EffectMultiMetalPIX.metal.txt",
            "Other/NDI",
        ], resources: [
            .process("metaltest.txt"),
            .process("metaltest.metal"),
            .copy("Metal/"),
        ]),
//        .target(name: "PixelKitCommandLab", dependencies: ["PixelKit"], path: "Tests/CommandLab", exclude: ["Mains"]),
        .testTarget(name: "PixelKitTests", dependencies: ["PixelKit"])
    ]
)
