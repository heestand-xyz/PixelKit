//
//  BlendPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics
import MetalKit
//#if !os(tvOS) && !targetEnvironment(simulator)
//import MetalPerformanceShaders
//#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

//@available(iOS 13.0.0, *)
//@available(OSX 10.15, *)
//@available(tvOS 13.0.0, *)
//public struct PixBlend: View, PIXUI {
//    public var node: NODE { pix }
//
//    public let pix: PIX
//    let blendpix: BlendPIX
//    public var body: some View {
//        NODERepView(node: pix)
//    }
//
//    public init(mode: RenderKit.BlendMode, _ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
//        blendpix = BlendPIX()
//        blendpix.blendMode = mode
//        pix = blendpix
//        blendpix.inputA = uiPixA().pix as? (PIX & NODEOut)
//        blendpix.inputB = uiPixB().pix as? (PIX & NODEOut)
//    }
//}

public class BlendPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    @Live public var blendMode: RenderKit.BlendMode = .add
    @Live public var bypassTransform: Bool = false
    @Live public var position: CGPoint = .zero
    @Live public var rotation: CGFloat = 0.0
    @Live public var scale: CGFloat = 1.0
    @Live public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_blendMode, _bypassTransform, _position, _rotation, _scale, _size] + super.liveList
    }
    
    override public var values: [Floatable] {
        [bypassTransform, position, rotation, scale, size]
    }
    
    open override var uniforms: [CGFloat] {
        [CGFloat(blendMode.index), !bypassTransform ? 1 : 0, position.x, position.y, rotation, scale, size.width, size.height]
    }
    
    public required init() {
        super.init(name: "Blend", typeName: "pix-effect-merger-blend")
//        customMergerRenderActive = true
//        customMergerRenderDelegate = self
    }
    
    // MARK - Custom Render
//    public func customRender(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//        switch blendMode {
//        case .add, .multiply, .subtract:
//            #if !os(tvOS) && !targetEnvironment(simulator)
//            return kernel(a: textureA, b: textureB, with: commandBuffer)
//            #else
//            return nil
//            #endif
//        default:
//            return nil
//        }
//    }
//
//    #if !os(tvOS) && !targetEnvironment(simulator)
//    func kernel(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//        if #available(OSX 10.13, *) {
//            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelKit.bits.mtl, width: textureA.width, height: textureA.height, mipmapped: true) // CHECK mipmapped
//            descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
//            guard let texture = pixelKit.metalDevice.makeTexture(descriptor: descriptor) else {
//                pixelKit.logger.log(node: self, .error, .generator, "Blend Kernel: Make texture faild.")
//                return nil
//            }
//            switch blendMode {
//            case .add:
//                let kernel = MPSImageAdd(device: pixelKit.metalDevice)
//                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
//            case .multiply:
//                let kernel = MPSImageMultiply(device: pixelKit.metalDevice)
//                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
//            case .subtract:
//                let kernel = MPSImageSubtract(device: pixelKit.metalDevice)
//                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
//            default:
//                return nil
//            }
//            return texture
//        } else {
//            return nil
//        }
//    }
//    #endif
    
}

public func blend(_ mode: RenderKit.BlendMode, _ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut) -> BlendPIX {
    let blendPix = BlendPIX()
    blendPix.inputA = pixA
    blendPix.inputB = pixB
    blendPix.blendMode = mode
    return blendPix
}
