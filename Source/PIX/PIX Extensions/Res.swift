//
//  PIXRes.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import LiveValues

public extension PIX {

    enum Res: Equatable {
        
        case auto
        
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
        case iPhone11(Orientation)
        case iPhone11Pro(Orientation)
        case iPhone11ProMax(Orientation)
        public static var iPhones: [Res] {
            return [
                .iPhone(.portrait), .iPhone(.landscape),
                .iPhonePlus(.portrait), .iPhonePlus(.landscape),
                .iPhoneX(.portrait), .iPhoneX(.landscape),
                .iPhoneXSMax(.portrait), .iPhoneXSMax(.landscape),
                .iPhoneXR(.portrait), .iPhoneXR(.landscape),
                .iPhone11(.portrait), .iPhone11(.landscape),
                .iPhone11Pro(.portrait), .iPhone11Pro(.landscape),
                .iPhone11ProMax(.portrait), .iPhone11ProMax(.landscape)
            ]
        }
        
        case iPad(Orientation)
        case iPad_10_2(Orientation)
        case iPadPro_10_5(Orientation)
        case iPadPro_11(Orientation)
        case iPadPro_12_9(Orientation)
        public static var iPads: [Res] {
            return [
                .iPad(.portrait), .iPad(.landscape),
                .iPad_10_2(.portrait), .iPad_10_2(.landscape),
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
            case .auto: return "Auto"
            case ._720p: return "720p"
            case ._1080p: return "1080p"
            case ._4K: return "4K"
            case ._8K: return "8K"
            case .fullHD(let ori): return "Full HD" + ori.postfix
            case .ultraHD(let ori): return "Ultra HD" + ori.postfix
            case .iPhone(let ori): return "iPhone" + ori.postfix
            case .iPhonePlus(let ori): return "iPhone Plus" + ori.postfix
            case .iPhoneX(let ori): return "iPhone X" + ori.postfix
            case .iPhoneXSMax(let ori): return "iPhone XS Max" + ori.postfix
            case .iPhoneXR(let ori): return "iPhone XR" + ori.postfix
            case .iPhone11(let ori): return "iPhone 11" + ori.postfix
            case .iPhone11Pro(let ori): return "iPhone 11 Pro" + ori.postfix
            case .iPhone11ProMax(let ori): return "iPhone 11 Pro Max" + ori.postfix
            case .iPad(let ori): return "iPad" + ori.postfix
            case .iPad_10_2(let ori): return "iPad 10.2‑inch" + ori.postfix
            case .iPadPro_10_5(let ori): return "iPad Pro 10.5‑inch" + ori.postfix
            case .iPadPro_11(let ori): return "iPad Pro 11‑inch" + ori.postfix
            case .iPadPro_12_9(let ori): return "iPad Pro 12.9‑inch" + ori.postfix
            case .fullscreen: return "Full Screen"
            default: return "\(raw.w)x\(raw.h)"
            }
        }
        
        // MARK: Display Size in Inches
        
        public var inches: CGFloat? {
            switch self {
            case .iPhone: return 4.7
            case .iPhonePlus: return 5.5
            case .iPhoneX, .iPhone11: return 6.1
            case .iPhoneXR, .iPhone11Pro: return 5.8
            case .iPhoneXSMax, .iPhone11ProMax: return 6.5
            case .iPad: return 9.7
            case .iPad_10_2: return 10.2
            case .iPadPro_10_5: return 10.5
            case .iPadPro_11: return 11.0
            case .iPadPro_12_9: return 12.9
            default: return nil
            }
        }
        
        // MARK: Raw
        
        public struct Raw {
            public let w: Int
            public let h: Int
            public var flopped: Raw { return Raw(w: h, h: w) }
            public static func ==(lhs: Raw, rhs: Raw) -> Bool {
                return lhs.w == rhs.w && lhs.h == rhs.h
            }
        }
        
