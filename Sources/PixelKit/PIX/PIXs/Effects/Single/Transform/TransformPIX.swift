//
//  TransformPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-28.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class TransformPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = TransformPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleTransformPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LiveFloat("scale") public var scale: CGFloat = 1.0
    @LiveSize("size") public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_position, _rotation, _scale, _size]
    }
    
    override public var values: [Floatable] {
        return [position, rotation, scale, size]
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

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.position = position
        model.rotation = rotation
        model.scale = scale
        model.size = size

        super.liveUpdateModelDone()
    }
    
}

public extension NODEOut {
    
    func pixTranslate(by position: CGPoint) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "position:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.position = position
        return transformPix
    }
    
    func pixTranslate(x: CGFloat = 0.0, y: CGFloat = 0.0) -> TransformPIX {
        (self as! PIX & NODEOut).pixTranslate(by: CGPoint(x: x, y: y))
    }
    
    func pixRotatate(by rotation: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "rotatate:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.rotation = rotation
        return transformPix
    }
    
    func pixRotatate(byDegrees rotation: CGFloat) -> TransformPIX {
        (self as! PIX & NODEOut).pixRotatate(by: rotation / 360)
    }
    
    func pixRotatate(byRadians rotation: CGFloat) -> TransformPIX {
        (self as! PIX & NODEOut).pixRotatate(by: rotation / (.pi * 2))
    }
    
    func pixScale(by scale: CGFloat) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.scale = scale
        return transformPix
    }
    
    func pixResize(by size: CGSize) -> TransformPIX {
        let transformPix = TransformPIX()
        transformPix.name = "scale:transform"
        transformPix.input = self as? PIX & NODEOut
        transformPix.size = size
        return transformPix
    }
    
    func pixScale(x: CGFloat = 1.0, y: CGFloat = 1.0) -> TransformPIX {
        pixResize(by: CGSize(width: x, height: y))
    }
    
}
