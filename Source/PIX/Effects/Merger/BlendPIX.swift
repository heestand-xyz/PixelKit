//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics
import MetalPerformanceShaders

public class BlendPIX: PIXMergerEffect, Layoutable, PIXAuto, PixelsCustomMergerRenderDelegate {
    
    override open var shader: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index), !bypassTransform.uniform ? 1 : 0, position.x.uniform, position.y.uniform, rotation.uniform, scale.uniform, size.width.uniform, size.height.uniform]
    }
    
    required init() {
        super.init()
        customMergerRenderActive = true
        customMergerRenderDelegate = self
    }
    
    // MARK - Custom Render
    public func customRender(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//        switch blendMode {
//        case .add, .multiply, .subtract:
//            return kernel(a: textureA, b: textureB, with: commandBuffer)
//        default:
//            return nil
//        }
        return nil
    }
    
    func kernel(a textureA: MTLTexture, b textureB: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if #available(OSX 10.13, *) {
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixels.bits.mtl, width: textureA.width, height: textureA.height, mipmapped: true) // CHECK mipmapped
            descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue) // CHECK shaderRead
            guard let texture = pixels.metalDevice.makeTexture(descriptor: descriptor) else {
                pixels.log(pix: self, .error, .generator, "Blend Kernel: Make texture faild.")
                return nil
            }
            switch blendMode {
            case .add:
                let kernel = MPSImageAdd(device: pixels.metalDevice)
                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
            case .multiply:
                let kernel = MPSImageMultiply(device: pixels.metalDevice)
                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
            case .subtract:
                let kernel = MPSImageSubtract(device: pixels.metalDevice)
                kernel.encode(commandBuffer: commandBuffer, primaryTexture: textureA, secondaryTexture: textureB, destinationTexture: texture)
            default:
                return nil
            }
            return texture
        } else {
            return nil
        }
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position * resScale(), size: frameSize() * resScale() * scale * size)
        }
        set {
            reFrame(to: frame)
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
        guard let resB = inPixB?.resolution else { return LiveSize(scale: 1.0) }
        return LiveSize(w: resB.aspect, h: 1.0)
    }
    
    func resScale() -> LiveFloat {
        guard let resA = inPixA?.resolution else { return 1.0 }
        guard let resB = inPixB?.resolution else { return 1.0 }
        let resScale = resB.height / resA.height
        return resScale
    }
    
}

