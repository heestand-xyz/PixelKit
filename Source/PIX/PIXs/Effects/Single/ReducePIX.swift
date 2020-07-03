//
//  ReducePIX.swift
//  
//
//  Created by Anton Heestand on 2020-07-03.
//

import LiveValues
import RenderKit
import MetalPerformanceShaders

@available(tvOS 11.3, *)
@available(iOS 11.3, *)
@available(OSX 10.13.4, *)
class ReducePIX: PIXSingleEffect, PIXAuto, CustomRenderDelegate {
    
    override var customResolution: Resolution? {
        guard let inputResolution: Resolution = (input as! PIX?)?.realResolution else { return nil }
        return getCustomResolution(from: inputResolution)
    }
    
    // MARK: - Public Properties
    
    public enum Axis {
        case row
        case column
    }
    
    public var axis: Axis = .row { didSet { applyResolution { self.setNeedsRender() } } }
    
    public enum Method {
//        case avg
        case mean
        case min
        case max
        case sum
    }
    
    public var method: Method = .mean { didSet { setNeedsRender() } }

    public required init() {
        super.init(name: "Reduce", typeName: "pix-effect-single-reduce")
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Custom Render
    
    func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let resolution: Resolution = getCustomResolution(from: texture.resolution)
        guard let destinationTexture: MTLTexture = try? Texture.emptyTexture(size: resolution.size.cg,
                                                                             bits: pixelKit.render.bits,
                                                                             on: pixelKit.render.metalDevice,
                                                                             write: true) else {
            pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let reduceKernel = MPSImageReduceRowMean(device: pixelKit.render.metalDevice)
        #if !os(tvOS)
        reduceKernel.edgeMode = extend.mps!
        #endif
        reduceKernel.encode(commandBuffer: commandBuffer,
                            sourceTexture: texture,
                            destinationTexture: destinationTexture)
        return destinationTexture
    }
    
    // MARK: - Custom Resolution
    
    func getCustomResolution(from resolution: Resolution) -> Resolution {
        switch axis {
        case .row:
            return .custom(w: resolution.w, h: 1)
        case .column:
            return .custom(w: 1, h: resolution.h)
        }
    }
    
}
