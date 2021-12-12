//
//  ReorderPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-07.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class ReorderPIX: PIXMergerEffect, PIXViewable {
    
    override public var shaderName: String { return "effectMergerReorderPIX" }
    
    // MARK: - Public Properties
    
    public enum Input: String, Enumable {
        case first
        case second
        public var index: Int {
            switch self {
            case .first:
                return 0
            case .second:
                return 1
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .first:
                return "First"
            case .second:
                return "Second"
            }
        }
    }
    @LiveEnum("redInput") public var redInput: Input = .first
    @LiveEnum("greenInput") public var greenInput: Input = .first
    @LiveEnum("blueInput") public var blueInput: Input = .first
    @LiveEnum("alphaInput") public var alphaInput: Input = .first
    
    public enum RawChannel {
        case red
        case green
        case blue
        case alpha
    }
    public enum Channel: String, Enumable {
        case red
        case green
        case blue
        case alpha
        case zero
        case one
        case luma
        public var index: Int {
            switch self {
            case .red: return 0
            case .green: return 1
            case .blue: return 2
            case .alpha: return 3
            case .zero: return 4
            case .one: return 5
            case .luma: return 6
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .red: return "Red"
            case .green: return "Green"
            case .blue: return "Blue"
            case .alpha: return "Alpha"
            case .zero: return "Zero"
            case .one: return "One"
            case .luma: return "Luma"
            }
        }
    }
    @LiveEnum("redChannel") public var redChannel: Channel = .red
    @LiveEnum("greenChannel") public var greenChannel: Channel = .green
    @LiveEnum("blueChannel") public var blueChannel: Channel = .blue
    @LiveEnum("alphaChannel") public var alphaChannel: Channel = .alpha
    
    @LiveBool("premultiply") public var premultiply: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_redInput, _redChannel, _greenInput, _greenChannel, _blueInput, _blueChannel, _alphaInput, _alphaChannel, _premultiply] + super.liveList
    }
    
    public override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: [redInput == .first ? 0 : 1, CGFloat(redChannel.index)])
        vals.append(contentsOf: [greenInput == .first ? 0 : 1, CGFloat(greenChannel.index)])
        vals.append(contentsOf: [blueInput == .first ? 0 : 1, CGFloat(blueChannel.index)])
        vals.append(contentsOf: [alphaInput == .first ? 0 : 1, CGFloat(alphaChannel.index)])
        vals.append(premultiply ? 1 : 0)
        vals.append(CGFloat(placement.index))
        return vals
    }
    
    public required init() {
        super.init(name: "Reorder", typeName: "pix-effect-merger-reorder")
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}

public extension NODEOut {
    
    func pixReorder(from channel: ReorderPIX.Channel, to rawChannel: ReorderPIX.RawChannel, pix: () -> (PIX & NODEOut)) -> ReorderPIX {
        pixReorder(pix: pix(), from: channel, to: rawChannel)
    }
    func pixReorder(pix: PIX & NODEOut, from channel: ReorderPIX.Channel, to rawChannel: ReorderPIX.RawChannel) -> ReorderPIX {
        let reorderPix = ReorderPIX()
        reorderPix.name = ":reorder:"
        reorderPix.inputA = self as? PIX & NODEOut
        reorderPix.inputB = pix
        switch rawChannel {
        case .red:
            reorderPix.redInput = .second
            reorderPix.redChannel = channel
        case .green:
            reorderPix.greenInput = .second
            reorderPix.greenChannel = channel
        case .blue:
            reorderPix.blueInput = .second
            reorderPix.blueChannel = channel
        case .alpha:
            reorderPix.alphaInput = .second
            reorderPix.alphaChannel = channel
        }
        return reorderPix
    }
    
    func pixReplace(_ rawChannel: ReorderPIX.RawChannel, with channel: ReorderPIX.Channel) -> ReorderPIX {
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
