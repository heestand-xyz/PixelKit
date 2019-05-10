//
//  PIXModes.swift
//  PixelKit
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
        case addWithAlpha
        case multiply
        case difference
        case subtract
        case subtractWithAlpha
        case maximum
        case minimum
        case gamma
        case power
        case divide
        case average
        case cosine
        case inside
        case outside
        case exclusiveOr
        var index: Int {
            switch self {
            case .over: return 0
            case .under: return 1
            case .add: return 2
            case .addWithAlpha: return 3
            case .multiply: return 4
            case .difference: return 5
            case .subtract: return 6
            case .subtractWithAlpha: return 7
            case .maximum: return 8
            case .minimum: return 9
            case .gamma: return 10
            case .power: return 11
            case .divide: return 12
            case .average: return 13
            case .cosine: return 14
            case .inside: return 15
            case .outside: return 16
            case .exclusiveOr: return 17
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
