//
//  NoisePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-14.
//  Open Source - MIT License
//


import RenderKit
import Resolution
#if canImport(SwiftUI)
import SwiftUI
#endif

final public class NoisePIX: PIXGenerator, PIXViewable {
    
    public typealias Model = NoisePixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorNoisePIX" }
    
    // MARK: - Public Properties
    
    @LiveInt("seed", range: 0...100) public var seed: Int = 1
    @LiveInt("octaves", range: 1...10, clamped: true) public var octaves: Int = 1
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("motion") public var motion: CGFloat = 0.0
    @LiveFloat("zoom", range: 0.25...2.0, increment: 0.25) public var zoom: CGFloat = 1.0
    @LiveBool("colored") public var colored: Bool = false
    @LiveBool("random") public var random: Bool = false
    @LiveBool("includeAlpha") public var includeAlpha: Bool = false
    
    @available(*, deprecated, renamed: "motion")
    public var zPosition: CGFloat {
        get { motion }
        set { motion = newValue }
    }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList.filter({ liveWrap in
            !["backgroundColor", "color"].contains(liveWrap.typeName)
        }) + [_seed, _octaves, _position, _motion, _zoom, _colored, _random, _includeAlpha]
    }
    
    override public var values: [Floatable] {
        [seed, octaves, position, motion, zoom, colored, random, includeAlpha]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            octaves: Int = 10,
                            zoom: CGFloat = 1.0) {
        self.init(at: resolution)
        self.octaves = octaves
        self.zoom = zoom
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        seed = model.seed
        octaves = model.octaves
        position = model.position
        motion = model.motion
        zoom = model.zoom
        colored = model.colored
        random = model.random
        includeAlpha = model.includeAlpha
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.seed = seed
        model.octaves = octaves
        model.position = position
        model.motion = motion
        model.zoom = zoom
        model.colored = colored
        model.random = random
        model.includeAlpha = includeAlpha
        
        super.liveUpdateModelDone()
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
    
    public func pixNoiseMotion(_ value: CGFloat) -> NoisePIX {
        motion = value
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
