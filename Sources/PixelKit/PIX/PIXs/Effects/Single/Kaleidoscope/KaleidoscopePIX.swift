//
//  KaleidoscopePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class KaleidoscopePIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = KaleidoscopePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleKaleidoscopePIX" }
    
    // MARK: - Public Properties
    
    @LiveInt("divisions", range: 2...24) public var divisions: Int = 12
    @LiveBool("mirror") public var mirror: Bool = true
    @LiveFloat("rotation", range: -0.5...0.5, increment: 0.125) public var rotation: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_divisions, _mirror, _rotation, _position]
    }
    
    override public var values: [Floatable] {
        [divisions, mirror, rotation, position]
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
        
        divisions = model.divisions
        mirror = model.mirror
        rotation = model.rotation
        position = model.position

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.divisions = divisions
        model.mirror = mirror
        model.rotation = rotation
        model.position = position

        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixKaleidoscope(divisions: Int = 12, mirror: Bool = true) -> KaleidoscopePIX {
        let kaleidoscopePix = KaleidoscopePIX()
        kaleidoscopePix.name = ":kaleidoscope:"
        kaleidoscopePix.input = self as? PIX & NODEOut
        kaleidoscopePix.divisions = divisions
        kaleidoscopePix.mirror = mirror
        return kaleidoscopePix
    }
    
}
