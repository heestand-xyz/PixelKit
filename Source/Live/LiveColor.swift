//
//  PIXColor.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-08.
//  Open Source - MIT License
//

import AVFoundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import CoreGraphics

#if os(iOS)
public typealias _Color = UIColor
#elseif os(macOS)
public typealias _Color = NSColor
#endif
//public extension _Color {
//    var liveColor: LiveColor {
//        return LiveColor(self)
//    }
//}

extension _Color {
    convenience init(_ liveColor: LiveColor) {
        self.init(displayP3Red: CGFloat(liveColor.r), green: CGFloat(liveColor.g), blue: CGFloat(liveColor.b), alpha: CGFloat(liveColor.a))
    }
}

public class LiveColor: LiveValue, CustomStringConvertible {
    
    public  var name: String?
    
    public var r: LiveFloat
    public var g: LiveFloat
    public var b: LiveFloat
    public var a: LiveFloat
    
    public var description: String {
        let _r: CGFloat = round(CGFloat(r) * 1_000) / 1_000
        let _g: CGFloat = round(CGFloat(g) * 1_000) / 1_000
        let _b: CGFloat = round(CGFloat(b) * 1_000) / 1_000
        let _a: CGFloat = round(CGFloat(a) * 1_000) / 1_000
        return "live\(name != nil ? "[\(name!)]" : "")(r:\("\(_r)".zfill(3)),g:\("\(_g)".zfill(3)),b:\("\(_b)".zfill(3)),a:\("\(_a)".zfill(3)))"
    }
    
    // MARK: Uniform
    
    public var uniformIsNew: Bool {
       return r.uniformIsNew || g.uniformIsNew || b.uniformIsNew || a.uniformIsNew
    }
    
    public var uniformList: [CGFloat] {
        return [r.uniform, g.uniform, b.uniform, a.uniform]
    }
    
    // MARK: Colors
    
    public static var whiteShine: LiveColor {
        let shine: LiveFloat = 0.1
        return LiveColor(r: (1.0 - shine / 2) + (shine / 2) * cos(.seconds),
                         g: (1.0 - shine / 2) + (shine / 2) * sin(.seconds),
                         b: (1.0 - shine / 2) + (shine / 2) * (cos(.seconds / 2) + sin(.seconds / 2) / 2))
    }
    
    public static var rainbow: LiveColor {
        return LiveColor(h: .secondsSince1970 / 6.0, s: 1.0, v: 1.0, a: 1.0)
    }
    
    public static var clear: LiveColor       { return LiveColor(r: 0.0, g: 0.0, b: 0.0, a: 0.0) }
    public static var clearWhite: LiveColor  { return LiveColor(r: 1.0, g: 1.0, b: 1.0, a: 0.0) }

    public static var white: LiveColor       { return LiveColor(lum: 1.0) }
    public static var lightGray: LiveColor   { return LiveColor(lum: 0.75) }
    public static var gray: LiveColor        { return LiveColor(lum: 0.5) }
    public static var darkGray: LiveColor    { return LiveColor(lum: 0.25) }
    public static var black: LiveColor       { return LiveColor(lum: 0.0) }
    
    public static var red: LiveColor         { return LiveColor(r: 1.0, g: 0.0, b: 0.0) }
    public static var orange: LiveColor      { return LiveColor(r: 1.0, g: 0.5, b: 0.0) }
    public static var yellow: LiveColor      { return LiveColor(r: 1.0, g: 1.0, b: 0.0) }
    public static var green: LiveColor       { return LiveColor(r: 0.0, g: 1.0, b: 0.0) }
    public static var cyan: LiveColor        { return LiveColor(r: 0.0, g: 1.0, b: 1.0) }
    public static var blue: LiveColor        { return LiveColor(r: 0.0, g: 0.0, b: 1.0) }
    public static var magenta: LiveColor     { return LiveColor(r: 1.0, g: 0.0, b: 1.0) }
    
    public static var random: LiveColor { return LiveColor(h: .random(in: 0.0..<1.0)) }
    
