//
//  PIXModes.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
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
    
}
