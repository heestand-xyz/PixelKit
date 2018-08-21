//
//  PIXMergerEffect.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-31.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXMergerEffect: PIXEffect, PIXInMerger {
    
    public var inPixA: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    public var inPixB: (PIX & PIXOut)? { didSet { setNeedsConnect() } }
    override var connectedIn: Bool { return pixInList.count == 2 }
    
    public enum FillMode: String, Codable {
        case fill
        case aspectFit
        case aspectFill
        var index: Int {
            switch self {
            case .fill: return 0
            case .aspectFit: return 1
            case .aspectFill: return 2
            }
        }
    }
    
    public var fillMode: FillMode = .aspectFit { didSet { setNeedsRender() } }
    
}
