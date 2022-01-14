//
//  LumaTransformPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-02.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class LumaTransformPIX: PIXMergerEffect, PIXViewable {
    
    public typealias Model = LumaTransformPixelModel
    
    private var model: Model {
        get { mergerEffectModel as! Model }
        set { mergerEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMergerLumaTransformPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LiveFloat("scale", range: 0.0...2.0) public var scale: CGFloat = 1.0
    @LiveSize("size") public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    @LiveFloat("lumaGamma", range: 0.0...2.0) public var lumaGamma: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_position, _rotation, _scale, _size, _lumaGamma]
    }
    
    override public var values: [Floatable] {
        [position, rotation, scale, size, lumaGamma]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        position = model.position
        rotation = model.rotation
        scale = model.scale
        size = model.size
        lumaGamma = model.lumaGamma

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.position = position
        model.rotation = rotation
        model.scale = scale
        model.size = size
        model.lumaGamma = lumaGamma

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixLumaTranform(position: CGPoint = .zero,
                         rotation: CGFloat = 0.0,
                         scale: CGFloat = 1.0,
                         size: CGSize = CGSize(width: 1.0, height: 1.0),
                         pix: () -> (PIX & NODEOut)) -> LumaTransformPIX {
        pixLumaTranform(pix: pix(), position: position, rotation: rotation, scale: scale, size: size)
    }
    func pixLumaTranform(pix: PIX & NODEOut,
                         position: CGPoint = .zero,
                         rotation: CGFloat = 0.0,
                         scale: CGFloat = 1.0,
                         size: CGSize = CGSize(width: 1.0, height: 1.0)) -> LumaTransformPIX {
        let lumaTranformPix = LumaTransformPIX()
        lumaTranformPix.name = ":lumaTranformPix:"
        lumaTranformPix.inputA = self as? PIX & NODEOut
        lumaTranformPix.inputB = pix
        
        return lumaTranformPix
    }
    
}

