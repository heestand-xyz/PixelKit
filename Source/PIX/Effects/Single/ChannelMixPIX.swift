//
//  ChannelMixPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics

public class ChannelMixPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public var red: LiveColor.Pure = .red { didSet { setNeedsRender() } }
    public var green: LiveColor.Pure = .green { didSet { setNeedsRender() } }
    public var blue: LiveColor.Pure = .blue { didSet { setNeedsRender() } }
    public var alpha: LiveColor.Pure = .alpha { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        var uniforms: [CGFloat] = []
        uniforms.append(contentsOf: LiveColor(pure: red).uniformList)
        uniforms.append(contentsOf: LiveColor(pure: green).uniformList)
        uniforms.append(contentsOf: LiveColor(pure: blue).uniformList)
        uniforms.append(contentsOf: LiveColor(pure: alpha).uniformList)
        return uniforms
    }
    
}

public extension PIXOut {
    
    func _swap(_ pureColorA: LiveColor.Pure, _ pureColorB: LiveColor.Pure) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "swap:channelMix"
        channelMixPix.inPix = self as? PIX & PIXOut
        switch pureColorA {
        case .red: channelMixPix.red = pureColorB
        case .green: channelMixPix.green = pureColorB
        case .blue: channelMixPix.blue = pureColorB
        case .alpha: channelMixPix.alpha = pureColorB
        }
        switch pureColorB {
        case .red: channelMixPix.red = pureColorA
        case .green: channelMixPix.green = pureColorA
        case .blue: channelMixPix.blue = pureColorA
        case .alpha: channelMixPix.alpha = pureColorA
        }
        return channelMixPix
    }
    
}
