//
//  PIXColor.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-08.
//  Copyright © 2018 Hexagons. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
typealias _Color = UIColor
#elseif os(macOS)
typealias _Color = NSColor
#endif
public extension _Color {
    var pixColor: PIX.Color {
        return PIX.Color(self)
    }
}

public extension PIX {
    
    public class Color: Codable {
        
        public var r: CGFloat
        public var g: CGFloat
        public var b: CGFloat
        public var a: CGFloat
        
        public static var clear: Color      { return Color(r: 0.0, g: 0.0, b: 0.0, a: 0.0) }
        
        public static var white: Color      { return Color(r: 1.0, g: 1.0, b: 1.0) }
        public static var gray: Color       { return Color(r: 0.5, g: 0.5, b: 0.5) }
        public static var black: Color      { return Color(r: 0.0, g: 0.0, b: 0.0) }
        
        public static var red: Color        { return Color(r: 1.0, g: 0.0, b: 0.0) }
        public static var yellow: Color     { return Color(r: 1.0, g: 1.0, b: 0.0) }
        public static var green: Color      { return Color(r: 0.0, g: 1.0, b: 0.0) }
        public static var cyan: Color       { return Color(r: 0.0, g: 1.0, b: 1.0) }
        public static var blue: Color       { return Color(r: 0.0, g: 0.0, b: 1.0) }
        public static var magenta: Color    { return Color(r: 1.0, g: 0.0, b: 1.0) }
        
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
            var osARGB: OSType {
                return kCVPixelFormatType_32ARGB
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
                    return CGColorSpace(name: CGColorSpace.sRGB)! // CHECK non linear extended 16 bit
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
        
        var _color: _Color {
            #if os(iOS)
            return uiColor
            #elseif os(macOS)
            return nsColor
            #endif
        }
        #if os(iOS)
        public var uiColor: UIColor {
            switch space {
            case .sRGB:
                return UIColor(red: r, green: g, blue: b, alpha: a)
            case .displayP3:
                return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
            }
        }
        #elseif os(macOS)
        public var nsColor: NSColor {
            switch space {
            case .sRGB:
                return NSColor(red: r, green: g, blue: b, alpha: a)
            case .displayP3:
                return NSColor(displayP3Red: r, green: g, blue: b, alpha: a)
            }
        }
        #endif
            
        public var ciColor: CIColor? {
            return CIColor(red: r, green: g, blue: b, alpha: a, colorSpace: space.cg)
        }
        public var cgColor: CGColor? {
            return CGColor(colorSpace: space.cg, components: list)
        }
        
        public var list: [CGFloat] {
            return [r, g, b, a]
        }
        
        public var lum: CGFloat {
            return (r + g + b) / 3 // CHECK convert to HSV and return value
        }
        
        public var mono: Color {
            return Color(r: lum, g: lum, b: lum, a: a, space: space)
        }
        
        // MARK: - RGB
        
        public init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1, space: Space = Pixels.main.colorSpace) {
            self.space = space
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
        
        public init(r255: Int, g255: Int, b255: Int, a255: Int = 255, space: Space = Pixels.main.colorSpace) {
            self.r = CGFloat(r255) / 255
            self.g = CGFloat(g255) / 255
            self.b = CGFloat(b255) / 255
            self.a = CGFloat(a255) / 255
            self.space = space
        }
        
        // MARK: - UI
        
        #if os(iOS)
        public init(_ ui: UIColor, space: Space = Pixels.main.colorSpace) {
            let ci = CIColor(color: ui)
            r = ci.red
            g = ci.green
            b = ci.blue
            a = ci.alpha
            self.space = space
        }
        #endif

        // MARK: - NS
        
        #if os(macOS)
        public init(_ ns: NSColor, space: Space = Pixels.main.colorSpace) {
            let ci = CIColor(color: ns)
            r = ci?.red ?? 0.0
            g = ci?.green ?? 0.0
            b = ci?.blue ?? 0.0
            a = ci?.alpha ?? 0.0
            self.space = space
        }
        #endif
        
        // MARK: - Grayscale
        
        public init(lum: CGFloat) {
            self.space = Pixels.main.colorSpace
            self.r = lum
            self.g = lum
            self.b = lum
            self.a = 1.0
        }
        
        public init(val: CGFloat) {
            self.space = Pixels.main.colorSpace
            self.r = val
            self.g = val
            self.b = val
            self.a = val
        }
        
        // MARK: - Hex
        
        public var hex: String {
            let hexInt: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
            return String(format:"#%06x", hexInt)
        }
        
        public init(hex: String, a: CGFloat = 1, space: Space = Pixels.main.colorSpace) {
            
            var hex = hex
            if hex[0..<1] == "#" {
                if hex.count == 4 {
                    hex = hex[1..<4]
                } else {
                    hex = hex[1..<7]
                }
            }
            if hex.count == 3 {
                let r = hex[0..<1]
                let g = hex[1..<2]
                let b = hex[2..<3]
                hex = r + r + g + g + b + b
            }
            
            var hexInt: UInt32 = 0
            let scanner: Scanner = Scanner(string: hex)
            scanner.scanHexInt32(&hexInt)
            
            self.r = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
            self.g = CGFloat((hexInt & 0xff00) >> 8) / 255.0
            self.b = CGFloat((hexInt & 0xff) >> 0) / 255.0
            self.a = a
            
            self.space = space
            
        }
        
        // MARK: - Pixel
        
        init(_ pixel: [CGFloat], space: Space = Pixels.main.colorSpace) {
            self.space = space
            guard pixel.count == 4 else {
                Pixels.main.log(.error, nil, "Color: Bad Channel Count: \(pixel.count)")
                r = 0
                g = 0
                b = 0
                a = 1
                return
            }
            switch Pixels.main.colorBits {
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
        
        // MARK: - Pure
        
        public enum Pure {
            case red
            case green
            case blue
            case alpha
            var color: Color {
                switch self {
                case .red: return   Color(r: 1.0, g: 0.0, b: 0.0, a: 0.0)
                case .green: return Color(r: 0.0, g: 1.0, b: 0.0, a: 0.0)
                case .blue: return  Color(r: 0.0, g: 0.0, b: 1.0, a: 0.0)
                case .alpha: return Color(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
                }
            }
        }
        
        public var isPure: Bool {
            let oneCount = (r == 1 ? 1 : 0) + (g == 1 ? 1 : 0) + (b == 1 ? 1 : 0) + (a == 1 ? 1 : 0)
            let zeroCount = (r == 0 ? 1 : 0) + (g == 0 ? 1 : 0) + (b == 0 ? 1 : 0) + (a == 0 ? 1 : 0)
            return oneCount == 1 && zeroCount == 3
        }
        
        public var pure: Pure? {
            guard isPure else { return nil }
            if r == 1 {
                return .red
            } else if g == 1 {
                return .green
            } else if b == 1 {
                return .blue
            } else if a == 1 {
                return .alpha
            } else { return nil }
        }
        
        public init(pure: Pure) {
            r = 0
            g = 0
            b = 0
            a = 0
            switch pure {
            case .red:
                r = 1
            case .green:
                g = 1
            case .blue:
                b = 1
            case .alpha:
                a = 1
            }
            space = Pixels.main.colorSpace
        }
        
        // MARK: - Functions
        
        public func withAlpha(_ alpha: CGFloat) -> Color {
            a = alpha
            return self
        }
        
        // MARK: - Operator Overloads
        
        public static func ==(lhs: Color, rhs: Color) -> Bool {
            return lhs.r == rhs.r &&
                   lhs.g == rhs.g &&
                   lhs.b == rhs.b &&
                   lhs.a == rhs.a
        }
        public static func !=(lhs: Color, rhs: Color) -> Bool {
            return !(lhs == rhs)
        }
        
        public static func >(lhs: Color, rhs: Color) -> Bool {
            return lhs.lum > rhs.lum
        }
        public static func <(lhs: Color, rhs: Color) -> Bool {
            return lhs.lum < rhs.lum
        }
        public static func >=(lhs: Color, rhs: Color) -> Bool {
            return lhs.lum >= rhs.lum
        }
        public static func <=(lhs: Color, rhs: Color) -> Bool {
            return lhs.lum <= rhs.lum
        }
        
        public static func +(lhs: Color, rhs: Color) -> Color {
            return Color(
                r: lhs.r + rhs.r,
                g: lhs.g + rhs.g,
                b: lhs.b + rhs.b,
                a: lhs.a + rhs.a,
                space: lhs.space)
        }
        public static func -(lhs: Color, rhs: Color) -> Color {
            return Color(
                r: lhs.r - rhs.r,
                g: lhs.g - rhs.g,
                b: lhs.b - rhs.b,
                a: lhs.a - rhs.a,
                space: lhs.space)
        }
        public static func *(lhs: Color, rhs: Color) -> Color {
            return Color(
                r: lhs.r * rhs.r,
                g: lhs.g * rhs.g,
                b: lhs.b * rhs.b,
                a: lhs.a * rhs.a,
                space: lhs.space)
        }
        
        public static func +(lhs: Color, rhs: CGFloat) -> Color {
            return Color(
                r: lhs.r + rhs,
                g: lhs.g + rhs,
                b: lhs.b + rhs,
                a: lhs.a + rhs,
                space: lhs.space)
        }
        public static func -(lhs: Color, rhs: CGFloat) -> Color {
            return Color(
                r: lhs.r - rhs,
                g: lhs.g - rhs,
                b: lhs.b - rhs,
                a: lhs.a - rhs,
                space: lhs.space)
        }
        public static func *(lhs: Color, rhs: CGFloat) -> Color {
            return Color(
                r: lhs.r * rhs,
                g: lhs.g * rhs,
                b: lhs.b * rhs,
                a: lhs.a * rhs,
                space: lhs.space)
        }
        public static func /(lhs: Color, rhs: CGFloat) -> Color {
            guard rhs != 0 else {
                return .init(lum: 1)
            }
            return Color(
                r: lhs.r / rhs,
                g: lhs.g / rhs,
                b: lhs.b / rhs,
                a: lhs.a / rhs,
                space: lhs.space)
        }
        public static func +(lhs: CGFloat, rhs: Color) -> Color {
            return rhs + lhs
        }
        public static func -(lhs: CGFloat, rhs: Color) -> Color {
            return (rhs - lhs) * -1
        }
        public static func *(lhs: CGFloat, rhs: Color) -> Color {
            return rhs * lhs
        }
        
        public static func += (lhs: inout Color, rhs: Color) {
            lhs.r += rhs.r
            lhs.g += rhs.g
            lhs.b += rhs.b
            lhs.a += rhs.a
        }
        public static func -= (lhs: inout Color, rhs: Color) {
            lhs.r -= rhs.r
            lhs.g -= rhs.g
            lhs.b -= rhs.b
            lhs.a -= rhs.a
        }
        public static func *= (lhs: inout Color, rhs: Color) {
            lhs.r *= rhs.r
            lhs.g *= rhs.g
            lhs.b *= rhs.b
            lhs.a *= rhs.a
        }
        
        public static func += (lhs: inout Color, rhs: CGFloat) {
            lhs.r += rhs
            lhs.g += rhs
            lhs.b += rhs
            lhs.a += rhs
        }
        public static func -= (lhs: inout Color, rhs: CGFloat) {
            lhs.r -= rhs
            lhs.g -= rhs
            lhs.b -= rhs
            lhs.a -= rhs
        }
        public static func *= (lhs: inout Color, rhs: CGFloat) {
            lhs.r *= rhs
            lhs.g *= rhs
            lhs.b *= rhs
            lhs.a *= rhs
        }
        public static func /= (lhs: inout Color, rhs: CGFloat) {
            guard rhs != 0 else { return }
            lhs.r /= rhs
            lhs.g /= rhs
            lhs.b /= rhs
            lhs.a /= rhs
        }
        
    }
    
}

extension String {
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
}
