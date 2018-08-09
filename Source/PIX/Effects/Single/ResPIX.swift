//
//  ResPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-03.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ResPIX: PIXSingleEffect, PIXable {

    let kind: HxPxE.PIXKind = .res
    
    public var res: PIX.Res { didSet { setNeedsRes() } }
    
    override var shader: String { return "res" }
    override var shaderNeedsAspect: Bool { return true }

    public override init() {
        self.res = .auto
        super.init()
//        setNeedsRes()
    }

    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
//        let container = try decoder.container(keyedBy: ResolutionCodingKeys.self)
//        let newCustomResolution = try container.decode(CGSize.self, forKey: .customResolution)
//        if customResolution != newCustomResolution {
//            customResolution = newCustomResolution
//            view.setResolution(newCustomResolution)
//        }
//        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
//        let id = UUID(uuidString: try topContainer.decode(String.self, forKey: .id))! // CHECK BANG
//        super.init(id: id)
    }

    override public func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
//        var container = encoder.container(keyedBy: ResolutionCodingKeys.self)
//        try container.encode(customResolution, forKey: .customResolution)
    }

}
