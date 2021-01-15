//
//  FlipFlopPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

public class FlipFlopPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleFlipFlopPIX" }
    
    // MARK: - Public Properties
        
    public enum Flip: String, Codable, CaseIterable, Floatable {
        case none
        case x
        case y
        case xy
        var index: Int {
            switch self {
            case .none: return 0
            case .x: return 1
            case .y: return 2
            case .xy: return 3
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    
    public enum Flop: String, Codable, CaseIterable, Floatable {
        case none
        case left
        case right
        var index: Int {
            switch self {
            case .none: return 0
            case .left: return 1
            case .right: return 2
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    
    @Live public var flip: Flip = .none
    @LiveResolution public var flop: Flop = .none
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_flip, _flop]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(flip.index), CGFloat(flop.index)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Flip Flop", typeName: "pix-effect-single-flip-flop")
    }
    
}

public extension NODEOut {
    
    func flipX() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flipX:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flip = .x
        return flipFlopPix
    }
    
    func flipY() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flipY:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flip = .y
        return flipFlopPix
    }
    
    func flopLeft() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flopLeft:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flop = .left
        return flipFlopPix
    }
    
    func flopRight() -> FlipFlopPIX {
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "flopRight:flipFlop"
        flipFlopPix.input = self as? PIX & NODEOut
        flipFlopPix.flop = .right
        return flipFlopPix
    }
    
}
