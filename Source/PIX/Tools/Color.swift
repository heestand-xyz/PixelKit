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
        
        public let r: CGFloat
        public let g: CGFloat
        public let b: CGFloat
        public let a: CGFloat
        
        public enum Bits: Int, Codable {
            case _8 = 8
            case _16 = 16
            public var mtl: MTLPixelFormat {
                switch self {
                case ._8: return .bgra8Unorm // rgba8Unorm
                case ._16: return .rgba16Float
                }
            }
            public var ci: CIFormat {
                switch self {
                case ._8: return .RGBA8
                case ._16: return .RGBA16
                }
            }
            var cam: OSType {
                return kCVPixelFormatType_32BGRA
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
            return (r + g + b) / 3
        }
        
        public var mono: PIX.Color {
            return PIX.Color(UIColor(white: lum, alpha: a))
        }
        
        public init(_ ui: UIColor, space: Space = HxPxE.main.colorSpace) {
            let ci = CIColor(color: ui)
            r = ci.red
            g = ci.green
            b = ci.blue
            a = ci.alpha
            self.space = space
        }
        
        public init(_ pixel: [CGFloat], space: Space = HxPxE.main.colorSpace) {
            r = pixel.count > 0 ? pixel[0] : 0
            g = pixel.count > 1 ? pixel[1] : 0
            b = pixel.count > 2 ? pixel[2] : 0
            a = pixel.count > 3 ? pixel[3] : 0
            self.space = space
        }
        
    }
    
}

