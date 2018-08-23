//
//  BlendsPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-14.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class BlendsPIX: PIXMultiEffect, PIXofaKind {
    
    let kind: PIX.Kind = .blends
    
    override var shader: String { return "effectMultiBlendsPIX" }
    
    public enum BlendingMode: String, Codable {
        case over
        case under
        case add
        case multiply
        case difference
        case subtract
        case maximum
        case minimum
        var index: Int {
            switch self {
            case .over: return 0
            case .under: return 1
            case .add: return 2
            case .multiply: return 3
            case .difference: return 4
            case .subtract: return 5
            case .maximum: return 6
            case .minimum: return 7
            }
        }
    }
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    enum BlendsCodingKeys: String, CodingKey {
        case blendingMode
    }
    override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index)]
    }
    
    public override required init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: BlendsCodingKeys.self)
        blendingMode = try container.decode(BlendingMode.self, forKey: .blendingMode)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BlendsCodingKeys.self)
        try container.encode(blendingMode, forKey: .blendingMode)
    }
    
    
}
