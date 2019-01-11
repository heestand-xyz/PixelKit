//
//  QuantizePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//
import CoreGraphics//x

public class QuantizePIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleQuantizePIX" }
    
    // MARK: - Public Properties
    
    public var fraction: CGFloat = 0.125 { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum QuantizeCodingKeys: String, CodingKey {
//        case fraction
//    }
    
    open override var uniforms: [CGFloat] {
        return [fraction]
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: QuantizeCodingKeys.self)
//        fraction = try container.decode(CGFloat.self, forKey: .fraction)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: QuantizeCodingKeys.self)
//        try container.encode(fraction, forKey: .fraction)
//    }
    
}

public extension PIXOut {
    
    func _quantize(by fraction: CGFloat) -> QuantizePIX {
        let quantizePix = QuantizePIX()
        quantizePix.name = ":quantize:"
        quantizePix.inPix = self as? PIX & PIXOut
        quantizePix.fraction = fraction
        return quantizePix
    }
    
}
