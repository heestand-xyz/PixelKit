//
//  RangePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-06.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public extension PIXOut {
    
    func range(inLow: CGFloat = 0.0, inHigh: CGFloat = 1.0, outLow: CGFloat = 0.0, outHigh: CGFloat = 1.0) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLow = inLow
        rangePix.inHigh = inHigh
        rangePix.outLow = outLow
        rangePix.outHigh = outHigh
        return rangePix
    }
    
    func range(inLow: UIColor = .clear, inHigh: UIColor = .white, outLow: UIColor = .clear, outHigh: UIColor = .white) -> RangePIX {
        let rangePix = RangePIX()
        rangePix.inPix = self as? PIX & PIXOut
        rangePix.inLowColor = inLow
        rangePix.inHighColor = inHigh
        rangePix.outLowColor = outLow
        rangePix.outHighColor = outHigh
        return rangePix
    }
    
}

public class RangePIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .range
    
    override open var shader: String { return "effectSingleRangePIX" }
    
    public var inLow: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var inHigh: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var outLow: CGFloat = 0.0 { didSet { setNeedsRender() } }
    public var outHigh: CGFloat = 1.0 { didSet { setNeedsRender() } }
    public var inLowColor: UIColor = .clear { didSet { setNeedsRender() } }
    public var inHighColor: UIColor = .white { didSet { setNeedsRender() } }
    public var outLowColor: UIColor = .clear { didSet { setNeedsRender() } }
    public var outHighColor: UIColor = .white { didSet { setNeedsRender() } }
    public var ignoreAlpha: Bool = true { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case inLow; case inHigh; case outLow; case outHigh; case inLowColor; case inHighColor; case outLowColor; case outHighColor; case ignoreAlpha
    }
    override var uniforms: [CGFloat] {
        var vals = [inLow, inHigh, outLow, outHigh]
        vals.append(contentsOf: Color(inLowColor).list)
        vals.append(contentsOf: Color(inHighColor).list)
        vals.append(contentsOf: Color(outLowColor).list)
        vals.append(contentsOf: Color(outHighColor).list)
        vals.append(ignoreAlpha ? 1 : 0)
        return vals
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        inLow = try container.decode(CGFloat.self, forKey: .inLow)
        inHigh = try container.decode(CGFloat.self, forKey: .inHigh)
        outLow = try container.decode(CGFloat.self, forKey: .outLow)
        outHigh = try container.decode(CGFloat.self, forKey: .outHigh)
        inLowColor = try container.decode(Color.self, forKey: .inLowColor).ui
        inHighColor = try container.decode(Color.self, forKey: .inHighColor).ui
        outLowColor = try container.decode(Color.self, forKey: .outLowColor).ui
        outHighColor = try container.decode(Color.self, forKey: .outHighColor).ui
        ignoreAlpha = try container.decode(Bool.self, forKey: .ignoreAlpha)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(inLow, forKey: .inLow)
        try container.encode(inHigh, forKey: .inHigh)
        try container.encode(outLow, forKey: .outLow)
        try container.encode(outHigh, forKey: .outHigh)
        try container.encode(Color(inLowColor), forKey: .inLowColor)
        try container.encode(Color(inHighColor), forKey: .inHighColor)
        try container.encode(Color(outLowColor), forKey: .outLowColor)
        try container.encode(Color(outHighColor), forKey: .outHighColor)
        try container.encode(ignoreAlpha, forKey: .ignoreAlpha)
    }
    
}
