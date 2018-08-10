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
        
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
        
        public enum Bits: Int, Codable {
            case _8 = 8
            case _16 = 16
            var mtl: MTLPixelFormat {
                switch self {
                case ._8: return .bgra8Unorm // rgba8Unorm
                case ._16: return .rgba16Float
                }
            }
            var ci: CIFormat {
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
            var cg: CGColorSpace {
                switch self {
                case .sRGB:
                    return CGColorSpace(name: CGColorSpace.linearSRGB)! // CHECK extended 16 bit
                case .displayP3:
                    return CGColorSpace(name: CGColorSpace.displayP3)! // CHECK not linear // CHECK extended 16 bit
                }
            }
        }
        
        let space: Space
        
        var ui: UIColor {
            switch space {
            case .sRGB:
                return UIColor(red: r, green: g, blue: b, alpha: a)
            case .displayP3:
                return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
            }
        }
        
        var list: [CGFloat] {
            return [r, g, b, a]
        }
        
        init(_ uiColor: UIColor, space: Space = HxPxE.main.colorSpace) {
            let ciColor = CIColor(color: uiColor)
            r = ciColor.red
            g = ciColor.green
            b = ciColor.blue
            a = ciColor.alpha
            self.space = space
        }
        
    }
    
}

