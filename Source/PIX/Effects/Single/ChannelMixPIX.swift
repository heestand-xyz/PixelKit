//
//  ChannelMixPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class ChannelMixPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .channelMix
    
    override var shader: String { return "effectSingleChannelMixPIX" }
    
    public var red: Color = Color(pure: .red) { didSet { setNeedsRender() } }
    public var green: Color = Color(pure: .green) { didSet { setNeedsRender() } }
    public var blue: Color = Color(pure: .blue) { didSet { setNeedsRender() } }
    public var alpha: Color = Color(pure: .alpha) { didSet { setNeedsRender() } }
    enum ChannelMixCodingKeys: String, CodingKey {
        case red; case green; case blue; case alpha
    }
    override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: red.list)
        vals.append(contentsOf: green.list)
        vals.append(contentsOf: blue.list)
        vals.append(contentsOf: alpha.list)
        return vals
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: ChannelMixCodingKeys.self)
        red = try container.decode(Color.self, forKey: .red)
        green = try container.decode(Color.self, forKey: .green)
        blue = try container.decode(Color.self, forKey: .blue)
        alpha = try container.decode(Color.self, forKey: .alpha)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChannelMixCodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
    
}
