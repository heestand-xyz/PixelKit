//
//  DisplacePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class DisplacePIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .displace
    
    override open var shader: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    public var distance: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var origin: CGPoint = CGPoint(x: 0.5, y: 0.5) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case distance; case origin
    }
    
    open override var uniforms: [CGFloat] {
        return [distance, origin.x, origin.y]
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        extend = .hold
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        distance = try container.decode(CGFloat.self, forKey: .distance)
        origin = try container.decode(CGPoint.self, forKey: .origin)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(distance, forKey: .distance)
        try container.encode(origin, forKey: .origin)
    }
    
    
}

public extension PIXOut {
    
    func _displace(pix: PIX & PIXOut, distance: CGFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.inPixA = self as? PIX & PIXOut
        displacePix.inPixB = pix
        displacePix.distance = distance
        return displacePix
    }
    
}
