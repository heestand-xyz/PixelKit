//
//  FlipFlopPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class FlipFlopPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = FlipFlopPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleFlipFlopPIX" }
    
    // MARK: - Public Properties
        
    public enum Flip: String, Enumable {
        case none
        case x
        case y
        case xy
        public var index: Int {
            switch self {
            case .none: return 0
            case .x: return 1
            case .y: return 2
            case .xy: return 3
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .none: return "None"
            case .x: return "X"
            case .y: return "Y"
            case .xy: return "XY"
            }
        }
    }
    @LiveEnum("flip") public var flip: Flip = .none
    
    public enum Flop: String, Enumable {
        case none
        case left
        case right
        public var index: Int {
            switch self {
            case .none: return 0
            case .left: return 1
            case .right: return 2
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .none: return "None"
            case .left: return "Left"
            case .right: return "Right"
            }
        }
    }
    @LiveEnum("flop", updateResolution: true) public var flop: Flop = .none
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_flip, _flop]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(flip.index), CGFloat(flop.index)]
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
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        flip = model.flip
        flop = model.flop

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.flip = flip
        model.flop = flop

        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixFlipX() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flipX:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flip = .x
        return flipFlopPix
    }
    
    func pixFlipY() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flipY:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flip = .y
        return flipFlopPix
    }
    
    func pixFlopLeft() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flopLeft:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flop = .left
        return flipFlopPix
    }
    
    func pixFlopRight() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flopRight:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flop = .right
        return flipFlopPix
    }
    
}
