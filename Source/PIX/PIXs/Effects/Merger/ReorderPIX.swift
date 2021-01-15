//
//  ReorderPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

public class ReorderPIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerReorderPIX" }
    
    // MARK: - Public Properties
    
    public enum Input: Int, CaseIterable, Floatable {
        case a
        case b
        public var floats: [CGFloat] { [CGFloat(rawValue)] }
    }
    
    public enum RawChannel {
        case red
        case green
        case blue
        case alpha
    }
    public enum Channel: String, CaseIterable, Floatable {
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
        public var floats: [CGFloat] { [CGFloat(index)] }
    }
    
    @Live public var redInput: Input = .a
    @Live public var redChannel: Channel = .red
    @Live public var greenInput: Input = .a
    @Live public var greenChannel: Channel = .green
    @Live public var blueInput: Input = .a
    @Live public var blueChannel: Channel = .blue
    @Live public var alphaInput: Input = .a
    @Live public var alphaChannel: Channel = .alpha
    @Live public var premultiply: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_redInput, _redChannel, _greenInput, _greenChannel, _blueInput, _blueChannel, _alphaInput, _alphaChannel, _premultiply] + super.liveList
    }
    
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
    
    public required init() {
        super.init(name: "Reorder", typeName: "pix-effect-merger-reorder")
        premultiply = false
    }
    
}

public extension NODEOut {
    
    func reorder(with pix: PIX & NODEOut, from channel: ReorderPIX.Channel, to rawChannel: ReorderPIX.RawChannel) -> ReorderPIX {
        let reorderPix = ReorderPIX()
        reorderPix.name = ":reorder:"
        reorderPix.inputA = self as? PIX & NODEOut
        reorderPix.inputB = pix
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
    
    func replace(_ rawChannel: ReorderPIX.RawChannel, with channel: ReorderPIX.Channel) -> ReorderPIX {
        let reorderPix = ReorderPIX()
        reorderPix.name = ":reorder:"
        reorderPix.inputA = self as? PIX & NODEOut
        reorderPix.inputB = self as? PIX & NODEOut
        switch rawChannel {
        case .red:
            reorderPix.redChannel = channel
        case .green:
            reorderPix.greenChannel = channel
        case .blue:
            reorderPix.blueChannel = channel
        case .alpha:
            reorderPix.alphaChannel = channel
        }
        return reorderPix
    }
    
}
