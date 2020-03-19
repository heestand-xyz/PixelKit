// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "PixelKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11)
    ],
    products: [
        .library(name: "PixelKit", targets: ["PixelKit"]),
    ],
    dependencies: [
//        .package(path: "~/Code/Frameworks/Production/LiveValues"),
        .package(url: "https://github.com/hexagons/LiveValues.git", from: "1.2.0"),
//        .package(path: "~/Code/Frameworks/Production/RenderKit"),
        .package(url: "https://github.com/hexagons/RenderKit.git", from: "0.4.0"),
    ],
    targets: [
        .target(name: "PixelKit", dependencies: ["LiveValues", "RenderKit"], path: "Source", exclude: [
            "PIX/PIXs/Effects/Single/DeepLabPIX.swift",
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
        ])
    ]
)
