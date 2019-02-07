//
//  CrossPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-21.
//  Open Source - MIT License
//

public class CrossPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerCrossPIX" }
    
    // MARK: - Public Properties
    
    public var fraction: LiveFloat = 0.5
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [fraction]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case fraction
//    }
    
//    open override var uniforms: [CGFloat] {
//        return [fraction]
//    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        fraction = try container.decode(CGFloat.self, forKey: .fraction)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(fraction, forKey: .fraction)
//    }
    
}

func cross(_ pixA: PIX & PIXOut, _ pixB: PIX & PIXOut, at fraction: LiveFloat) -> CrossPIX {
    let crossPix = CrossPIX()
    crossPix.name = ":cross:"
    crossPix.inPixA = pixA
    crossPix.inPixB = pixB
    crossPix.fraction = fraction
    return crossPix
}
