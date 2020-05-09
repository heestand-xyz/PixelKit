//
//  DisplacePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class DisplacePIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    public var distance: LiveFloat = LiveFloat(1.0, max: 2.0)
    public var origin: LiveFloat = 0.5
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [distance, origin]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Displace", typeName: "pix-effect-merger-displace")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func _displace(with pix: PIX & NODEOut, distance: LiveFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.name = ":displace:"
        displacePix.inputA = self as? PIX & NODEOut
        displacePix.inputB = pix
        displacePix.distance = distance
        return displacePix
    }
    
    func _noiseDisplace(distance: LiveFloat, zPosition: LiveFloat = 0.0, octaves: LiveInt = 10) -> DisplacePIX {
        let pix = self as! PIX & NODEOut
        let noisePix = NoisePIX(at: pix.renderResolution)
        noisePix.name = "noiseDisplace:noise"
        noisePix.colored = true
        noisePix.zPosition = zPosition
        noisePix.octaves = octaves
        return pix._displace(with: noisePix, distance: distance)
    }
    
}
