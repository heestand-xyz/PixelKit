//
//  EqualizePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-08-09.
//

import RenderKit
import Resolution
import CoreGraphics
import MetalKit
#if !os(tvOS) && !targetEnvironment(simulator)
// MPS does not support the iOS simulator.
import MetalPerformanceShaders
#endif
import SwiftUI

final public class EqualizePIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    public typealias Model = EqualizePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    @LiveBool("includeAlpha") public var includeAlpha: Bool = false

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_includeAlpha]
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
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        includeAlpha = model.includeAlpha
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.includeAlpha = includeAlpha
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Histogram
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        #if !os(tvOS) && !targetEnvironment(simulator)
        return histogram(texture, with: commandBuffer)
        #else
        return nil
        #endif
    }
    
    #if !os(tvOS) && !targetEnvironment(simulator)
    func histogram(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        var histogramInfo = MPSImageHistogramInfo(
            numberOfHistogramEntries: 256,
            histogramForAlpha: ObjCBool(includeAlpha),
            minPixelValue: vector_float4(0,0,0,0),
            maxPixelValue: vector_float4(1,1,1,1)
        )
             
        let histogram = MPSImageHistogram(device: PixelKit.main.render.metalDevice, histogramInfo: &histogramInfo)
        let equalization = MPSImageHistogramEqualization(device: PixelKit.main.render.metalDevice, histogramInfo: &histogramInfo)

        let bufferLength: Int = histogram.histogramSize(forSourceFormat: texture.pixelFormat)
        guard let histogramInfoBuffer: MTLBuffer = PixelKit.main.render.metalDevice.makeBuffer(length: bufferLength, options: [.storageModePrivate]) else { return nil }
        
        histogram.encode(to: commandBuffer, sourceTexture: texture, histogram: histogramInfoBuffer, histogramOffset: 0)
        
        equalization.encodeTransform(to: commandBuffer, sourceTexture: texture, histogram: histogramInfoBuffer, histogramOffset: 0)
        
        guard let histogramTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: PixelKit.main.render.bits, on: PixelKit.main.render.metalDevice, write: true) else {
            PixelKit.main.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        
        equalization.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: histogramTexture)
        
        return histogramTexture
        
    }
    #endif
    
}

public extension NODEOut {
    
    func pixEqualize() -> EqualizePIX {
        let equalizePix = EqualizePIX()
        equalizePix.name = ":equalize:"
        equalizePix.input = self as? PIX & NODEOut
        return equalizePix
    }
    
}

struct EqualizePIX_Previews: PreviewProvider {
    static var previews: some View {
        PixelView(pix: {
            let noisePix = NoisePIX()
            noisePix.octaves = 10
            noisePix.colored = true
            let equalizePix = EqualizePIX()
            equalizePix.input = noisePix
            return equalizePix
        }())
    }
}
