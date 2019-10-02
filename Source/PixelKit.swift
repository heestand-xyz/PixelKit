//
//  PixelKit.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import RenderKit

public class PixelKit {
    
    public static let render = Render(with: kMetalLibName)
    public static let logger = Logger()

    // MARK: Signature
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    let kBundleId = "se.hexagons.pixelkit.macos"
    let kMetalLibName = "PixelKitShaders-macOS"
    #elseif os(iOS)
    let kBundleId = "se.hexagons.pixelkit"
    let kMetalLibName = "PixelKitShaders"
    #elseif os(tvOS)
    let kBundleId = "se.hexagons.pixelkit.tvos"
    let kMetalLibName = "PixelKitShaders-tvOS"
    #endif
    
}