        public var raw: Raw {
            switch self {
            case .auto:
                let scale = PIX.Res.scale.cg
                for pix in PixelKit.main.linkedPixs {
                    guard let superview = pix.view.superview else { continue }
                    let size = superview.frame.size
                    return Raw(w: Int(size.width * scale), h: Int(size.height * scale))
                }
                return Res._128.raw
            case ._720p: return Raw(w: 1280, h: 720)
            case ._1080p: return Raw(w: 1920, h: 1080)
            case ._4K: return Raw(w: 3840, h: 2160)
            case ._8K: return Raw(w: 7680, h: 4320)
            case .fullHD(let ori):
                let raw = Raw(w: 1920, h: 1080)
                if ori == .landscape { return raw }
                else { return raw.flopped }
            case .ultraHD(let ori):
                let raw = Raw(w: 3840, h: 2160)
                if ori == .landscape { return raw }
                else { return raw.flopped }
            case ._128: return Raw(w: 128, h: 128)
            case ._256: return Raw(w: 256, h: 256)
            case ._512: return Raw(w: 512, h: 512)
            case ._1024: return Raw(w: 1024, h: 1024)
            case ._2048: return Raw(w: 2048, h: 2048)
            case ._4096: return Raw(w: 4096, h: 4096)
            case ._8192: return Raw(w: 8192, h: 8192)
            case ._16384: return Raw(w: 16384, h: 16384)
            case .iPhone(let ori):
                let raw = Raw(w: 750, h: 1334)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhonePlus(let ori):
                let raw = Raw(w: 1080, h: 1920)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhoneX(let ori):
                let raw = Raw(w: 1125, h: 2436)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhoneXSMax(let ori):
                let raw = Raw(w: 1242, h: 2688)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhoneXR(let ori):
                let raw = Raw(w: 828, h: 1792)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhone11(let ori):
                let raw = Raw(w: 828, h: 1792)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhone11Pro(let ori):
                let raw = Raw(w: 1125, h: 2436)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPhone11ProMax(let ori):
                let raw = Raw(w: 1242, h: 2688)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPad(let ori):
                let raw = Raw(w: 1536, h: 2048)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPad_10_2(let ori):
                let raw = Raw(w: 1620, h: 2160)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPadPro_10_5(let ori):
                let raw = Raw(w: 1668, h: 2224)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPadPro_11(let ori):
                let raw = Raw(w: 1668, h: 2388)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .iPadPro_12_9(let ori):
                let raw = Raw(w: 2048, h: 2732)
                if ori == .portrait { return raw }
                else { return raw.flopped }
            case .fullscreen:
                #if os(iOS) || os(tvOS)
                let size = UIScreen.main.nativeBounds.size
                let raw = Raw(w: Int(size.width), h: Int(size.height))
                #if os(iOS)
                if [.portrait, .portraitUpsideDown].contains(UIApplication.shared.statusBarOrientation) { return raw }
                else { return raw.flopped }
                #else
                return raw
                #endif
                #elseif os(macOS)
                let size = NSScreen.main?.frame.size ?? Res._128.size.cg
                let scale = NSScreen.main?.backingScaleFactor ?? 1.0
                return Raw(w: Int(size.width * scale), h: Int(size.height * scale))
                #endif
            case .cgSize(let size): return Raw(w: Int(size.width), h: Int(size.height))
            case .size(let size): return Raw(w: Int(size.w.cg), h: Int(size.h.cg))
            case .custom(let w, let h): return Raw(w: w, h: h)
            case .square(let val): return Raw(w: val, h: val)
            case .raw(let raw): return raw
            }
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

        // MARK: Size

        public var size: LiveSize {
            let raw = self.raw
            return LiveSize(w: LiveFloat(raw.w), h: LiveFloat(raw.h))
        }
        
        public static var scale: LiveFloat {
            #if os(iOS)
            return LiveFloat(UIScreen.main.nativeScale)
            #elseif os(tvOS)
            return 1.0
            #elseif os(macOS)
            return LiveFloat(NSScreen.main?.backingScaleFactor ?? 1.0)
            #endif
        }
        
        public var ppi: Int? {
            switch self {
            case .iPad, .iPad_10_2, .iPadPro_10_5, .iPadPro_11, .iPadPro_12_9: return 264
            case .iPhone, .iPhoneXR, .iPhone11: return 326
            case .iPhonePlus: return 401
            case .iPhoneX, .iPhoneXSMax, .iPhone11Pro, .iPhone11ProMax: return 458
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
            #if os(macOS) || targetEnvironment(macCatalyst)
            return false
            #else
            return Res.fullscreen == .iPhone(.landscape) || Res.fullscreen == .iPhone(.portrait) ||
                Res.fullscreen == .iPhonePlus(.landscape) || Res.fullscreen == .iPhonePlus(.portrait) ||
                Res.fullscreen == .iPhoneX(.landscape) || Res.fullscreen == .iPhoneX(.portrait) ||
                Res.fullscreen == .iPhoneXR(.landscape) || Res.fullscreen == .iPhoneXR(.portrait) ||
                Res.fullscreen == .iPhoneXSMax(.landscape) || Res.fullscreen == .iPhoneXSMax(.portrait) ||
                Res.fullscreen == .iPhone11(.landscape) || Res.fullscreen == .iPhone11(.portrait) ||
                Res.fullscreen == .iPhone11Pro(.landscape) || Res.fullscreen == .iPhone11Pro(.portrait) ||
                Res.fullscreen == .iPhone11ProMax(.landscape) || Res.fullscreen == .iPhone11ProMax(.portrait)
            #endif
        }
        
        public static var isiPad: Bool {
            #if os(macOS) || targetEnvironment(macCatalyst)
            return false
            #else
            return Res.fullscreen == .iPad(.landscape) || Res.fullscreen == .iPad(.portrait) ||
               Res.fullscreen == .iPad_10_2(.landscape) || Res.fullscreen == .iPad_10_2(.portrait) ||
               Res.fullscreen == .iPadPro_11(.landscape) || Res.fullscreen == .iPadPro_11(.portrait) ||
               Res.fullscreen == .iPadPro_10_5(.landscape) || Res.fullscreen == .iPadPro_10_5(.portrait) ||
               Res.fullscreen == .iPadPro_12_9(.landscape) || Res.fullscreen == .iPadPro_12_9(.portrait)
            #endif
        }
        
        public static var hasTeleCamera: Bool {
            return Res.fullscreen == .iPhonePlus(.landscape) || Res.fullscreen == .iPhonePlus(.portrait) ||
                Res.fullscreen == .iPhoneX(.landscape) || Res.fullscreen == .iPhoneX(.portrait) ||
                Res.fullscreen == .iPhoneXSMax(.landscape) || Res.fullscreen == .iPhoneXSMax(.portrait) ||
                Res.fullscreen == .iPhone11Pro(.landscape) || Res.fullscreen == .iPhone11Pro(.portrait) ||
                Res.fullscreen == .iPhone11ProMax(.landscape) || Res.fullscreen == .iPhone11ProMax(.portrait)
        }
        
        public static var hasSuperWideCamera: Bool {
            return Res.fullscreen == .iPhone11(.landscape) || Res.fullscreen == .iPhone11(.portrait) ||
                Res.fullscreen == .iPhone11Pro(.landscape) || Res.fullscreen == .iPhone11Pro(.portrait) ||
                Res.fullscreen == .iPhone11ProMax(.landscape) || Res.fullscreen == .iPhone11ProMax(.portrait)
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
            case Res.iPhoneXR(.portrait).size.cg: self = .iPhoneXR(.portrait)
            case Res.iPhoneXR(.landscape).size.cg: self = .iPhoneXR(.landscape)
            case Res.iPhone11(.portrait).size.cg: self = .iPhone11(.portrait)
            case Res.iPhone11(.landscape).size.cg: self = .iPhone11(.landscape)
            case Res.iPhone11Pro(.portrait).size.cg: self = .iPhone11Pro(.portrait)
            case Res.iPhone11Pro(.landscape).size.cg: self = .iPhone11Pro(.landscape)
            case Res.iPhone11ProMax(.portrait).size.cg: self = .iPhone11ProMax(.portrait)
            case Res.iPhone11ProMax(.landscape).size.cg: self = .iPhone11ProMax(.landscape)
            case Res.iPad(.portrait).size.cg: self = .iPad(.portrait)
            case Res.iPad(.landscape).size.cg: self = .iPad(.landscape)
            case Res.iPad_10_2(.portrait).size.cg: self = .iPad_10_2(.portrait)
            case Res.iPad_10_2(.landscape).size.cg: self = .iPad_10_2(.landscape)
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
        
        #if os(iOS) || os(tvOS)
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
        
        // MARK: - Re Res
        
        public enum ImagePlacement {
            case fill
            case fit
        }
        
        public func reRes(in inRes: Res, _ placement: ImagePlacement = .fit) -> Res {
            switch placement {
            case .fit:
                return Res.raw(Raw(
                    w: Int((width / inRes.width > height / inRes.height <?>
                        inRes.width <=> width * (inRes.height / height)).cg),
                    h: Int((width / inRes.width < height / inRes.height <?>
                        inRes.height <=> height * (inRes.width / width)).cg)
                ))
            case .fill:
                return Res.raw(Raw(
                    w: Int((width / inRes.width < height / inRes.height <?>
                        inRes.width <=> width * (inRes.height / height)).cg),
                    h: Int((width / inRes.width > height / inRes.height <?>
                        inRes.height <=> height * (inRes.width / width)).cg)
                ))
            }
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
