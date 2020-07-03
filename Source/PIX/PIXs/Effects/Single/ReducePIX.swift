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
    
    override open var shaderName: String { return "effectSingleReducePIX" }

    override var customResolution: Resolution? {
        guard let inputResolution: Resolution = (input as! PIX?)?.realResolution else { return nil }
        return getCustomResolution(from: inputResolution)
    }

    // MARK: - Public Properties
    
    public enum Axis {
        case horizontal
        case vertical
    }
    
    /// final output axis of pixels
    ///
    /// to get one pixel row, use `.horizontal` *(default)*
    public var axis: Axis = .horizontal { didSet { applyResolution { self.setNeedsRender() } } }
    
    public enum Method {
        case mean
        case min
        case max
        case sum
        /// enable 16 bit fore better accuracy: `PixelKit.main.render.bits = ._16`
        case average
    }
    
    public var method: Method = .mean {
        didSet {
            setNeedsRender()
            if method == .average && pixelKit.render.bits == ._8 {
                pixelKit.logger.log(.info, .render, "Reduce with .average is better in 16 bit mode. `PixelKit.main.render.bits = ._16`")
            }
        }
    }

//    public override var overrideBits: LiveColor.Bits? { method == .average ? ._16 : nil }

    public required init() {
        super.init(name: "Reduce", typeName: "pix-effect-single-reduce")
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Property Helpers
    
    var resolutionCount: Int {
        guard let inputResolution: Resolution = (input as! PIX?)?.realResolution else { return 1 }
        return getResolutionCount(from: inputResolution)
    }
    
    public override var uniforms: [CGFloat] {
        [
            method == .average ? 1.0 : 0.0,
            CGFloat(resolutionCount),
        ]
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
        #if !os(tvOS)
        reduceKernel.edgeMode = extend.mps!
        #endif
        reduceKernel.encode(commandBuffer: commandBuffer,
                            sourceTexture: texture,
                            destinationTexture: destinationTexture)
        return destinationTexture
    }
    
    // MARK: - Resolution
    
    func getCustomResolution(from resolution: Resolution) -> Resolution {
        switch axis {
        case .horizontal:
            return .custom(w: resolution.w, h: 1)
        case .vertical:
            return .custom(w: 1, h: resolution.h)
        }
    }
    
    func getResolutionCount(from resolution: Resolution) -> Int {
        switch axis {
        case .horizontal:
            return resolution.h
        case .vertical:
            return resolution.w
        }
    }
    
    // MARK: - Kernel
    
    func getKernel(with device: MTLDevice) -> MPSImageReduceUnary {
        switch axis {
        case .horizontal:
            switch method {
            case .mean:
                return MPSImageReduceColumnMean(device: device)
            case .min:
                return MPSImageReduceColumnMin(device: device)
            case .max:
                return MPSImageReduceColumnMax(device: device)
            case .sum, .average:
                return MPSImageReduceColumnSum(device: device)
            }
        case .vertical:
            switch method {
            case .mean:
                return MPSImageReduceRowMean(device: device)
            case .min:
                return MPSImageReduceRowMin(device: device)
            case .max:
                return MPSImageReduceRowMax(device: device)
            case .sum, .average:
                return MPSImageReduceRowSum(device: device)
            }
        }
    }
    
}
