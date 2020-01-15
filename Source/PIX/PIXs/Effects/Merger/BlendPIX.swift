//
//  BlendPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics
import MetalKit
//#if !os(tvOS) && !targetEnvironment(simulator)
//import MetalPerformanceShaders
//#endif

public class BlendPIX: PIXMergerEffect, Layoutable, PIXAuto/*, PixelCustomMergerRenderDelegate*/ {
    
    override open var shaderName: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = LiveFloat(0.0, min: -0.5, max: 0.5)
    public var scale: LiveFloat = LiveFloat(1.0, max: 2.0)
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index), !bypassTransform.uniform ? 1 : 0, position.x.uniform, position.y.uniform, rotation.uniform, scale.uniform, size.width.uniform, size.height.uniform]
    }
    
    public required init() {
        super.init()
        name = "blend"
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
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position * resScale(), size: frameSize() * resScale() * scale * size)
        }
        set {
            reFrame(to: newValue)
        }
    }
    public var frameRotation: LiveFloat {
        get { return rotation }
        set { rotation = newValue }
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center / resScale()
        scale = 1.0
        size = frame.size / (frameSize() * resScale())
    }
    
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        anchorX(targetXAnchor, to: layoutable.frame, sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        anchorY(targetYAnchor, to: layoutable.frame, sourceYAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, toBoundAnchor: sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, toBoundAnchor: sourceYAnchor, constant: constant)
    }
    
    func frameSize() -> LiveSize {
        guard let resB = inputB?.renderResolution else { return LiveSize(scale: 1.0) }
        return LiveSize(w: resB.aspect, h: 1.0)
    }
    
    func resScale() -> LiveFloat {
        guard let resA = inputA?.renderResolution else { return 1.0 }
        guard let resB = inputB?.renderResolution else { return 1.0 }
        let resScale = resB.height / resA.height
        return resScale
    }
    
}

public func blend(_ mode: BlendMode, _ pixA: PIX & NODEOut, _ pixB: PIX & NODEOut) -> BlendPIX {
    let blendPix = BlendPIX()
    blendPix.inputA = pixA
    blendPix.inputB = pixB
    blendPix.blendMode = mode
    return blendPix
}
