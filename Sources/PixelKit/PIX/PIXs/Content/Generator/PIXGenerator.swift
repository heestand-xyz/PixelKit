//
//  PIXGenerator.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-16.
//  Open Source - MIT License
//

import CoreGraphics
import MetalKit
import PixelColor
import RenderKit
import Resolution

open class PIXGenerator: PIXContent, NODEGenerator, NODEResolution {
    
    public var generatorModel: PixelGeneratorModel {
        get { contentModel as! PixelGeneratorModel }
        set { contentModel = newValue }
    }
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128

    public var premultiply: Bool = true { didSet { render() } }
    override open var shaderNeedsResolution: Bool { return true }
    
    public var tileResolution: Resolution { PixelKit.main.tileResolution }
    public var tileTextures: [[MTLTexture]]?
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black
    @LiveColor("color") public var color: PixelColor = .white
    
    open override var liveList: [LiveWrap] {
        super.liveList + [_resolution, _backgroundColor, _color]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: PixelGeneratorModel) {
        self.resolution = model.resolution
        super.init(model: model)
        setupGenerator()
    }
    
    public required init(at resolution: Resolution) {
        fatalError("please use init(model:)")
    }
    
    // MARK: - Setup
    
    func setupGenerator() {
        applyResolution { [weak self] in
            self?.render()
            // FIXME: Delay on Init
            PixelKit.main.render.delay(frames: 1) { [weak self] in
                self?.render()
            }
        }
    }
    
    // MARK: - Live Model
    
    open override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = generatorModel.resolution
        backgroundColor = generatorModel.backgroundColor
        color = generatorModel.color
        premultiply = generatorModel.premultiply
    }
    
    open override func liveUpdateModel() {
        super.liveUpdateModel()
        
        generatorModel.resolution = resolution
        generatorModel.backgroundColor = backgroundColor
        generatorModel.color = color
        generatorModel.premultiply = premultiply
    }
    
    // MARK: - Property Funcs
    
    public func pixResolution(_ value: Resolution) -> PIXGenerator {
        resolution = value
        return self
    }
    
    public func pixColor(_ value: PixelColor) -> PIXGenerator {
        color = value
        return self
    }
    
    public func pixBackgroundColor(_ value: PixelColor) -> PIXGenerator {
        backgroundColor = value
        return self
    }
    
}
