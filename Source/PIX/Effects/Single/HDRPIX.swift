//
//  HDRPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-10-14.
//  Copyright © 2018 Hexagons. All rights reserved.
//

//import CoreGraphics
//
//public class HDRPIX: PIXSingleEffect, PIXofaKind {
//    
//    let kind: PIX.Kind = .hdr
//    
//    override open var shader: String { return "effectSingleHDRPIX" }
//    
//    enum DistType: Int, Codable {
//        case narrow = 16
//        case broad = 64
//    }
//    
//    var distType: DistType { didSet { setNeedsRender() } }
//    enum LevelsCodingKeys: String, CodingKey {
//        case distType
//    }
//    var sampleRes: Res {
//        return
//    }
//    open override var uniforms: [CGFloat] {
//        return [sampleRes.width, sampleRes.height]
//    }
//    
//    
//    
//    public init(distType: DistType = .narrow) {
//        self.distType = distType
//        super.init()
//    }
//    
//    // MARK: JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: LevelsCodingKeys.self)
//        distType = try container.decode(CGFloat.self, forKey: .distType)
//        setNeedsRender()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: LevelsCodingKeys.self)
//        try container.encode(distType, forKey: .distType)
//    }
//    
//}
