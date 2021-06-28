//
//  ChannelMixPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class ChannelMixPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public enum Channel: String, Enumable {
        case red
        case green
        case blue
        case alpha
        case clear
        public var index: Int {
            switch self {
            case .red: return 0
            case .green: return 1
            case .blue: return 2
            case .alpha: return 3
            case .clear: return 4
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .red: return "Red"
            case .green: return "Green"
            case .blue: return "Blue"
            case .alpha: return "Alpha"
            case .clear: return "Clear"
            }
        }
        var color: PixelColor {
            switch self {
            case .red:
                return PixelColor(channel: .red)
            case .green:
                return PixelColor(channel: .green)
            case .blue:
                return PixelColor(channel: .red)
            case .alpha:
                return PixelColor(channel: .alpha)
            case .clear:
                return .clear
            }
        }
    }
    
    @LiveEnum("red") public var red: Channel = .red
    @LiveEnum("green") public var green: Channel = .green
    @LiveEnum("blue") public var blue: Channel = .blue
    @LiveEnum("alpha") public var alpha: Channel = .alpha
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_red, _green, _blue, _alpha]
    }
    
    public override var uniforms: [CGFloat] {
        var uniforms: [CGFloat] = []
        uniforms.append(contentsOf: red.color.components)
        uniforms.append(contentsOf: green.color.components)
        uniforms.append(contentsOf: blue.color.components)
        uniforms.append(contentsOf: alpha.color.components)
        return uniforms
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Channel Mix", typeName: "pix-effect-single-channel-mix")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    /// Swap supprts the **rgba** channels. The **clear** channel will be ignored.
    func pixSwap(_ channelA: ChannelMixPIX.Channel, _ channelB: ChannelMixPIX.Channel) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "swap:channelMix"
        channelMixPix.input = self as? PIX & NODEOut
        switch channelA {
        case .red: channelMixPix.red = channelB
        case .green: channelMixPix.green = channelB
        case .blue: channelMixPix.blue = channelB
        case .alpha: channelMixPix.alpha = channelB
        default: break
        }
        switch channelB {
        case .red: channelMixPix.red = channelA
        case .green: channelMixPix.green = channelA
        case .blue: channelMixPix.blue = channelA
        case .alpha: channelMixPix.alpha = channelA
        default: break
        }
        return channelMixPix
    }
    
}
