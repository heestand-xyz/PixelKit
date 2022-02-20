//
//  EdgePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-06.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import MetalPerformanceShaders

final public class EdgePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = EdgePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleEdgePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat("strength", range: 0.0...20.0, increment: 5.0) public var strength: CGFloat = 10.0
    @LiveFloat("distance", range: 0.0...2.0) public var distance: CGFloat = 1.0
    @LiveBool("colored") public var colored: Bool = false
    @LiveBool("transparent") public var transparent: Bool = false
    @LiveBool("includeAlpha") public var includeAlpha: Bool = false
    @LiveBool("sobel") public var sobel: Bool = false

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_strength, _distance, _colored, _transparent, _includeAlpha, _sobel]
    }
    
    override public var values: [Floatable] {
        [strength, distance, colored, transparent, includeAlpha, sobel]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        
        customRenderDelegate = self
        
        customRenderActive = sobel
        _sobel.didSetValue = { [weak self] in
            self?.customRenderActive = self?.sobel ?? false
            self?.render()
        }
        
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        strength = model.strength
        distance = model.distance
        colored = model.colored
        transparent = model.transparent
        includeAlpha = model.includeAlpha
        sobel = model.sobel
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.strength = strength
        model.distance = distance
        model.colored = colored
        model.transparent = transparent
        model.includeAlpha = includeAlpha
        model.sobel = sobel
        
        super.liveUpdateModelDone()
    }
}

extension EdgePIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let size = texture.resolution.size
        guard let sobelTexture = try? Texture.emptyTexture(size: size, bits: PixelKit.main.render.bits, on: PixelKit.main.render.metalDevice, write: true) else {
            PixelKit.main.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let sobelKernel = MPSImageSobel(device: PixelKit.main.render.metalDevice)
        #if os(macOS)
        sobelKernel.edgeMode = extend.mps!
        #endif
        sobelKernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: sobelTexture)
        return sobelTexture
    }
}

public extension NODEOut {
    
    func pixEdge(_ strength: CGFloat = 1.0) -> EdgePIX {
        let edgePix = EdgePIX()
        edgePix.name = ":edge:"
        edgePix.input = self as? PIX & NODEOut
        edgePix.strength = strength
        return edgePix
    }
    
}
