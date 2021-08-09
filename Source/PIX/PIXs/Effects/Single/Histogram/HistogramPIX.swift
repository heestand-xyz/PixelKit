//
//  HistogramPIX.swift
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

final public class HistogramPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable/*, NODEResolution*/ {
        
    override public var shaderName: String { return "nilPIX" }

//    public var resolution: Resolution = .square(256)
    
    // MARK: - Public Properties
    
    @LiveInt("power", range: 8...12) var power: Int = 8 {
        didSet {
//            resolution = .square(Int(pow(2.0, CGFloat(power))))
        }
    }
    @LiveBool("includeAlpha") var includeAlpha: Bool = false

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_power, _includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Histogram", typeName: "pix-effect-single-histogram")
        customRenderDelegate = self
        customRenderActive = true
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        customRenderDelegate = self
        customRenderActive = true
    }
    
    // MARK: Histogram
    
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
            numberOfHistogramEntries: Int(pow(2.0, CGFloat(power))),
            histogramForAlpha: ObjCBool(includeAlpha),
            minPixelValue: vector_float4(0,0,0,0),
            maxPixelValue: vector_float4(1,1,1,1)
        )
             
        let histogram = MPSImageHistogram(device: pixelKit.render.metalDevice, histogramInfo: &histogramInfo)
        let equalization = MPSImageHistogramEqualization(device: pixelKit.render.metalDevice, histogramInfo: &histogramInfo)

        let bufferLength: Int = histogram.histogramSize(forSourceFormat: texture.pixelFormat)
        guard let histogramInfoBuffer: MTLBuffer = pixelKit.render.metalDevice.makeBuffer(length: bufferLength, options: [.storageModePrivate]) else { return nil }
        
        histogram.encode(to: commandBuffer, sourceTexture: texture, histogram: histogramInfoBuffer, histogramOffset: 0)
        
        equalization.encodeTransform(to: commandBuffer, sourceTexture: texture, histogram: histogramInfoBuffer, histogramOffset: 0)
        
        guard let histogramTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: pixelKit.render.bits, on: pixelKit.render.metalDevice, write: true) else {
            pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        
        equalization.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: histogramTexture)
        
        return histogramTexture
        
    }
    #endif
    
}

public extension NODEOut {
    
    func pixHistogram(power: Int = 8) -> HistogramPIX {
        let histogramPix = HistogramPIX()
        histogramPix.name = ":histogram:"
        histogramPix.input = self as? PIX & NODEOut
        histogramPix.power = power
        return histogramPix
    }
    
}

struct HistogramPIX_Previews: PreviewProvider {
    static var previews: some View {
        PixelView(pix: {
            let noisePix = NoisePIX()
            noisePix.octaves = 10
            noisePix.colored = true
            let histogramPix = HistogramPIX()
            histogramPix.input = noisePix
            return histogramPix
        }())
    }
}
