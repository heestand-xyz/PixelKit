//
//  NoisePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-14.
//  Open Source - MIT License
//


import RenderKit
#if canImport(SwiftUI)
import SwiftUI
#endif

final public class NoisePIX: PIXGenerator, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorNoisePIX" }
    
    public var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var seed: Int = 1
    @Live public var octaves: Int = 10
    @Live public var position: CGPoint = .zero
    @Live public var zPosition: CGFloat = 0.0
    @Live public var zoom: CGFloat = 1.0
    @Live public var colored: Bool = false
    @Live public var random: Bool = false
    @Live public var includeAlpha: Bool = false
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_seed, _octaves, _position, _zPosition, _zoom, _colored, _random, _includeAlpha]
    }
    
    override public var values: [Floatable] {
        [seed, octaves, position, zPosition, zoom, colored, random, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Noise", typeName: "pix-content-generator-noise")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            octaves: Int = 10,
                            zoom: CGFloat = 1.0) {
        self.init(at: resolution)
        self.octaves = octaves
        self.zoom = zoom
    }
    
    // MARK: - Property Funcs
    
    public func pixNoiseSeed(_ value: Int) -> NoisePIX {
        seed = value
        return self
    }
    
    public func pixNoisePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> NoisePIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixNoiseZPosition(_ value: CGFloat) -> NoisePIX {
        zPosition = value
        return self
    }
    
    public func pixNoiseColored() -> NoisePIX {
        colored = true
        return self
    }
    
    public func pixNoiseRandom() -> NoisePIX {
        random = true
        return self
    }
    
    public func pixNoiseIncludeAlpha() -> NoisePIX {
        includeAlpha = true
        return self
    }
    
}
