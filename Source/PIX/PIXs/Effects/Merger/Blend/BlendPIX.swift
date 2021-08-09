//
//  BlendPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import CoreGraphics
import MetalKit
import SwiftUI
import PixelColor

final public class BlendPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    @LiveEnum("blendMode") public var blendMode: RenderKit.BlendMode = .average
    @LiveBool("bypassTransform") public var bypassTransform: Bool = false
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LiveFloat("scale", range: 0.0...2.0) public var scale: CGFloat = 1.0
    @LiveSize("size") public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_blendMode, _bypassTransform, _position, _rotation, _scale, _size] + super.liveList
    }
    
    override public var values: [Floatable] {
        [bypassTransform, position, rotation, scale, size]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(blendMode.index), !bypassTransform ? 1 : 0, position.x, position.y, rotation, scale, size.width, size.height]
    }
    
    public required init() {
        super.init(name: "Blend", typeName: "pix-effect-merger-blend")
//        customMergerRenderActive = true
//        customMergerRenderDelegate = self
    }
    
    public convenience init(blendMode: RenderKit.BlendMode = .average,
                            _ inputA: (() -> (PIX & NODEOut))? = nil,
                            with inputB: (() -> (PIX & NODEOut))? = nil) {
        self.init()
        super.inputA = inputA?()
        super.inputB = inputB?()
        self.blendMode = blendMode
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: - Property Funcs
    
    public func pixBlendPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> BlendPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixBlendRotation(_ value: CGFloat) -> BlendPIX {
        rotation = value
        return self
    }
    
    public func pixBlendScale(_ value: CGFloat) -> BlendPIX {
        scale = value
        return self
    }
    
    public func pixBlendSize(width: CGFloat, height: CGFloat) -> BlendPIX {
        size = CGSize(width: width, height: height)
        return self
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

public func pixBlend(_ mode: RenderKit.BlendMode, _ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut) -> BlendPIX {
    let blendPix = BlendPIX()
    blendPix.inputA = pixA
    blendPix.inputB = pixB
    blendPix.blendMode = mode
    return blendPix
}

public extension NODEOut {

    func pixMask(pix: () -> (PIX & NODEOut)) -> BlendPIX {
        pixMask(pix: pix())
    }
    
    /// The red channel is used as a mask
    func pixMask(pix: PIX & NODEOut) -> BlendPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.input = pix
        channelMixPix.alpha = .red
        let blendPix = BlendPIX()
        blendPix.name = ":blend:"
        blendPix.inputA = self as? PIX & NODEOut
        blendPix.inputB = channelMixPix
        blendPix.blendMode = .multiply
        return blendPix
    }
    
    func pixMultiply(color: PixelColor) -> BlendPIX {
        pixBlend(color: color, blendMode: .multiply)
    }
    
    func pixAdd(color: PixelColor) -> BlendPIX {
        pixBlend(color: color, blendMode: .add)
    }
    
    func pixBlend(color: PixelColor, blendMode: RenderKit.BlendMode) -> BlendPIX {
        let blendPix = BlendPIX()
        blendPix.name = ":blend:"
        blendPix.inputA = self as? PIX & NODEOut
        blendPix.inputB = ColorPIX(color: color)
        blendPix.blendMode = blendMode
        return blendPix
    }
    
}
