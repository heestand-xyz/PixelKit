//
//  PIXModes.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import MetalPerformanceShaders

extension PIX {
    
    public enum Placement: String, Codable, CaseIterable {
        case fill
        case aspectFit
        case aspectFill
        case custom
        var index: Int {
            switch self {
            case .fill: return 0
            case .aspectFit: return 1
            case .aspectFill: return 2
            case .custom: return 3
            }
        }
    }
    
    public enum BlendingMode: String, Codable, CaseIterable {
        case over
        case under
        case add
        case multiply
        case difference
        case subtractWithAlpha
        case subtract
        case maximum
        case minimum
        case gamma
        case power
        case divide
        case average
        case cosine
        case inside
//        case insideDestination
        case outside
//        case outsideDestination
        case exclusiveOr
        var index: Int {
            switch self {
            case .over: return 0
            case .under: return 1
            case .add: return 2
            case .multiply: return 3
            case .difference: return 4
            case .subtractWithAlpha: return 5
            case .subtract: return 6
            case .maximum: return 7
            case .minimum: return 8
            case .gamma: return 9
            case .power: return 10
            case .divide: return 11
            case .average: return 12
            case .cosine: return 13
            case .inside: return 14
//            case .insideDestination: return 15
            case .outside: return 15
//            case .outsideDestination: return 17
            case .exclusiveOr: return 16
            }
        }
    }
    
    public enum InterpolateMode: String, Codable {
        case nearest
        case linear
        var mtl: MTLSamplerMinMagFilter {
            switch self {
            case .nearest: return .nearest
            case .linear: return .linear
            }
        }
    }
    
    public enum ExtendMode: String, Codable, CaseIterable {
        case hold
        case zero
        case loop
        case mirror
        var mtl: MTLSamplerAddressMode {
            switch self {
            case .hold: return .clampToEdge
            case .zero: return .clampToZero
            case .loop: return .repeat
            case .mirror: return .mirrorRepeat
            }
        }
        var mps: MPSImageEdgeMode? {
            switch self {
            case .zero:
                if #available(OSX 10.13, *) {
                    return .zero
                } else {
                    return nil
                }
            default:
                if #available(OSX 10.13, *) {
                    return .clamp
                } else {
                    return nil
                }
            }
        }
        var index: Int {
            switch self {
            case .hold: return 0
            case .zero: return 1
            case .loop: return 2
            case .mirror: return 3
            }
        }
    }
    
    public enum SampleQualityMode: Int, Codable, CaseIterable {
        case low = 4
        case mid = 8
        case high = 16
        case extreme = 32
        case insane = 64
        case epic = 128
    }
    
}
