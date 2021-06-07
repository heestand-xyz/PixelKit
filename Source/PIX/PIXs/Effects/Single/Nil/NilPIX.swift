//
//  NilPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-15.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution

final public class NilPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }
    
    let nilOverrideBits: Bits?
    public override var overrideBits: Bits? { nilOverrideBits }
    
    public required init(name: String = "Nil") {
        nilOverrideBits = nil
        super.init(name: name, typeName: "pix-effect-single-nil")
    }
    
    public required init() {
        nilOverrideBits = nil
        super.init(name: "Nil", typeName: "pix-effect-single-nil")
    }
    
    public init(overrideBits: Bits) {
        nilOverrideBits = overrideBits
        super.init(name: "Nil (\(overrideBits.rawValue)bit)", typeName: "pix-effect-single-nil")
    }
    
    // MARK: Codable
    
    enum CodingKeys: CodingKey {
        case nilOverrideBits
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nilOverrideBits = try container.decode(Bits?.self, forKey: .nilOverrideBits)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nilOverrideBits, forKey: .nilOverrideBits)
        try super.encode(to: encoder)
    }
    
}

public extension NODEOut {
    
    /// bypass is `false` by *default*
    func pixNil(bypass: Bool = false) -> NilPIX {
        let nilPix = NilPIX()
        nilPix.name = ":nil:"
        nilPix.input = self as? PIX & NODEOut
        nilPix.bypass = bypass
        return nilPix
    }
    
}
