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

open class PIXCustom: PIXContent, NODECustom, CustomRenderDelegate {
    
    public var customModel: PixelCustomModel {
        get { contentModel as! PixelCustomModel }
        set { contentModel = newValue }
    }
    
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
    
    // MARK: - Life Cycle -
    
    public init(model: PixelCustomModel) {
        self.resolution = model.resolution
        super.init(model: model)
        setupCustom()
    }
    
    public required init(at resolution: Resolution) {
        fatalError("please use init(model:)")
    }
    
    // MARK: - Setup
    
    private func setupCustom() {
        customRenderDelegate = self
        customRenderActive = true
        applyResolution { [weak self] in
            self?.render()
        }
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = customModel.resolution
        backgroundColor = customModel.backgroundColor
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        customModel.resolution = resolution
        customModel.backgroundColor = backgroundColor
    }
    
    // MARK: - Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? { nil }
    
}
