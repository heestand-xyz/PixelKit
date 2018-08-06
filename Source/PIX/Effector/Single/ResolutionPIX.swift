//
//  ResolutionPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-03.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ResolutionPIX: PIXSingleEffector, PIXable {
    
    let kind: HxPxE.PIXKind = .resolution
    
    public var customResolution = CGSize(width: 128, height: 128) { didSet { view.setResolution(customResolution) } }
    enum ResolutionCodingKeys: String, CodingKey {
        case customResolution
    }
    
    override public init() {
        super.init()
        view.setResolution(customResolution)
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: ResolutionCodingKeys.self)
        let newCustomResolution = try container.decode(CGSize.self, forKey: .customResolution)
        if customResolution != newCustomResolution {
            customResolution = newCustomResolution
            view.setResolution(newCustomResolution)
        }
//        let topContainer = try decoder.container(keyedBy: CodingKeys.self)
//        let id = UUID(uuidString: try topContainer.decode(String.self, forKey: .id))! // CHECK BANG
//        super.init(id: id)
    }
    
    override public func encode(to encoder: Encoder) throws {
//        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ResolutionCodingKeys.self)
        try container.encode(customResolution, forKey: .customResolution)
    }
    
}
