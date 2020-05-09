//
//  ChromaKeyPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class ChromaKeyPIX: PIXSingleEffect, PIXAuto {
    
    override open var shaderName: String { return "effectSingleChromaKeyPIX" }
    
    // MARK: - Public Properties
    
    public var keyColor: LiveColor = .green
    public var range: LiveFloat = LiveFloat(0.1, min: 0.0, max: 0.5)
    public var softness: LiveFloat = LiveFloat(0.1, min: 0.0, max: 0.5)
    public var edgeDesaturation: LiveFloat = 0.5
    public var premultiply: LiveBool = true
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [keyColor, range, softness, edgeDesaturation, premultiply]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Chroma Key", typeName: "pix-effect-single-chroma-key")
    }
    
}

public extension NODEOut {
    
    func _chromaKey(_ color: LiveColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.name = ":chromaKey:"
        chromaKeyPix.input = self as? PIX & NODEOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}
