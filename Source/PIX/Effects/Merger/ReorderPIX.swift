//
//  ReorderPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class ReorderPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerReorderPIX" }
    
    // MARK: - Public Properties
    
    public enum Input: String, Codable {
        case a
        case b
    }
    
    public enum RawChannel {
        case red
        case green
        case blue
        case alpha
    }
    public enum Channel: String, Codable {
        case red
        case green
        case blue
        case alpha
        case zero
        case one
        case lum
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
    
//    enum CodingKeys: String, CodingKey {
//        case redInput; case redChannel; case greenInput; case greenChannel; case blueInput; case blueChannel; case alphaInput; case alphaChannel; case premultiply
//    }
    
    open override var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: [redInput == .a ? 0 : 1, CGFloat(redChannel.index)])
        vals.append(contentsOf: [greenInput == .a ? 0 : 1, CGFloat(greenChannel.index)])
        vals.append(contentsOf: [blueInput == .a ? 0 : 1, CGFloat(blueChannel.index)])
        vals.append(contentsOf: [alphaInput == .a ? 0 : 1, CGFloat(alphaChannel.index)])
        vals.append(premultiply ? 1 : 0)
        vals.append(CGFloat(fillMode.index))
        return vals
    }
        
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        redInput = try container.decode(Input.self, forKey: .redInput)
//        redChannel = try container.decode(Channel.self, forKey: .redChannel)
//        greenInput = try container.decode(Input.self, forKey: .greenInput)
//        greenChannel = try container.decode(Channel.self, forKey: .greenChannel)
//        blueInput = try container.decode(Input.self, forKey: .blueInput)
//        blueChannel = try container.decode(Channel.self, forKey: .blueChannel)
//        alphaInput = try container.decode(Input.self, forKey: .alphaInput)
//        alphaChannel = try container.decode(Channel.self, forKey: .alphaChannel)
//        premultiply = try container.decode(Bool.self, forKey: .premultiply)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(redInput, forKey: .redInput)
//        try container.encode(redChannel, forKey: .redChannel)
//        try container.encode(greenInput, forKey: .greenInput)
//        try container.encode(greenChannel, forKey: .greenChannel)
//        try container.encode(blueInput, forKey: .blueInput)
//        try container.encode(blueChannel, forKey: .blueChannel)
//        try container.encode(alphaInput, forKey: .alphaInput)
//        try container.encode(alphaChannel, forKey: .alphaChannel)
//        try container.encode(premultiply, forKey: .premultiply)
//    }
    
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
