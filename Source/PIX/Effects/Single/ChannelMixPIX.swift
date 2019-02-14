//
//  ChannelMixPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class ChannelMixPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleChannelMixPIX" }
    
    // MARK: - Public Properties
    
    public var red: LiveColor = LiveColor(pure: .red) { didSet { setNeedsRender() } }
    public var green: LiveColor = LiveColor(pure: .green) { didSet { setNeedsRender() } }
    public var blue: LiveColor = LiveColor(pure: .blue) { didSet { setNeedsRender() } }
    public var alpha: LiveColor = LiveColor(pure: .alpha) { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum ChannelMixCodingKeys: String, CodingKey {
//        case red; case green; case blue; case alpha
//    }
    
    open override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: red.list)
        vals.append(contentsOf: green.list)
        vals.append(contentsOf: blue.list)
        vals.append(contentsOf: alpha.list)
        return vals
    }
    
}

public extension PIXOut {
    
    func _swap(_ pureColorA: LiveColor.Pure, _ pureColorB: LiveColor.Pure) -> ChannelMixPIX {
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
