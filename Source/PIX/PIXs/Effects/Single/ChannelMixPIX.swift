//
//  ChannelMixPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics

public class ChannelMixPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public var red: PXColor.Pure = .red { didSet { setNeedsRender() } }
    public var green: PXColor.Pure = .green { didSet { setNeedsRender() } }
    public var blue: PXColor.Pure = .blue { didSet { setNeedsRender() } }
    public var alpha: PXColor.Pure = .alpha { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        var uniforms: [CGFloat] = []
        uniforms.append(contentsOf: PXColor(pure: red).uniformList)
        uniforms.append(contentsOf: PXColor(pure: green).uniformList)
        uniforms.append(contentsOf: PXColor(pure: blue).uniformList)
        uniforms.append(contentsOf: PXColor(pure: alpha).uniformList)
        return uniforms
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Channel Mix", typeName: "pix-effect-single-channel-mix")
    }
    
}

public extension NODEOut {
    
    func _swap(_ pureColorA: PXColor.Pure, _ pureColorB: PXColor.Pure) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "swap:channelMix"
        channelMixPix.input = self as? PIX & NODEOut
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
