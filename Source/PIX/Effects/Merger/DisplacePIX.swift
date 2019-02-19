//
//  DisplacePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Open Source - MIT License
//

import CoreGraphics//x

public class DisplacePIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    public var distance: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var origin: CGPoint = CGPoint(x: 0.5, y: 0.5) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case distance; case origin
//    }
    
    open override var uniforms: [CGFloat] {
        return [distance, origin.x, origin.y]
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        extend = .hold
    }
    
}

public extension PIXOut {
    
    func _displace(with pix: PIX & PIXOut, distance: CGFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.name = ":displace:"
        displacePix.inPixA = self as? PIX & PIXOut
        displacePix.inPixB = pix
        displacePix.distance = distance
        return displacePix
    }
    
//    func _displaceNoise(distance: CGFloat, octaves: Int) -> DisplacePIX {
//        let noisePix = NoisePIX(res: (self as? PIX & PIXOut)?.resolution ?? ._128)
//        noisePix.name = "displaceNoise:noise"
//        noisePix.colored = true
//        noisePix.octaves = octaves
//        return _displace(with: noisePix, distance: distance)
//    }
    
}
