//
//  LumaBlurPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

/*public*/ class LumaBlurPIX: PIXMergerEffect, PIXable {
    
    let kind: PIX.Kind = .lumaBlur
    
    override var shader: String { return "lumaBlurPIX" }
    
    public enum Style: Int, Codable {
        case box = 0
        case angle = 1
        case zoom = 2
        case random = 4
        // CHECK make string and add index
    }
    
    public enum Quality: Int, Codable {
        case low = 4
        case mid = 8
        case high = 16
        case extreme = 32
        // CHECK make string and add index
    }
    
    public var style: Style = .box { didSet { setNeedsRender() } }
    public var radius: CGFloat = 10 { didSet { setNeedsRender() } }
    public var quality: Quality = .mid { didSet { setNeedsRender() } }
    public var angle: CGFloat = 0 { didSet { setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsRender() } }
    enum LumaBlurCodingKeys: String, CodingKey {
        case style; case radius; case quality; case angle; case position
    }
    override var shaderUniforms: [CGFloat] {
        return [CGFloat(style.rawValue), radius, CGFloat(quality.rawValue), angle, position.x, position.y]
    }
    
    public override init() {
        super.init()
        extend = .clampToEdge
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    
    public override func encode(to encoder: Encoder) throws {}
    
    
}
