//
//  LumaBlurPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import CoreImage

final public class LumaBlurPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = LumaBlurPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerLumaBlurPIX" }
    
    // MARK: - Public Properties
    
    public enum Style: String, Enumable {
        case box
        case angle
        case zoom
        case random
        case ciFilter
        public var index: Int {
            switch self {
            case .box: return 1
            case .angle: return 2
            case .zoom: return 3
            case .random: return 4
            case .ciFilter: return 5
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .box: return "Box"
            case .angle: return "Angle"
            case .zoom: return "Zoom"
            case .random: return "Random"
            case .ciFilter: return "CI Filter"
            }
        }
    }
    
    @LiveEnum("style") public var style: Style = .box
    @LiveFloat("radius", increment: 0.125) public var radius: CGFloat = 0.5
    @LiveEnum("quality") public var quality: SampleQualityMode = .mid
    @LiveFloat("angle", range: -0.5...0.5) public var angle: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _radius, _quality, _angle, _position, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [radius, angle, position, lumaGamma]
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(style.index), radius * 32 * 10, CGFloat(quality.rawValue), angle, position.x, position.y, lumaGamma]
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
    
    public convenience init(radius: CGFloat = 0.5,
                            _ inputA: () -> (PIX & NODEOut),
                            with inputB: () -> (PIX & NODEOut)) {
        self.init()
        super.inputA = inputA()
        super.inputB = inputB()
        self.radius = radius
    }
    
    // MARK: Setup
    
    private func setup() {
        
        customRenderActive = style == .ciFilter
        _style.didSetValue = { [weak self] in
            self?.customRenderActive = self?.style == .ciFilter
        }
        
        customRenderDelegate = self
        
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        style = model.style
        radius = model.radius
        quality = model.quality
        angle = model.angle
        position = model.position
        lumaGamma = model.lumaGamma

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.style = style
        model.radius = radius
        model.quality = quality
        model.angle = angle
        model.position = position
        model.lumaGamma = lumaGamma

        super.liveUpdateModelDone()
    }
    
    // MARK: Property Funcs
    
    public func pixLumaBlurStyle(_ value: Style) -> LumaBlurPIX {
        style = value
        return self
    }
    
    public func pixLumaBlurQuality(_ value: SampleQualityMode) -> LumaBlurPIX {
        quality = value
        return self
    }
    
    public func pixLumaBlurAngle(_ value: CGFloat) -> LumaBlurPIX {
        angle = value
        return self
    }
    
    public func pixLumaBlurPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> LumaBlurPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
}

extension LumaBlurPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        guard let textureA = inputA?.texture else { return nil }
        guard let textureB = inputB?.texture else { return nil }
        
        guard let ciImageA = Texture.ciImage(from: textureA, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        guard var ciImageB = Texture.ciImage(from: textureB, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        if ciImageA.extent.size != ciImageB.extent.size {
            guard let imageB = Texture.image(from: ciImageB) else { return nil }
            let stretchedImageB = Texture.resize(imageB, to: ciImageA.extent.size, placement: .stretch)
            guard let stretchedCIImageB = Texture.ciImage(from: stretchedImageB) else { return nil }
            ciImageB = stretchedCIImageB
        }
        
        let parameters: [String : Any]? = [
            kCIInputImageKey : ciImageA,
            "inputMask" : ciImageB,
            "inputRadius" : NSNumber(value: radius * 100),
        ]
            
        guard let filter: CIFilter = CIFilter(name: "CIMaskedVariableBlur", parameters: parameters) else { return nil }
        guard let finalImage: CIImage = filter.outputImage else { return nil }
        
        let croppedImage: CIImage = finalImage.cropped(to: ciImageA.extent)

        do {
            let finalTexture: MTLTexture = try Texture.makeTexture(from: croppedImage,
                                                                   at: textureA.resolution.size,
                                                                   colorSpace: PixelKit.main.render.colorSpace,
                                                                   bits: PixelKit.main.render.bits,
                                                                   with: commandBuffer,
                                                                   on: PixelKit.main.render.metalDevice)
            return finalTexture
        } catch {
            PixelKit.main.logger.log(node: self, .error, .resource, "Masked Variable Blur Failed", e: error)
            return nil
        }
        
    }
    
}

public extension NODEOut {
    
    func pixLumaBlur(radius: CGFloat, quality: PIX.SampleQualityMode = .default, pix: () -> (PIX & NODEOut)) -> LumaBlurPIX {
        pixLumaBlur(pix: pix(), radius: radius, quality: quality)
    }
    func pixLumaBlur(pix: PIX & NODEOut, radius: CGFloat, quality: PIX.SampleQualityMode = .default) -> LumaBlurPIX {
        let lumaBlurPix = LumaBlurPIX()
        lumaBlurPix.name = ":lumaBlur:"
        lumaBlurPix.inputA = self as? PIX & NODEOut
        lumaBlurPix.inputB = pix
        lumaBlurPix.radius = radius
        lumaBlurPix.quality = quality
        return lumaBlurPix
    }
    
    func pixTiltShift(radius: CGFloat = 0.5, gamma: CGFloat = 0.5, offset: CGFloat = 0.0, scale: CGFloat = 1.0, quality: PIX.SampleQualityMode = .default) -> LumaBlurPIX {
        let pix = self as! PIX & NODEOut
        let gradientPix = GradientPIX(at: pix.finalResolution)
        gradientPix.name = "tiltShift:gradient"
        gradientPix.direction = .vertical
        gradientPix.offset = 0.5 + offset
        gradientPix.scale = 0.5 * scale
        gradientPix.extendMode = .mirror
        return pix.pixLumaBlur(pix: gradientPix !** gamma, radius: radius, quality: quality)
    }
    
}
