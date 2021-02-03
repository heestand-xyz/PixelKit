//
//  ChannelMixPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//


import RenderKit
import CoreGraphics
import PixelColor

final public class ChannelMixPIX: PIXSingleEffect, BodyViewRepresentable {
    
    override public var shaderName: String { return "effectSingleChannelMixPIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var red: PixelColor.Channel = .red
    @Live public var green: PixelColor.Channel = .green
    @Live public var blue: PixelColor.Channel = .blue
    @Live public var alpha: PixelColor.Channel = .alpha
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_red, _green, _blue, _alpha]
    }
    
    public override var uniforms: [CGFloat] {
        var uniforms: [CGFloat] = []
        uniforms.append(contentsOf: PixelColor(channel: red).components)
        uniforms.append(contentsOf: PixelColor(channel: green).components)
        uniforms.append(contentsOf: PixelColor(channel: blue).components)
        uniforms.append(contentsOf: PixelColor(channel: alpha).components)
        return uniforms
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Channel Mix", typeName: "pix-effect-single-channel-mix")
    }
    
}

public extension NODEOut {
    
    func pixSwap(_ pureColorA: PixelColor.Channel, _ pureColorB: PixelColor.Channel) -> ChannelMixPIX {
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
