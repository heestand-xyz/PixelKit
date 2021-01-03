//
//  FreezePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-23.
//  Open Source - MIT License
//


import RenderKit
import Metal

public class FreezePIX: PIXSingleEffect {
    
    override open var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    public var freeze: Bool = false
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [freeze]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Freeze", typeName: "pix-effect-single-freeze")
    }
    
    // MARK: Freeze
    
    public override func setNeedsRender() {
        if !freeze.val {
            super.setNeedsRender()
        }
    }
    
}

public extension NODEOut {
    
    func _freeze(_ active: Bool) -> FreezePIX {
        let freezePix = FreezePIX()
        freezePix.name = ":freeze:"
        freezePix.input = self as? PIX & NODEOut
        freezePix.freeze = active
        return freezePix
    }
    
}
