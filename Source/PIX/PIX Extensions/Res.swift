//
//  PIXRes.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public extension PIX {

    enum Res {
        
        case _720p
        case _1080p
        case _4K
        case _8K
        public static var standardCases: [Res] {
            return [._720p, ._1080p, ._4K, ._8K]
        }

        case fullHD(Orientation)
        case ultraHD(Orientation)
        public static var hdCases: [Res] {
            return [
                .fullHD(.portrait), .fullHD(.landscape),
                .ultraHD(.portrait), .ultraHD(.landscape)
            ]
        }
        
        case _128
        case _256
        case _512
        case _1024
        case _2048
        case _4096
        case _8192
        case _16384
        public static var squareCases: [Res] {
            return [._128, ._256, ._512, ._1024, ._2048, ._4096, ._8192, ._16384]
        }
        
        case iPhone(Orientation)
        case iPhonePlus(Orientation)
        case iPhoneX(Orientation)
        case iPhoneXSMax(Orientation)
        case iPhoneXR(Orientation)
        public static var iPhoneCases: [Res] {
            return [
                .iPhone(.portrait), .iPhone(.landscape),
                .iPhonePlus(.portrait), .iPhonePlus(.landscape),
                .iPhoneX(.portrait), .iPhoneX(.landscape),
                .iPhoneXSMax(.portrait), .iPhoneXSMax(.landscape),
                .iPhoneXR(.portrait), .iPhoneXR(.landscape)
            ]
        }
        
        case iPad(Orientation)
        case iPadPro_10_5(Orientation)
        case iPadPro_11(Orientation)
        case iPadPro_12_9(Orientation)
        public static var iPadCases: [Res] {
            return [
            .iPad(.portrait), .iPad(.landscape),
            .iPadPro_10_5(.portrait), .iPadPro_10_5(.landscape),
            .iPadPro_11(.portrait), .iPadPro_11(.landscape),
            .iPadPro_12_9(.portrait), .iPadPro_12_9(.landscape)
            ]
        }
        
        case fullscreen
        
        case cgSize(_ size: CGSize)
        case size(_ size: LiveSize)
        case custom(w: Int, h: Int)
        case square(_ val: Int)
        case raw(_ raw: Raw)
        
        public enum Orientation {
            case portrait
            case landscape
            var postfix: String {
                switch self {
                case .portrait:
                    return " in Portrait"
                case .landscape:
                    return " in Landscape"
                }
            }
        }
        
        // MARK: Name
        
        public var name: String {
            switch self {
                case ._720p: return "720p"
                case ._1080p: return "1080p"
                case ._4K: return "4K"
                case .fullHD(let ori): return "Full HD" + ori.postfix
                case .ultraHD(let ori): return "Ultra HD" + ori.postfix
                case .iPhone(let ori): return "iPhone" + ori.postfix
                case .iPhonePlus(let ori): return "iPhone Plus" + ori.postfix
                case .iPhoneX(let ori): return "iPhone X" + ori.postfix
                case .iPhoneXSMax(let ori): return "iPhone XS Max" + ori.postfix
                case .iPhoneXR(let ori): return "iPhone XR" + ori.postfix
                case .iPad(let ori): return "iPad" + ori.postfix
                case .iPadPro_10_5(let ori): return "iPad Pro 10.5‑inch" + ori.postfix
                case .iPadPro_11(let ori): return "iPad Pro 11‑inch" + ori.postfix
                case .iPadPro_12_9(let ori): return "iPad Pro 12.9‑inch" + ori.postfix
                case .fullscreen: return "Full Screen"
                default: return "\(raw.w)x\(raw.h)"
            }
        }

        // MARK: Size

        public var size: LiveSize {
            switch self {
            case ._720p: return LiveSize(w: 1280, h: 720)
            case ._1080p: return LiveSize(w: 1920, h: 1080)
            case ._4K: return LiveSize(w: 3840, h: 2160)
            case ._8K: return LiveSize(w: 7680, h: 4320)
            case .fullHD(let ori):
                let size = LiveSize(w: 1920, h: 1080)
                if ori == .landscape { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .ultraHD(let ori):
                let size = LiveSize(w: 3840, h: 2160)
                if ori == .landscape { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case ._128: return LiveSize(w: 128, h: 128)
            case ._256: return LiveSize(w: 256, h: 256)
            case ._512: return LiveSize(w: 512, h: 512)
            case ._1024: return LiveSize(w: 1024, h: 1024)
            case ._2048: return LiveSize(w: 2048, h: 2048)
            case ._4096: return LiveSize(w: 4096, h: 4096)
            case ._8192: return LiveSize(w: 8192, h: 8192)
            case ._16384: return LiveSize(w: 16384, h: 16384)
            case .iPhone(let ori):
                let size = LiveSize(w: 750, h: 1334)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPhonePlus(let ori):
                let size = LiveSize(w: 1080, h: 1920)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPhoneX(let ori):
                let size = LiveSize(w: 1125, h: 2436)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPhoneXSMax(let ori):
                let size = LiveSize(w: 1242, h: 2688)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPhoneXR(let ori):
                let size = LiveSize(w: 828, h: 1792)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPad(let ori):
                let size = LiveSize(w: 1536, h: 2048)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPadPro_10_5(let ori):
                let size = LiveSize(w: 1668, h: 2224)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPadPro_11(let ori):
                let size = LiveSize(w: 1668, h: 2388)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .iPadPro_12_9(let ori):
                let size = LiveSize(w: 2048, h: 2732)
                if ori == .portrait { return size }
                else { return LiveSize(w: size.height, h: size.width) }
            case .fullscreen:
                #if os(iOS)
                let size = UIScreen.main.nativeBounds.size
                if [.portrait, .portraitUpsideDown].contains(UIApplication.shared.statusBarOrientation) { return LiveSize(size) }
                else { return LiveSize(size) }
                #elseif os(macOS)
                let size = NSScreen.main?.frame.size ?? Res._128.size.cg
                let scale = NSScreen.main?.backingScaleFactor ?? 1.0
                return LiveSize(size) * LiveFloat(scale)
                #endif
            case .cgSize(let size): return LiveSize(size)
            case .size(let size): return size
            case .custom(let w, let h): return LiveSize(w: LiveFloat(w), h: LiveFloat(h))
            case .square(let val): return LiveSize(w: LiveFloat(val), h: LiveFloat(val))
            case .raw(let raw): return LiveSize(w: LiveFloat(raw.w), h: LiveFloat(raw.h))
            }
        }
        
        public static var scale: LiveFloat {
            #if os(iOS)
            return LiveFloat(UIScreen.main.nativeScale)
            #elseif os(macOS)
            return LiveFloat(NSScreen.main?.backingScaleFactor ?? 1.0)
            #endif
        }
        
        public var ppi: Int? {
            switch self {
            case .iPhone, .iPhoneXR: return 326
            case .iPhonePlus: return 401
            case .iPhoneX, .iPhoneXSMax: return 458
            case .iPad, .iPadPro_10_5, .iPadPro_11, .iPadPro_12_9: return 264
            default: return nil
            }
        }
        
        public var width: LiveFloat {
            return size.width
        }
        public var height: LiveFloat {
            return size.height
        }
        
        public var flopped: Res {
            return .raw(raw.flopped)
        }
        
        // MARK: Checks
        
        public static var isiPhone: Bool {
            return Res.fullscreen == .iPhone(.landscape) || Res.fullscreen == .iPhone(.portrait) ||
                Res.fullscreen == .iPhonePlus(.landscape) || Res.fullscreen == .iPhonePlus(.portrait) ||
                Res.fullscreen == .iPhoneX(.landscape) || Res.fullscreen == .iPhoneX(.portrait) ||
                Res.fullscreen == .iPhoneXR(.landscape) || Res.fullscreen == .iPhoneXR(.portrait) ||
                Res.fullscreen == .iPhoneXSMax(.landscape) || Res.fullscreen == .iPhoneXSMax(.portrait)
        }
        
        public static var isiPad: Bool {
            return Res.fullscreen == .iPad(.landscape) || Res.fullscreen == .iPad(.portrait) ||
               Res.fullscreen == .iPadPro_11(.landscape) || Res.fullscreen == .iPadPro_11(.portrait) ||
               Res.fullscreen == .iPadPro_10_5(.landscape) || Res.fullscreen == .iPadPro_10_5(.portrait) ||
               Res.fullscreen == .iPadPro_12_9(.landscape) || Res.fullscreen == .iPadPro_12_9(.portrait)
        }
        
        public static var hasDualCamera: Bool {
            return Res.fullscreen == .iPhonePlus(.landscape) || Res.fullscreen == .iPhonePlus(.portrait) ||
                Res.fullscreen == .iPhoneX(.landscape) || Res.fullscreen == .iPhoneX(.portrait) ||
                Res.fullscreen == .iPhoneXSMax(.landscape) || Res.fullscreen == .iPhoneXSMax(.portrait)
        }
        
        // MARK: Raw
        
        public struct Raw/*: Codable*/ {
            public let w: Int
            public let h: Int
            public var flopped: Raw { return Raw(w: h, h: w) }
            public static func ==(lhs: Raw, rhs: Raw) -> Bool {
                return lhs.w == rhs.w && lhs.h == rhs.h
            }
        }
        
        public var raw: Raw {
            return Raw(w: Int(size.width.cg), h: Int(size.height.cg))
        }
        
        public var w: Int {
            return raw.w
        }
        public var h: Int {
            return raw.h
        }
        
        public var count: Int {
            return raw.w * raw.h
        }
        
        // MARK: - Aspect
        
        public var aspect: LiveFloat {
            return size.width / size.height
        }
        
        public enum AspectPlacement {
            case fit
            case fill
        }
        
        public func aspectRes(to aspectPlacement: AspectPlacement, in res: Res) -> Res {
            var comboAspect = aspect.cg / res.aspect.cg
            if aspect.cg < res.aspect.cg {
                comboAspect = 1 / comboAspect
            }
            let width: CGFloat
            let height: CGFloat
            switch aspectPlacement {
            case .fit:
                width = aspect.cg >= res.aspect.cg ? res.width.cg : res.width.cg / comboAspect
                height = aspect.cg <= res.aspect.cg ? res.height.cg : res.height.cg / comboAspect
            case .fill:
                width = aspect.cg <= res.aspect.cg ? res.width.cg : res.width.cg * comboAspect
                height = aspect.cg >= res.aspect.cg ? res.height.cg : res.height.cg * comboAspect
            }
            return .cgSize(CGSize(width: width, height: height))
        }
        public func aspectBounds(to aspectPlacement: AspectPlacement, in res: Res) -> CGRect {
            let aRes = aspectRes(to: aspectPlacement, in: res)
            return CGRect(x: 0, y: 0, width: aRes.width.cg / Res.scale.cg, height: aRes.height.cg / Res.scale.cg)
        }
        
        // MARK: - Life Cycle
        
        public init(size: CGSize) {
            switch size {
            case Res._720p.size.cg: self = ._720p
            case Res._1080p.size.cg: self = ._1080p
            case Res._4K.size.cg: self = ._4K
            case Res._8K.size.cg: self = ._8K
            case Res.fullHD(.portrait).size.cg: self = .fullHD(.portrait)
            case Res.fullHD(.landscape).size.cg: self = .fullHD(.landscape)
            case Res.ultraHD(.portrait).size.cg: self = .ultraHD(.portrait)
            case Res.ultraHD(.landscape).size.cg: self = .ultraHD(.landscape)
            case Res._128.size.cg: self = ._128
            case Res._256.size.cg: self = ._256
            case Res._512.size.cg: self = ._512
            case Res._1024.size.cg: self = ._1024
            case Res._2048.size.cg: self = ._2048
            case Res._4096.size.cg: self = ._4096
            case Res._8192.size.cg: self = ._8192
            case Res._16384.size.cg: self = ._16384
            case Res.iPhone(.portrait).size.cg: self = .iPhone(.portrait)
            case Res.iPhone(.landscape).size.cg: self = .iPhone(.landscape)
            case Res.iPhonePlus(.portrait).size.cg: self = .iPhonePlus(.portrait)
            case Res.iPhonePlus(.landscape).size.cg: self = .iPhonePlus(.landscape)
            case Res.iPhoneX(.portrait).size.cg: self = .iPhoneX(.portrait)
            case Res.iPhoneX(.landscape).size.cg: self = .iPhoneX(.landscape)
            case Res.iPad(.portrait).size.cg: self = .iPad(.portrait)
            case Res.iPad(.landscape).size.cg: self = .iPad(.landscape)
            case Res.iPadPro_10_5(.portrait).size.cg: self = .iPadPro_10_5(.portrait)
            case Res.iPadPro_10_5(.landscape).size.cg: self = .iPadPro_10_5(.landscape)
            case Res.iPadPro_12_9(.portrait).size.cg: self = .iPadPro_12_9(.portrait)
            case Res.iPadPro_12_9(.landscape).size.cg: self = .iPadPro_12_9(.landscape)
            case Res.fullscreen.size.cg: self = .fullscreen
            default: self = .custom(w: Int(size.width), h: Int(size.height))
            }
        }
        
        public init(autoScaleSize: CGSize) {
            self.init(size: CGSize(width: autoScaleSize.width * Res.scale.cg, height: autoScaleSize.height * Res.scale.cg))
        }
        
        public init(_ raw: Raw) {
            let rawSize = CGSize(width: raw.w, height: raw.h)
            self.init(size: rawSize)
        }
        
        #if os(iOS)
        public init(image: UIImage) {
            let nativeSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
            self.init(size: nativeSize)
        }
        #elseif os(macOS)
        public init(image: NSImage) {
            let size = CGSize(width: image.size.width, height: image.size.height)
            self.init(size: size)
        }
        #endif
        
        public init(pixelBuffer: CVPixelBuffer) {
            let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            self.init(size: imageSize)
        }
        
        public init(texture: MTLTexture) {
            let textureSize = CGSize(width: CGFloat(texture.width), height: CGFloat(texture.height))
            self.init(size: textureSize)
        }
        
        // MARK: - Operator Overloads
        
        public static func ==(lhs: Res, rhs: Res) -> Bool {
            return lhs.w == rhs.w && lhs.h == rhs.h
        }
        public static func !=(lhs: Res, rhs: Res) -> Bool {
            return !(lhs == rhs)
        }
        
        public static func >(lhs: Res, rhs: Res) -> Bool? {
            let w = lhs.w > rhs.w
            let h = lhs.h > rhs.h
            return w == h ? w : nil
        }
        public static func <(lhs: Res, rhs: Res) -> Bool? {
            let w = lhs.w < rhs.w
            let h = lhs.h < rhs.h
            return w == h ? w : nil
        }
        public static func >=(lhs: Res, rhs: Res) -> Bool? {
            let w = lhs.w >= rhs.w
            let h = lhs.h >= rhs.h
            return w == h ? w : nil
        }
        public static func <=(lhs: Res, rhs: Res) -> Bool? {
            let w = lhs.w <= rhs.w
            let h = lhs.h <= rhs.h
            return w == h ? w : nil
        }
        
        public static func +(lhs: Res, rhs: Res) -> Res {
            return Res(Raw(w: lhs.w + rhs.w, h: lhs.h + rhs.h))
        }
        public static func -(lhs: Res, rhs: Res) -> Res {
            return Res(Raw(w: lhs.w - rhs.w, h: lhs.h - rhs.h))
        }
        public static func *(lhs: Res, rhs: Res) -> Res {
            return Res(Raw(w: Int(lhs.width.cg * rhs.width.cg), h: Int(lhs.height.cg * rhs.height.cg)))
        }
        
        public static func +(lhs: Res, rhs: CGFloat) -> Res {
            return Res(Raw(w: lhs.w + Int(rhs), h: lhs.h + Int(rhs)))
        }
        public static func -(lhs: Res, rhs: CGFloat) -> Res {
            return Res(Raw(w: lhs.w - Int(rhs), h: lhs.h - Int(rhs)))
        }
        public static func *(lhs: Res, rhs: CGFloat) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg * rhs)), h: Int(round(lhs.height.cg * rhs))))
        }
        public static func /(lhs: Res, rhs: CGFloat) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg / rhs)), h: Int(round(lhs.height.cg / rhs))))
        }
        public static func +(lhs: CGFloat, rhs: Res) -> Res {
            return rhs + lhs
        }
        public static func -(lhs: CGFloat, rhs: Res) -> Res {
            return (rhs - lhs) * CGFloat(-1.0)
        }
        public static func *(lhs: CGFloat, rhs: Res) -> Res {
            return rhs * lhs
        }
        
        public static func +(lhs: Res, rhs: Int) -> Res {
            return Res(Raw(w: lhs.w + Int(rhs), h: lhs.h + Int(rhs)))
        }
        public static func -(lhs: Res, rhs: Int) -> Res {
            return Res(Raw(w: lhs.w - Int(rhs), h: lhs.h - Int(rhs)))
        }
        public static func *(lhs: Res, rhs: Int) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg * CGFloat(rhs))), h: Int(round(lhs.height.cg * CGFloat(rhs)))))
        }
        public static func /(lhs: Res, rhs: Int) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg / CGFloat(rhs))), h: Int(round(lhs.height.cg / CGFloat(rhs)))))
        }
        public static func +(lhs: Int, rhs: Res) -> Res {
            return rhs + lhs
        }
        public static func -(lhs: Int, rhs: Res) -> Res {
            return (rhs - lhs) * Int(-1)
        }
        public static func *(lhs: Int, rhs: Res) -> Res {
            return rhs * lhs
        }
        
        public static func +(lhs: Res, rhs: Double) -> Res {
            return Res(Raw(w: lhs.w + Int(rhs), h: lhs.h + Int(rhs)))
        }
        public static func -(lhs: Res, rhs: Double) -> Res {
            return Res(Raw(w: lhs.w - Int(rhs), h: lhs.h - Int(rhs)))
        }
        public static func *(lhs: Res, rhs: Double) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg * CGFloat(rhs))), h: Int(round(lhs.height.cg * CGFloat(rhs)))))
        }
        public static func /(lhs: Res, rhs: Double) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg / CGFloat(rhs))), h: Int(round(lhs.height.cg / CGFloat(rhs)))))
        }
        public static func +(lhs: Double, rhs: Res) -> Res {
            return rhs + lhs
        }
        public static func -(lhs: Double, rhs: Res) -> Res {
            return (rhs - lhs) * Double(-1.0)
        }
        public static func *(lhs: Double, rhs: Res) -> Res {
            return rhs * lhs
        }
        
        public static func +(lhs: Res, rhs: LiveFloat) -> Res {
            return Res(Raw(w: lhs.w + Int(rhs.cg), h: lhs.h + Int(rhs.cg)))
        }
        public static func -(lhs: Res, rhs: LiveFloat) -> Res {
            return Res(Raw(w: lhs.w - Int(rhs.cg), h: lhs.h - Int(rhs.cg)))
        }
        public static func *(lhs: Res, rhs: LiveFloat) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg * rhs.cg)), h: Int(round(lhs.height.cg * rhs.cg))))
        }
        public static func /(lhs: Res, rhs: LiveFloat) -> Res {
            return Res(Raw(w: Int(round(lhs.width.cg / rhs.cg)), h: Int(round(lhs.height.cg / rhs.cg))))
        }
        public static func +(lhs: LiveFloat, rhs: Res) -> Res {
            return rhs + lhs
        }
        public static func -(lhs: LiveFloat, rhs: Res) -> Res {
            return (rhs - lhs) * LiveFloat(-1.0)
        }
        public static func *(lhs: LiveFloat, rhs: Res) -> Res {
            return rhs * lhs
        }
        
    }

}