    // MARK: Bits

    public enum Bits: Int, Codable {
        case _8 = 8
        case _10 = 10
        case _16 = 16
        case _32 = 32
        public var mtl: MTLPixelFormat {
            switch self {
            case ._8: return .bgra8Unorm
            case ._10: return .bgra10_xr_srgb
            case ._16: return .rgba16Float
            case ._32: return .rgba32Float
            }
        }
        public var ci: CIFormat {
            switch self {
            case ._8, ._10: return .RGBA8
            case ._16, ._32: return .RGBA16
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
    
    // MARK: Space
    
    public enum Space: String, Codable {
        case sRGB
        case displayP3
        public var cg: CGColorSpace {
            switch self {
            case .sRGB:
                return CGColorSpace(name: CGColorSpace.sRGB)!
            case .displayP3:
                return CGColorSpace(name: CGColorSpace.displayP3)!
            }
        }
    }
    
    static let linearP3ToLinearSRGBMatrix: matrix_float3x3 = {
        let col1 = float3([ 1.2249, -0.2247,  0])
        let col2 = float3([-0.0420,  1.0419,  0])
        let col3 = float3([-0.0197, -0.0786,  1.0979])
        return matrix_float3x3([col1, col2, col3])
    }()
    
    func sRGB(p3 c: LiveColor) -> LiveColor {
        let p3 = float3(x: Float(c.r.cg), y: Float(c.g.cg), z: Float(c.b.cg))
        let linearSrgb = p3.gammaDecoded * LiveColor.linearP3ToLinearSRGBMatrix
        let srgb = linearSrgb.gammaEncoded
        return LiveColor(r: LiveFloat(srgb.x), g: LiveFloat(srgb.y), b: LiveFloat(srgb.z), a: a)
    }
    
    var colorCorrect: LiveColor {
        switch Pixels.main.colorSpace {
        case .sRGB:
            return self
        case .displayP3:
//            return sRGB(p3: self)
            
            let p3Color = UIColor(displayP3Red: r.cg, green: g.cg, blue: b.cg, alpha: a.cg)
            let ciColor = CIColor(color: p3Color)
            let r = LiveFloat(ciColor.red)
            let g = LiveFloat(ciColor.green)
            let b = LiveFloat(ciColor.blue)
            let a = LiveFloat(ciColor.alpha)
            return LiveColor(r: r, g: g, b: b, a: a)
        }
    }
    
    // MARK: Touch
    
    #if os(iOS)
    public static var touch: LiveColor {
        return LiveColor(lum: .touch)
    }
    #elseif os(macOS)
    public static var mouseLeft: LiveColor {
        return LiveBool.mouseLeft <?> .white <=> .black
    }
    public static var mouseRight: LiveColor {
        return LiveBool.mouseRight <?> .white <=> .black
    }
    public static var mouseInView: LiveColor {
        return LiveBool.mouseInView <?> .white <=> .black
    }
    #endif
    
    // MARK: MIDI
    
    #if os(macOS)
    
    public static var midiAny: LiveColor {
        return LiveColor(lum: LiveFloat.midiAny)
    }
    
    #endif
    
    // MARK: Properties
    
    var _color: _Color {
        #if os(iOS)
        return uiColor
        #elseif os(macOS)
        return nsColor
        #endif
    }
    #if os(iOS)
    public var uiColor: UIColor {
        switch Pixels.main.colorSpace {
        case .sRGB:
            return UIColor(red: r.cg, green: g.cg, blue: b.cg, alpha: a.cg)
        case .displayP3:
            return UIColor(displayP3Red: r.cg, green: g.cg, blue: b.cg, alpha: a.cg)
        }
    }
    #elseif os(macOS)
    public var nsColor: NSColor {
        switch Pixels.main.colorSpace {
        case .sRGB:
            return NSColor(red: r.cg, green: g.cg, blue: b.cg, alpha: a.cg)
        case .displayP3:
            return NSColor(displayP3Red: r.cg, green: g.cg, blue: b.cg, alpha: a.cg)
        }
    }
    #endif
    
    public var ciColor: CIColor {
        return CIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a), colorSpace: Pixels.main.colorSpace.cg) ?? CIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    public var cgColor: CGColor {
        return CGColor(colorSpace: Pixels.main.colorSpace.cg, components: list) ?? _Color.clear.cgColor
    }
    
    public var list: [CGFloat] {
        return [CGFloat(r), CGFloat(g), CGFloat(b), CGFloat(a)]
    }
    
    public var lum: LiveFloat {
        return (r + g + b) / 3
    }
    
    public var mono: LiveColor {
        return LiveColor(r: lum, g: lum, b: lum, a: a/*, space: space*/)
    }
    
    
    // MARK: - Life Cycle

    // MARK: - Future
    
    public init(_ liveValue: @escaping () -> (_Color)) {
        let liveColor = LiveColor(liveValue())
        r = liveColor.r
        g = liveColor.g
        b = liveColor.b
        a = liveColor.a
    }
    
    // MARK: - RGB
    
    public init(r: LiveFloat, g: LiveFloat, b: LiveFloat, a: LiveFloat = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    public init(r255: Int, g255: Int, b255: Int, a255: Int = 255) {
        self.r = LiveFloat(CGFloat(r255) / 255)
        self.g = LiveFloat(CGFloat(g255) / 255)
        self.b = LiveFloat(CGFloat(b255) / 255)
        self.a = LiveFloat(CGFloat(a255) / 255)
    }
    
    // MARK: - UI
    
    #if os(iOS)
    public init(_ uiColor: UIColor) {
        let ciColor = CIColor(color: uiColor)
        r = LiveFloat(ciColor.red)
        g = LiveFloat(ciColor.green)
        b = LiveFloat(ciColor.blue)
        a = LiveFloat(ciColor.alpha)
    }
    #endif

    // MARK: - NS
    
    #if os(macOS)
    public init(_ nsColor: NSColor) {
        let ciColor = CIColor(color: nsColor)
        // FIXME: Optional LiveFloat
        r = LiveFloat(ciColor?.red ?? 0.0)
        g = LiveFloat(ciColor?.green ?? 0.0)
        b = LiveFloat(ciColor?.blue ?? 0.0)
        a = LiveFloat(ciColor?.alpha ?? 0.0)
    }
    #endif
    
    // MARK: - Grayscale
    
    public init(lum: LiveFloat, a: LiveFloat = 1.0) {
//        self.space = Pixels.main.colorSpace
        self.r = lum
        self.g = lum
        self.b = lum
        self.a = a
    }
    
    // MARK: - Hue Saturaton Value
    
    public var hue: LiveFloat {
        return LiveFloat({ self.hsv().h })
    }
    public var sat: LiveFloat {
        return LiveFloat({ self.hsv().s })
    }
    public var val: LiveFloat {
        return LiveFloat({ self.hsv().v })
    }
    func hsv() -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let r = CGFloat(self.r)
        let g = CGFloat(self.g)
        let b = CGFloat(self.b)
        var h, s, v: CGFloat
        var mn, mx, d: CGFloat
        mn = r < g ? r : g
        mn = mn < b ? mn : b
        mx = r > g ? r : g
        mx = mx > b ? mx : b
        v = mx
        d = mx - mn
        if (d < 0.00001) {
            s = 0
            h = 0
            return (h: h, s: s, v: v)
        }
        if mx > 0.0 {
            s = d / mx
        } else {
            s = 0.0
            h = 0.0
            return (h: h, s: s, v: v)
        }
        if r >= mx {
            h = (g - b) / d
        } else if g >= mx {
            h = 2.0 + (b - r) / d
        } else {
            h = 4.0 + (r - g) / d
        }
        h *= 60.0
        if h < 0.0 {
            h += 360.0
        }
        h /= 360.0
        return (h: h, s: s, v: v)
    }
    
    public init(h: LiveFloat, s: LiveFloat = 1.0, v: LiveFloat = 1.0, a: LiveFloat = 1.0) {
        r = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).r })
        g = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).g })
        b = LiveFloat({ return LiveColor.rgb(h: CGFloat(h), s: CGFloat(s), v: CGFloat(v)).b })
        self.a = a
    }
    static func rgb(h: CGFloat, s: CGFloat, v: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        var hh, p, q, t, ff: CGFloat
        var i: Int
        if (s <= 0.0) {
            r = v
            g = v
            b = v
            return  (r: r, g: g, b: b)
        }
        hh = (h - floor(h)) * 360
        hh = hh / 60.0
        i = Int(hh)
        ff = hh - CGFloat(i)
        p = v * (1.0 - s)
        q = v * (1.0 - (s * ff))
        t = v * (1.0 - (s * (1.0 - ff)))
        switch(i) {
        case 0:
            r = v
            g = t
            b = p
        case 1:
            r = q
            g = v
            b = p
        case 2:
            r = p
            g = v
            b = t
        case 3:
            r = p
            g = q
            b = v
        case 4:
            r = t
            g = p
            b = v
        case 5:
            r = v
            g = p
            b = q
        default:
            r = v
            g = p
            b = q
        }
        return (r: r, g: g, b: b)
    }
    
    // MARK: - Hex
    
    public var hex: String {
        let hexInt: Int = (Int)(CGFloat(r)*255)<<16 | (Int)(CGFloat(g)*255)<<8 | (Int)(CGFloat(b)*255)<<0
        return String(format:"#%06x", hexInt)
    }
    
    public init(hex: String, a: CGFloat = 1) {
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
        self.r = LiveFloat(CGFloat((hexInt & 0xff0000) >> 16) / 255.0)
        self.g = LiveFloat(CGFloat((hexInt & 0xff00) >> 8) / 255.0)
        self.b = LiveFloat(CGFloat((hexInt & 0xff) >> 0) / 255.0)
        self.a = LiveFloat(a)
    }
    
    // MARK: - Pixel
    
    init(_ pixel: [CGFloat]) {
        guard pixel.count == 4 else {
            Pixels.main.log(.error, nil, "Color: Bad Channel Count: \(pixel.count)")
            r = 0
            g = 0
            b = 0
            a = 1
            return
        }
        switch Pixels.main.bits {
        case ._8, ._10:
            // FIXME: BGRA Temp Fix
            b = LiveFloat(pixel[0])
            g = LiveFloat(pixel[1])
            r = LiveFloat(pixel[2])
            a = LiveFloat(pixel[3])
        case ._16, ._32:
            r = LiveFloat(pixel[0])
            g = LiveFloat(pixel[1])
            b = LiveFloat(pixel[2])
            a = LiveFloat(pixel[3])
        }
    }
    
    // MARK: - Pure
    
    public enum Pure {
        case red
        case green
        case blue
        case alpha
        var liveColor: LiveColor {
            switch self {
            case .red:   return .init(r: 1.0, g: 0.0, b: 0.0, a: 0.0)
            case .green: return .init(r: 0.0, g: 1.0, b: 0.0, a: 0.0)
            case .blue:  return .init(r: 0.0, g: 0.0, b: 1.0, a: 0.0)
            case .alpha: return .init(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
            }
        }
    }
    
    public var isPure: LiveBool {
        let oneCount: LiveInt = (r == 1.0 <?> 1 <=> 0) + (g == 1.0 <?> 1 <=> 0) + (b == 1.0 <?> 1 <=> 0) + (a == 1.0 <?> 1 <=> 0)
        let zeroCount: LiveInt = (r == 0.0 <?> 1 <=> 0) + (g == 0.0 <?> 1 <=> 0) + (b == 0.0 <?> 1 <=> 0) + (a == 0.0 <?> 1 <=> 0)
        return oneCount == 1 && zeroCount == 3
    }
    
    public var pure: Pure? {
        guard Bool(isPure) else { return nil }
        if CGFloat(r) == 1.0 {
            return .red
        } else if CGFloat(g) == 1.0 {
            return .green
        } else if CGFloat(b) == 1.0 {
            return .blue
        } else if CGFloat(a) == 1.0 {
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
//        space = Pixels.main.colorSpace
    }
    
    // MARK: - Functions
    
    public func withAlpha(of alpha: LiveFloat) -> LiveColor {
        return LiveColor(r: r, g: g, b: b, a: alpha)
    }
    
    public func withHue(of hue: LiveFloat, fullySaturated: Bool = false) -> LiveColor {
        return LiveColor(h: hue, s: fullySaturated ? 1.0 : sat, v: val/*, space: space*/)
    }
    public func withSat(of sat: LiveFloat) -> LiveColor {
        return LiveColor(h: hue, s: sat, v: val/*, space: space*/)
    }
    public func withVal(of val: LiveFloat) -> LiveColor {
        return LiveColor(h: hue, s: sat, v: val/*, space: space*/)
    }
    
    public func withShiftedHue(by hueShift: LiveFloat) -> LiveColor {
        return LiveColor(h: (hue + hueShift).remainder(dividingBy: 1.0), s: sat, v: val/*, space: space*/)
    }
    
    // MARK: - Operator Overloads
    
    public static func ==  (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.r == rhs.r &&
               lhs.g == rhs.g &&
               lhs.b == rhs.b &&
               lhs.a == rhs.a
    }
    public static func != (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return !(lhs == rhs)
    }
    
    public static func > (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val > rhs.val
    }
    public static func < (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val < rhs.val
    }
    public static func >= (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val >= rhs.val
    }
    public static func <= (lhs: LiveColor, rhs: LiveColor) -> LiveBool {
        return lhs.val <= rhs.val
    }
    
    public static func + (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(r: lhs.r + rhs.r,
                         g: lhs.g + rhs.g,
                         b: lhs.b + rhs.b,
                         a: lhs.a + rhs.a/*,
                        space: lhs.space*/)
    }
    public static func - (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(r: lhs.r - rhs.r,
                         g: lhs.g - rhs.g,
                         b: lhs.b - rhs.b,
                         a: lhs.a/*,
                         space: lhs.space*/)
    }
    public static func -- (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(r: lhs.r - rhs.r,
                         g: lhs.g - rhs.g,
                         b: lhs.b - rhs.b,
                         a: lhs.a - rhs.a/*,
                         space: lhs.space*/)
    }
    public static func * (lhs: LiveColor, rhs: LiveColor) -> LiveColor {
        return LiveColor(r: lhs.r * rhs.r,
                         g: lhs.g * rhs.g,
                         b: lhs.b * rhs.b,
                         a: lhs.a * rhs.a/*,
                         space: lhs.space*/)
    }
    
    public static func + (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(r: lhs.r + rhs,
                         g: lhs.g + rhs,
                         b: lhs.b + rhs,
                         a: lhs.a + rhs/*,
                         space: lhs.space*/)
    }
    public static func - (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(r: lhs.r - rhs,
                         g: lhs.g - rhs,
                         b: lhs.b - rhs,
                         a: lhs.a/*,
                         space: lhs.space*/)
    }
    public static func -- (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(r: lhs.r - rhs,
                         g: lhs.g - rhs,
                         b: lhs.b - rhs,
                         a: lhs.a - rhs/*,
                         space: lhs.space*/)
    }
    public static func * (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(r: lhs.r * rhs,
                         g: lhs.g * rhs,
                         b: lhs.b * rhs,
                         a: lhs.a * rhs/*,
                         space: lhs.space*/)
    }
    public static func / (lhs: LiveColor, rhs: LiveFloat) -> LiveColor {
        return LiveColor(r: lhs.r != 0.0 <?> lhs.r / rhs <=> 1.0,
                         g: lhs.g != 0.0 <?> lhs.g / rhs <=> 1.0,
                         b: lhs.b != 0.0 <?> lhs.b / rhs <=> 1.0,
                         a: lhs.a != 0.0 <?> lhs.a / rhs <=> 1.0/*,
                         space: lhs.space*/)
    }
    public static func + (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return rhs + lhs
    }
    public static func - (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return (rhs - lhs) * -1
    }
    public static func * (lhs: LiveFloat, rhs: LiveColor) -> LiveColor {
        return rhs * lhs
    }
    
    public static func += (lhs: inout LiveColor, rhs: LiveColor) {
        lhs.r += rhs.r
        lhs.g += rhs.g
        lhs.b += rhs.b
        lhs.a += rhs.a
    }
    public static func += (lhs: inout LiveColor, rhs: LiveFloat) {
        lhs.r += rhs
        lhs.g += rhs
        lhs.b += rhs
        lhs.a += rhs
    }
    public static func -= (lhs: inout LiveColor, rhs: LiveColor) {
        lhs.r -= rhs.r
        lhs.g -= rhs.g
        lhs.b -= rhs.b
        lhs.a -= rhs.a
    }
    public static func -= (lhs: inout LiveColor, rhs: LiveFloat) {
        lhs.r -= rhs
        lhs.g -= rhs
        lhs.b -= rhs
        lhs.a -= rhs
    }
    public static func *= (lhs: inout LiveColor, rhs: LiveColor) {
        lhs.r *= rhs.r
        lhs.g *= rhs.g
        lhs.b *= rhs.b
        lhs.a *= rhs.a
    }
    public static func *= (lhs: inout LiveColor, rhs: LiveFloat) {
        lhs.r *= rhs
        lhs.g *= rhs
        lhs.b *= rhs
        lhs.a *= rhs
    }
    public static func /= (lhs: inout LiveColor, rhs: LiveColor) {
        lhs.r /= rhs.r != 0 <?> rhs.r <=> 1.0
        lhs.g /= rhs.g != 0 <?> rhs.g <=> 1.0
        lhs.b /= rhs.b != 0 <?> rhs.b <=> 1.0
        lhs.a /= rhs.a != 0 <?> rhs.a <=> 1.0
    }
    public static func /= (lhs: inout LiveColor, rhs: LiveFloat) {
        lhs.r /= rhs != 0 <?> rhs <=> 1.0
        lhs.g /= rhs != 0 <?> rhs <=> 1.0
        lhs.b /= rhs != 0 <?> rhs <=> 1.0
        lhs.a /= rhs != 0 <?> rhs <=> 1.0
    }
    
    public prefix static func - (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: -operand.r,
            g: -operand.g,
            b: -operand.b,
            a: operand.a/*,
            space: operand.space*/)
    }
    
    public prefix static func -- (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: -operand.r,
            g: -operand.g,
            b: -operand.b,
            a: -operand.a/*,
             space: operand.space*/)
    }
    
    public prefix static func ! (operand: LiveColor) -> LiveColor {
        return LiveColor(
            r: 1.0 - operand.r,
            g: 1.0 - operand.g,
            b: 1.0 - operand.b,
            a: operand.a/*,
             space: operand.space*/)
    }
    
    public static func <=> (lhs: LiveColor, rhs: LiveColor) -> (LiveColor, LiveColor) {
        return (lhs, rhs)
    }
    
    #if os(macOS)
    /// find addresses with `MIDI.main.log = true`
    public static func midi(_ address: String) -> LiveColor {
        return LiveColor(lum: LiveFloat.midi(address))
    }
    #endif
    
}

extension float3 {
    
    var gammaDecoded: float3 {
        let f = {
            (c: Float) -> Float in
            if abs(c) <= 0.04045 {
                return c / 12.92
            }
            return sign(c) * powf((abs(c) + 0.055) / 1.055, 2.4)
        }
        return float3(f(x), f(y), f(z))
        
    }
    
    var gammaEncoded: float3 {
        let f = {
            (c: Float) -> Float in
            if abs(c) <= 0.0031308 {
                return c * 12.92
            }
            return sign(c) * (powf(abs(c), 1/2.4) * 1.055 - 0.055)
        }
        return float3(f(x), f(y), f(z))
    }
    
}
