//
//  PIXResolution.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-13.
//  Open Source - MIT License
//

import RenderKit
import LiveValues
import CoreGraphics

extension PIX {
    
    public var renderResolution: Resolution {
        realResolution ?? .auto
    }
    
    public var realResolution: Resolution? {
        guard !bypass else {
            if let pixIn = self as? NODEInIO {
                return pixIn.nodeInList.first?.resolution
            } else { return nil }
        }
        if let pixContent = self as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                if let imagePix = pixResource as? ImagePIX {
                    if let res = imagePix.resizedRes {
                        return res
                    }
                    guard let image = imagePix.image else { return nil }
                    #if !os(macOS)
                    return Res.cgSize(image.size) * LiveFloat(image.scale)
                    #else
                    return Res.cgSize(image.size)
                    #endif
                } else {
                    #if !os(tvOS)
                    if let webPix = pixResource as? WebPIX {
                        return webPix.res
                    }
                    #endif
                    guard let pixelBuffer = pixResource.pixelBuffer else { return nil }
                    var bufferRes = Res(pixelBuffer: pixelBuffer)
                    if pixResource.flop {
                        bufferRes = Res(bufferRes.raw.flopped)
                    }
                    return bufferRes
                }
            } else if let pixGenerator = pixContent as? PIXGenerator {
                return pixGenerator.res
            } else if let pixSprite = pixContent as? PIXSprite {
                return .cgSize(pixSprite.scene?.size ?? CGSize(width: 128, height: 128))
            } else if let pixCustom = pixContent as? PIXCustom {
                return pixCustom.res
            } else { return nil }
        } else if let resPix = self as? ResPIX {
            let resRes: Resolution
            if resPix.inheritInRes {
                guard let inResolution = resPix.nodeInList.first?.resolution else { return nil }
                resRes = inResolution
            } else {
                resRes = resPix.res
            }
            return resRes * resPix.resMultiplier
        } else if let pixIn = self as? PIX & NODEInIO {
            if let remapPix = pixIn as? RemapPIX {
                guard let inResB = remapPix.inPixB?.resolution else { return nil }
                return inResB
            }
            guard let inRes = pixIn.nodeInList.first?.resolution else { return nil }
            if let cropPix = self as? CropPIX {
                return .size(inRes.size * LiveSize(cropPix.resScale))
            } else if let convertPix = self as? ConvertPIX {
                return .size(inRes.size * LiveSize(convertPix.resScale))
            } else if let flipFlopPix = self as? FlipFlopPIX {
                return flipFlopPix.flop != .none ? Res(inRes.raw.flopped) : inRes
            }
            return inRes
        } else { return nil }
    }
    
    public func nextRealResolution(callback: @escaping (Resolution) -> ()) {
        if let res = realResolution {
            callback(res)
            return
        }
        PixelKit.main.delay(frames: 1, done: {
            self.nextRealResolution(callback: callback)
        })
    }
    
    public func applyResolution(applied: @escaping () -> ()) {
        let res = resolution
//        guard let res = resolution else {
//            if pixelKit.frame == 0 {
//                pixelKit.logger.log(node: self, .detail, .res, "Waiting for potential layout, delayed one frame.")
//                pixelKit.delay(frames: 1, done: {
//                    self.applyResolution(applied: applied)
//                })
//                return
//            }
//            pixelKit.logger.log(node: self, .error, .res, "Unknown.")
//            return
//        }
        guard view.resSize == nil || view.resSize! != res.size.cg else {
            applied()
            return
        }
        view.setResolution(res)
        pixelKit.logger.log(node: self, .info, .res, "Applied: \(res) aka \(res.w)x\(res.h)")
        applied()
//        delegate?.pixResChanged(self, to: res)
        // FIXME: Check if this is extra work..
        if let pixOut = self as? NODEOutIO {
            for pathList in pixOut.pixOutPathList {
                pathList.pixIn.applyResolution(applied: {})
            }
        }
    }
    
    func removeRes() {
        view.setResolution(nil)
    }
    
}
