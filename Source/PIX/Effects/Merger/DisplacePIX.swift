//
//  DisplacePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

public class DisplacePIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    public var distance: LiveFloat = 1.0
    public var origin: LiveFloat = 0.5
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [distance, origin]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        extend = .hold
    }
    
}

public extension PIXOut {
    
    func _displace(with pix: PIX & PIXOut, distance: LiveFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.name = ":displace:"
        displacePix.inPixA = self as? PIX & PIXOut
        displacePix.inPixB = pix
        displacePix.distance = distance
        return displacePix
    }
    
    func _noiseDisplace(distance: LiveFloat, zPosition: LiveFloat = 0.0, octaves: LiveInt = 10) -> DisplacePIX {
        let pix = self as! PIX & PIXOut
        let noisePix = NoisePIX(res: pix.resolution ?? ._128) // FIXME: with LiveRes
        noisePix.name = "noiseDisplace:noise"
        noisePix.colored = true
        noisePix.zPosition = zPosition
        noisePix.octaves = octaves
        return pix._displace(with: noisePix, distance: distance)
    }
    
}
