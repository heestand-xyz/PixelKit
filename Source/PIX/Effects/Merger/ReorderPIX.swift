//
//  ReorderPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//
import CoreGraphics//x

public class ReorderPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerReorderPIX" }
    
    // MARK: - Public Properties
    
    public enum Input: String, CaseIterable {
        case a = "A"
        case b = "B"
    }
    
    public enum RawChannel {
        case red
        case green
        case blue
        case alpha
    }
    public enum Channel: String, CaseIterable {
        case red = "R"
        case green = "G"
        case blue = "B"
        case alpha = "A"
        case zero = "Zero"
        case one = "One"
        case lum = "Lum"
        var index: Int {
            switch self {
            case .red: return 0
            case .green: return 1
            case .blue: return 2
            case .alpha: return 3
            case .zero: return 4
            case .one: return 5
            case .lum: return 6
            }
        }
    }
    
    public var redInput: Input = .a { didSet { setNeedsRender() } }
    public var redChannel: Channel = .red { didSet { setNeedsRender() } }
    public var greenInput: Input = .a { didSet { setNeedsRender() } }
    public var greenChannel: Channel = .green { didSet { setNeedsRender() } }
    public var blueInput: Input = .a { didSet { setNeedsRender() } }
    public var blueChannel: Channel = .blue { didSet { setNeedsRender() } }
    public var alphaInput: Input = .a { didSet { setNeedsRender() } }
    public var alphaChannel: Channel = .alpha { didSet { setNeedsRender() } }
    public var premultiply: Bool = true { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: [redInput == .a ? 0 : 1, CGFloat(redChannel.index)])
        vals.append(contentsOf: [greenInput == .a ? 0 : 1, CGFloat(greenChannel.index)])
        vals.append(contentsOf: [blueInput == .a ? 0 : 1, CGFloat(blueChannel.index)])
        vals.append(contentsOf: [alphaInput == .a ? 0 : 1, CGFloat(alphaChannel.index)])
        vals.append(premultiply ? 1 : 0)
        vals.append(CGFloat(placement.index))
        return vals
    }
    
}

public extension PIXOut {
    
    func _reorder(with pix: PIX & PIXOut, from channel: ReorderPIX.Channel, to rawChannel: ReorderPIX.RawChannel) -> ReorderPIX {
        let reorderPix = ReorderPIX()
        reorderPix.name = ":reorder:"
        reorderPix.inPixA = self as? PIX & PIXOut
        reorderPix.inPixB = pix
        switch rawChannel {
        case .red:
            reorderPix.redInput = .b
            reorderPix.redChannel = channel
        case .green:
            reorderPix.greenInput = .b
            reorderPix.greenChannel = channel
        case .blue:
            reorderPix.blueInput = .b
            reorderPix.blueChannel = channel
        case .alpha:
            reorderPix.alphaInput = .b
            reorderPix.alphaChannel = channel
        }
        return reorderPix
    }
    
}
