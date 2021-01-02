//
//  ChromaKeyPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit

public class ChromaKeyPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleChromaKeyPIX" }
    
    // MARK: - Public Properties
    
    public var keyColor: PXColor = .green
    public var range: CGFloat = CGFloat(0.1, min: 0.0, max: 0.5)
    public var softness: CGFloat = CGFloat(0.1, min: 0.0, max: 0.5)
    public var edgeDesaturation: CGFloat = 0.5
    public var alphaCrop: CGFloat = 0.5
    public var premultiply: LiveBool = true
    
    // MARK: - Property Helpers
    
    override public var values: [CoreValue] {
        return [keyColor, range, softness, edgeDesaturation, alphaCrop, premultiply]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Chroma Key", typeName: "pix-effect-single-chroma-key")
    }
    
}

public extension NODEOut {
    
    func _chromaKey(_ color: PXColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.name = ":chromaKey:"
        chromaKeyPix.input = self as? PIX & NODEOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}
