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
        case custom(size: CGSize)
        
        public var size: CGSize {
            switch self {
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
            case .custom(let size): return size
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
        
        var raw: Any? {
            switch self {
            case .screen: return "screen"
            default: return size
            }
        }
        
        init?(raw: Any?) {
            if let rawStr = raw as? String {
                if rawStr == "screen" {
                    self = .screen
                } else {
                    return nil
                }
            } else if let rawSize = raw as? CGSize {
                self.init(size: rawSize)
            } else {
                return nil
            }
        }
        
        init(size: CGSize) {
            switch size {
            case CGSize(width: 1280, height: 720): self = ._720p
            case CGSize(width: 1920, height: 1080): self = ._1080p
            case CGSize(width: 3840, height: 2160): self = ._4K
            case CGSize(width: 128, height: 128): self = ._128
            case CGSize(width: 256, height: 256): self = ._256
            case CGSize(width: 512, height: 512): self = ._512
            case CGSize(width: 1024, height: 1024): self = ._1024
            case CGSize(width: 2048, height: 2048): self = ._2048
            case CGSize(width: 4096, height: 4096): self = ._4096
            default: self = .custom(size: size)
            }
        }
        
        init(image: UIImage) {
            let nativeSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
            self = .custom(size: nativeSize)
        }
        
    }

}
