//
//  PIXColor.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-08.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public extension PIX {
    
    public class Color: Codable {
        
        public var r: CGFloat
        public var g: CGFloat
        public var b: CGFloat
        public var a: CGFloat
        
        public enum Bits: Int, Codable {
            case _8 = 8
            case _16 = 16
            case _32 = 32
            public var mtl: MTLPixelFormat {
                switch self {
                case ._8: return .bgra8Unorm // rgba8Unorm
                case ._16: return .rgba16Float
                case ._32: return .rgba32Float
                }
            }
            public var ci: CIFormat {
                switch self {
                case ._8: return .RGBA8
                case ._16: return .RGBA16
                case ._32: return .RGBA16 // CHECK
                }
            }
            var os: OSType {
                return kCVPixelFormatType_32BGRA
            }
            public var max: Int {
                return NSDecimalNumber(decimal: pow(2, self.rawValue)).intValue - 1
            }
        }
        
        public enum Space: String, Codable {
            case sRGB
            case displayP3
            public var cg: CGColorSpace {
                switch self {
                case .sRGB:
                    return CGColorSpace(name: CGColorSpace.linearSRGB)! // CHECK non linear extended 16 bit
                case .displayP3:
                    return CGColorSpace(name: CGColorSpace.displayP3)! // CHECK linear extended 16 bit
                }
            }
//            init(_ cg: CGColorSpace) {
//                switch cg.name {
//                case CGColorSpace.sRGB: self = .sRGB
//                case CGColorSpace.extendedSRGB: self = .sRGB
//                case CGColorSpace.linearSRGB: self = .sRGB
//                case CGColorSpace.extendedLinearSRGB: self = .sRGB
//                default: self = .displayP3
//                }
//            }
        }
        
        public let space: Space
        
        public var ui: UIColor {
            switch space {
            case .sRGB:
                return UIColor(red: r, green: g, blue: b, alpha: a)
            case .displayP3:
                return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
            }
        }
        public var ci: CIColor? {
            return CIColor(red: r, green: g, blue: b, alpha: a, colorSpace: space.cg)
        }
        public var cg: CGColor? {
            return CGColor(colorSpace: space.cg, components: list)
        }
        
        public var list: [CGFloat] {
            return [r, g, b, a]
        }
        
        public var lum: CGFloat {
            return (r + g + b) / 3 // CHECK convert to HSV and return value
        }
        
        public var mono: PIX.Color {
            return PIX.Color(UIColor(white: lum, alpha: a))
        }
        
        public init(_ ui: UIColor, space: Space = HxPxE.main.colorSpace) {
            self.space = space
            let ci = CIColor(color: ui)
            r = ci.red
            g = ci.green
            b = ci.blue
            a = ci.alpha
        }
        
        public init(_ pixel: [CGFloat], space: Space = HxPxE.main.colorSpace) {
            self.space = space
            guard pixel.count == 4 else {
                Logger.main.log(.error, nil, "Color: Bad Channel Count: \(pixel.count)")
                r = 0
                g = 0
                b = 0
                a = 1
                return
            }
            switch HxPxE.main.colorBits {
            case ._8:
                // CHECK BGRA Temp Fix
                b = pixel[0]
                g = pixel[1]
                r = pixel[2]
                a = pixel[3]
            case ._16, ._32:
                r = pixel[0]
                g = pixel[1]
                b = pixel[2]
                a = pixel[3]
            }
        }
        
    }
    
}

