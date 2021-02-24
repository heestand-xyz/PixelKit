//
//  ChromaKeyPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import PixelColor

final public class ChromaKeyPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleChromaKeyPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor(name: "Key Color") public var keyColor: PixelColor = .green
    @LiveFloat(name: "Range", range: 0.0...0.5) public var range: CGFloat = 0.1
    @LiveFloat(name: "Softness", range: 0.0...0.5) public var softness: CGFloat = 0.1
    @LiveFloat(name: "Edge Desaturation") public var edgeDesaturation: CGFloat = 0.5
    @LiveFloat(name: "Alpha Crop") public var alphaCrop: CGFloat = 0.5
    @LiveBool(name: "Premultiply") public var premultiply: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_keyColor, _range, _softness, _edgeDesaturation, _alphaCrop, _premultiply]
    }
    
    override public var values: [Floatable] {
        [keyColor, range, softness, edgeDesaturation, alphaCrop, premultiply]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Chroma Key", typeName: "pix-effect-single-chroma-key")
    }
    
}

public extension NODEOut {
    
    func pixChromaKey(_ color: PixelColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.name = ":chromaKey:"
        chromaKeyPix.input = self as? PIX & NODEOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}
