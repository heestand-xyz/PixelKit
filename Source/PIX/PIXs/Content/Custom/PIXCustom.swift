//
//  PIXCustom.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//

import RenderKit
import Resolution
import Metal
import PixelColor

open class PIXCustom: PIXContent, NODECustom, NODEResolution, CustomRenderDelegate {
    
    override open var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black
    
    public override var liveList: [LiveWrap] {
        [_backgroundColor, _resolution] + super.liveList
    }
    
    override open var values: [Floatable] { return [backgroundColor] }
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), name: String, typeName: String) {
        self.resolution = resolution
        super.init(name: name, typeName: typeName)
        setupCustom()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        setupCustom()
    }
    
    func setupCustom() {
        customRenderDelegate = self
        customRenderActive = true
        applyResolution { [weak self] in
            self?.render()
        }
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? { return nil }
    
}
