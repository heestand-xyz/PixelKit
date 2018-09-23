//
//  ThresholdPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-17.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func threshold(at threshold: CGFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.inPix = self as? PIX & PIXOut
        thresholdPix.threshold = threshold
        return thresholdPix
    }
    
}

public class ThresholdPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .threshold
    
    override open var shader: String { return "effectSingleThresholdPIX" }
    
    public var threshold: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var smoothness: CGFloat = 0 { didSet { setNeedsRender() } }
    enum EdgeCodingKeys: String, CodingKey {
        case threshold; case smoothness
    }
    open override var uniforms: [CGFloat] {
        return [threshold, smoothness]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
        smoothness = try container.decode(CGFloat.self, forKey: .smoothness)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(smoothness, forKey: .smoothness)
    }
    
}
