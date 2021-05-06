//
//  FreezePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-23.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import Metal

final public class FreezePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    @LiveBool("freeze") public var freeze: Bool = false
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_freeze]
    }
    
    override public var values: [Floatable] {
        [freeze]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Freeze", typeName: "pix-effect-single-freeze")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK: Freeze
    
    public override func render() {
        if !freeze {
            super.render()
        }
    }
    
}

public extension NODEOut {
    
    func pixFreeze(_ active: Bool) -> FreezePIX {
        let freezePix = FreezePIX()
        freezePix.name = ":freeze:"
        freezePix.input = self as? PIX & NODEOut
        freezePix.freeze = active
        return freezePix
    }
    
}
