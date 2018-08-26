//
//  PIXRes.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public extension PIX {

    public enum Res {
        
        case _720p
        case _1080p
        case _4K

        case fullHD(Orientation)
        case ultraHD(Orientation)
        
        case _128
        case _256
        case _512
        case _1024
        case _2048
        case _4096
        case _8192
        case _16384
        
        case iPhone(Orientation)
        case iPhonePlus(Orientation)
        case iPhoneX(Orientation)
        
        case iPad(Orientation)
        case iPadPro_10_5(Orientation)
        case iPadPro_12_9(Orientation)
        
        case fullScreen
        
        case size(_ size: CGSize)
        case custom(w: Int, h: Int)
        case raw(_ raw: Raw)
        
        public enum Orientation {
            case portrait
            case landscape
        }

        // MARK: Size

        public var size: CGSize {
            switch self {
            case ._720p: return CGSize(width: 1280, height: 720)
            case ._1080p: return CGSize(width: 1920, height: 1080)
            case ._4K: return CGSize(width: 3840, height: 2160)
            case .fullHD(let ori):
                let size = CGSize(width: 1920, height: 1080)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .ultraHD(let ori):
                let size = CGSize(width: 3840, height: 2160)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case ._128: return CGSize(width: 128, height: 128)
            case ._256: return CGSize(width: 256, height: 256)
            case ._512: return CGSize(width: 512, height: 512)
            case ._1024: return CGSize(width: 1024, height: 1024)
            case ._2048: return CGSize(width: 2048, height: 2048)
            case ._4096: return CGSize(width: 4096, height: 4096)
            case ._8192: return CGSize(width: 8192, height: 8192)
            case ._16384: return CGSize(width: 16384, height: 16384)
            case .iPhone(let ori):
                let size = CGSize(width: 750, height: 1334)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .iPhonePlus(let ori):
                let size = CGSize(width: 1080, height: 1920)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .iPhoneX(let ori):
                let size = CGSize(width: 1125, height: 2436)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .iPad(let ori):
                let size = CGSize(width: 1536, height: 2048)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .iPadPro_10_5(let ori):
                let size = CGSize(width: 1668, height: 2224)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .iPadPro_12_9(let ori):
                let size = CGSize(width: 2048, height: 2732)
                if ori == .portrait { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .fullScreen:
                let size = UIScreen.main.nativeBounds.size
                if [.portrait, .portraitUpsideDown].contains(UIApplication.shared.statusBarOrientation) { return size }
                else { return CGSize(width: size.height, height: size.width) }
            case .size(let size): return size
            case .custom(let w, let h): return CGSize(width: w, height: h)
            case .raw(let raw): return CGSize(width: raw.w, height: raw.h)
            }
        }
        
        public var width: CGFloat {
            return size.width
        }
        public var height: CGFloat {
            return size.height
        }
        public var aspect: CGFloat {
            return size.width / size.height
        }
        
        // MARK: Raw
        
        public struct Raw: Codable {
            public let w: Int
            public let h: Int
            public var flopped: Raw { return Raw(w: h, h: w) }
            public static func ==(lhs: Raw, rhs: Raw) -> Bool {
                return lhs.w == rhs.w && lhs.h == rhs.h
            }
        }
        
        public var raw: Raw {
            return Raw(w: Int(size.width), h: Int(size.height))
        }
        
        public var w: Int {
            return raw.w
        }
        public var h: Int {
            return raw.h
        }
        
        // MARK: - Life Cycle
        
        public init(size: CGSize) {
            switch size {
            case Res._720p.size: self = ._720p
            case Res._1080p.size: self = ._1080p
            case Res._4K.size: self = ._4K
            case Res.fullHD(.portrait).size: self = .fullHD(.portrait)
            case Res.fullHD(.landscape).size: self = .fullHD(.landscape)
            case Res.ultraHD(.portrait).size: self = .ultraHD(.portrait)
            case Res.ultraHD(.landscape).size: self = .ultraHD(.landscape)
            case Res._128.size: self = ._128
            case Res._256.size: self = ._256
            case Res._512.size: self = ._512
            case Res._1024.size: self = ._1024
            case Res._2048.size: self = ._2048
            case Res._4096.size: self = ._4096
            case Res._8192.size: self = ._8192
            case Res._16384.size: self = ._16384
            case Res.iPhone(.portrait).size: self = .iPhone(.portrait)
            case Res.iPhone(.landscape).size: self = .iPhone(.landscape)
            case Res.iPhonePlus(.portrait).size: self = .iPhonePlus(.portrait)
            case Res.iPhonePlus(.landscape).size: self = .iPhonePlus(.landscape)
            case Res.iPhoneX(.portrait).size: self = .iPhoneX(.portrait)
            case Res.iPhoneX(.landscape).size: self = .iPhoneX(.landscape)
            case Res.iPad(.portrait).size: self = .iPad(.portrait)
            case Res.iPad(.landscape).size: self = .iPad(.landscape)
            case Res.iPadPro_10_5(.portrait).size: self = .iPadPro_10_5(.portrait)
            case Res.iPadPro_10_5(.landscape).size: self = .iPadPro_10_5(.landscape)
            case Res.iPadPro_12_9(.portrait).size: self = .iPadPro_12_9(.portrait)
            case Res.iPadPro_12_9(.landscape).size: self = .iPadPro_12_9(.landscape)
            case Res.fullScreen.size: self = .fullScreen
            default: self = .custom(w: Int(size.width), h: Int(size.height))
            }
        }
        
        public init(_ raw: Raw) {
            let rawSize = CGSize(width: raw.w, height: raw.h)
            self.init(size: rawSize)
        }
        
        public init(image: UIImage) {
            let nativeSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
            self.init(size: nativeSize)
        }
        
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
            return .custom(w: lhs.w + rhs.w, h: lhs.h + rhs.h)
        }
        public static func -(lhs: Res, rhs: Res) -> Res {
            return .custom(w: lhs.w - rhs.w, h: lhs.h - rhs.h)
        }
        public static func *(lhs: Res, rhs: Res) -> Res {
            return .custom(w: Int(lhs.width * rhs.width), h: Int(lhs.height * rhs.height))
        }
        
        public static func +(lhs: Res, rhs: CGFloat) -> Res {
            return .custom(w: lhs.w + Int(rhs), h: lhs.h + Int(rhs))
        }
        public static func -(lhs: Res, rhs: CGFloat) -> Res {
            return .custom(w: lhs.w - Int(rhs), h: lhs.h - Int(rhs))
        }
        public static func *(lhs: Res, rhs: CGFloat) -> Res {
            return .custom(w: Int(lhs.width * rhs), h: Int(lhs.height * rhs))
        }
        public static func /(lhs: Res, rhs: CGFloat) -> Res {
            return .custom(w: Int(lhs.width / rhs), h: Int(lhs.height / rhs))
        }
        public static func +(lhs: CGFloat, rhs: Res) -> Res {
            return rhs + lhs
        }
        public static func -(lhs: CGFloat, rhs: Res) -> Res {
            return (rhs - lhs) * -1
        }
        public static func *(lhs: CGFloat, rhs: Res) -> Res {
            return rhs * lhs
        }
        
    }

}
