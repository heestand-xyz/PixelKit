//
//  ThresholdPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-17.
//  Copyright © 2018 Hexagons. All rights reserved.
//
import CoreGraphics//x

public class ThresholdPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleThresholdPIX" }
    
    // MARK: - Public Properties
    
    public var threshold: CGFloat = 0.5 { didSet { setNeedsRender() } }
    public var smooth: Bool = true { didSet { setNeedsRender() } }
    var _smoothness: CGFloat = 0
    public var smoothness: CGFloat {
        set {
            _smoothness = newValue
            setNeedsRender()
        }
        get {
            guard smooth else { return 0.0 }
            return max(_smoothness, 1.0 / pow(2.0, CGFloat(Pixels.main.bits.rawValue)))
        }
    }
    
    // MARK: - Property Helpers
    enum EdgeCodingKeys: String, CodingKey {
        case threshold; case smoothness
    }
    
    open override var uniforms: [CGFloat] {
        return [threshold, smoothness]
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: EdgeCodingKeys.self)
        threshold = try container.decode(CGFloat.self, forKey: .threshold)
        smoothness = try container.decode(CGFloat.self, forKey: .smoothness)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EdgeCodingKeys.self)
        try container.encode(threshold, forKey: .threshold)
        try container.encode(smoothness, forKey: .smoothness)
    }
    
}

public extension PIXOut {
    
    func _threshold(at threshold: CGFloat = 0.5) -> ThresholdPIX {
        let thresholdPix = ThresholdPIX()
        thresholdPix.name = ":threshold:"
        thresholdPix.inPix = self as? PIX & PIXOut
        thresholdPix.threshold = threshold
        return thresholdPix
    }
    
}
