//
//  PIXCustom.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//

import RenderKit
import Metal
import PixelColor

open class PIXCustom: PIXContent, NODECustom, NODEResolution, CustomRenderDelegate {
    
    override open var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Public Properties
    
    public var resolution: Resolution { didSet { applyResolution { self.setNeedsRender() } } }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    @Live public var backgroundColor: PixelColor = .black
    
    public override var liveList: [LiveWrap] {
        [_backgroundColor]
    }
    
    override open var values: [Floatable] { return [backgroundColor] }
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), name: String, typeName: String) {
        self.resolution = resolution
        super.init(name: name, typeName: typeName)
        customRenderDelegate = self
        customRenderActive = true
        applyResolution { self.setNeedsRender() }
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? { return nil }
    
}
