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
    
    public required init() {
        super.init(name: "Edge", typeName: "pix-effect-single-edge")
        setup()
        extend = .hold
    }
    
    // MARK: Setup
    
    private func setup() {
        
        customRenderDelegate = self
        
        customRenderActive = sobel
        _sobel.didSetValue = { [weak self] in
            self?.customRenderActive = self?.sobel ?? false
            self?.render()
        }
        
    }
    
}

extension EdgePIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let size = texture.resolution.size
        guard let sobelTexture = try? Texture.emptyTexture(size: size, bits: pixelKit.render.bits, on: pixelKit.render.metalDevice, write: true) else {
            pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
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
