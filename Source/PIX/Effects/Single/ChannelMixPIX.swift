//
//  ChannelMixPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class ChannelMixPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .channelMix
    
    override open var shader: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public var red: Color = Color(pure: .red) { didSet { setNeedsRender() } }
    public var green: Color = Color(pure: .green) { didSet { setNeedsRender() } }
    public var blue: Color = Color(pure: .blue) { didSet { setNeedsRender() } }
    public var alpha: Color = Color(pure: .alpha) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    enum ChannelMixCodingKeys: String, CodingKey {
        case red; case green; case blue; case alpha
    }
    
    open override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: red.list)
        vals.append(contentsOf: green.list)
        vals.append(contentsOf: blue.list)
        vals.append(contentsOf: alpha.list)
        return vals
    }
    
    // MARK: - JSON
    
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

public extension PIXOut {
    
    func _swap(_ pureColorA: PIX.Color.Pure, _ pureColorB: PIX.Color.Pure) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "swap:channelMix"
        channelMixPix.inPix = self as? PIX & PIXOut
        switch pureColorA {
        case .red: channelMixPix.red = .init(pure: pureColorB)
        case .green: channelMixPix.green = .init(pure: pureColorB)
        case .blue: channelMixPix.blue = .init(pure: pureColorB)
        case .alpha: channelMixPix.alpha = .init(pure: pureColorB)
        }
        switch pureColorB {
        case .red: channelMixPix.red = .init(pure: pureColorA)
        case .green: channelMixPix.green = .init(pure: pureColorA)
        case .blue: channelMixPix.blue = .init(pure: pureColorA)
        case .alpha: channelMixPix.alpha = .init(pure: pureColorA)
        }
        return channelMixPix
    }
    
}
