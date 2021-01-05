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
public class ReducePIX: PIXSingleEffect, PIXAuto, CustomRenderDelegate {
    
    override open var shaderName: String { return "nilPIX" }

    override var customResolution: Resolution? {
        guard let inputResolution: Resolution = (input as! PIX?)?.realResolution else { return nil }
        return getCustomResolution(from: inputResolution)
    }

    // MARK: - Public Properties
    
    public enum Method {
        /// average
        case avg
        /// minumum
        case min
        /// maximum
        case max
        /// sum of all pixels the cell list
        case sum
    }
    
    public var method: Method = .avg { didSet { setNeedsRender() } }

    public required init() {
        super.init(name: "Reduce", typeName: "pix-effect-single-reduce")
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Custom Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let resolution: Resolution = getCustomResolution(from: texture.resolution)
        guard let destinationTexture: MTLTexture = try? Texture.emptyTexture(size: resolution.size.cg,
                                                                             bits: pixelKit.render.bits,
                                                                             on: pixelKit.render.metalDevice,
                                                                             write: true) else {
            pixelKit.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        let reduceKernel: MPSImageReduceUnary = getKernel(with: pixelKit.render.metalDevice)
        #if !os(tvOS) && !targetEnvironment(simulator)
        reduceKernel.edgeMode = extend.mps!
        #endif
        reduceKernel.encode(commandBuffer: commandBuffer,
                            sourceTexture: texture,
                            destinationTexture: destinationTexture)
        return destinationTexture
    }
    
    // MARK: - Resolution
    
    func getCustomResolution(from resolution: Resolution) -> Resolution {
        return .custom(w: 1, h: resolution.h)
    }
    
    // MARK: - Kernel
    
    func getKernel(with device: MTLDevice) -> MPSImageReduceUnary {
       switch method {
        case .avg:
            return MPSImageReduceRowMean(device: device)
        case .min:
            return MPSImageReduceRowMin(device: device)
        case .max:
            return MPSImageReduceRowMax(device: device)
        case .sum:
            return MPSImageReduceRowSum(device: device)
        }
    }
    
}
