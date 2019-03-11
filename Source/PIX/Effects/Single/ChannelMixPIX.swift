//
//  ChannelMixPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

public class ChannelMixPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public var red: LiveColor = LiveColor(pure: .red) { didSet { setNeedsRender() } }
    public var green: LiveColor = LiveColor(pure: .green) { didSet { setNeedsRender() } }
    public var blue: LiveColor = LiveColor(pure: .blue) { didSet { setNeedsRender() } }
    public var alpha: LiveColor = LiveColor(pure: .alpha) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [red, green, blue, alpha]
    }
    
}

public extension PIXOut {
    
    func _swap(_ pureColorA: LiveColor.Pure, _ pureColorB: LiveColor.Pure) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "swap:channelMix"
        channelMixPix.inPix = self as? PIX & PIXOut
        switch pureColorA {
        case .red: channelMixPix.red = LiveColor(pure: pureColorB)
        case .green: channelMixPix.green = LiveColor(pure: pureColorB)
        case .blue: channelMixPix.blue = LiveColor(pure: pureColorB)
        case .alpha: channelMixPix.alpha = LiveColor(pure: pureColorB)
        }
        switch pureColorB {
        case .red: channelMixPix.red = LiveColor(pure: pureColorA)
        case .green: channelMixPix.green = LiveColor(pure: pureColorA)
        case .blue: channelMixPix.blue = LiveColor(pure: pureColorA)
        case .alpha: channelMixPix.alpha = LiveColor(pure: pureColorA)
        }
        return channelMixPix
    }
    
}
