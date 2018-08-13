//
//  Res.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public extension PIX {

    public enum Res {
        
        case auto
        case screen
        case _720p
        case _1080p
        case _4K
        case _128
        case _256
        case _512
        case _1024
        case _2048
        case _4096
        case custom(res: CGSize)
        case unknown
        
        var resolution: CGSize? {
            switch self {
            case .auto: return nil
            case .screen: return UIScreen.main.nativeBounds.size
            case ._720p: return CGSize(width: 1280, height: 720)
            case ._1080p: return CGSize(width: 1920, height: 1080)
            case ._4K: return CGSize(width: 3840, height: 2160)
            case ._128: return CGSize(width: 128, height: 128)
            case ._256: return CGSize(width: 256, height: 256)
            case ._512: return CGSize(width: 512, height: 512)
            case ._1024: return CGSize(width: 1024, height: 1024)
            case ._2048: return CGSize(width: 2048, height: 2048)
            case ._4096: return CGSize(width: 4096, height: 4096)
            case .custom(let res): return res
            case .unknown: return nil
            }
        }
        
        var isAuto: Bool {
            switch self {
            case .auto: return true
            default: return false
            }
        }
        
        var aspect: CGFloat? {
            guard resolution != nil else { return nil }
            return resolution!.width / resolution!.height
        }
        
        var raw: Any? {
            switch self {
            case .auto: return "auto"
            case .screen: return "screen"
            default: return resolution
            }
        }
        
        init(raw: Any?) {
            if let rawStr = raw as? String {
                if rawStr == "auto" {
                    self = .auto
                } else if rawStr == "screen" {
                    self = .screen
                } else {
                    self = .unknown
                }
            } else if let rawResolution = raw as? CGSize {
                self.init(resolution: rawResolution)
            } else {
                self = .unknown
            }
        }
        
        init(resolution: CGSize) {
            switch resolution {
            case CGSize(width: 1280, height: 720): self = ._720p
            case CGSize(width: 1920, height: 1080): self = ._1080p
            case CGSize(width: 3840, height: 2160): self = ._4K
            case CGSize(width: 128, height: 128): self = ._128
            case CGSize(width: 256, height: 256): self = ._256
            case CGSize(width: 512, height: 512): self = ._512
            case CGSize(width: 1024, height: 1024): self = ._1024
            case CGSize(width: 2048, height: 2048): self = ._2048
            case CGSize(width: 4096, height: 4096): self = ._4096
            default: self = .custom(res: resolution)
            }
        }
        
    }

}
