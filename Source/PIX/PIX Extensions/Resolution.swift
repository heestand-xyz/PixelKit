//
//  PIXResolution.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-13.
//  Open Source - MIT License
//

import RenderKit
import LiveValues
import RenderKit
import CoreGraphics

extension PIX {
    
    public var renderResolution: Resolution {
        realResolution ?? .auto(render: pixelKit.render)
    }
    
    public var realResolution: Resolution? {
        guard !bypass else {
            if let pixIn = self as? NODEInIO {
                return (pixIn.inputList.first as? PIX)?.realResolution
            } else { return nil }
        }
        if let pixContent = self as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                if let imagePix = pixResource as? ImagePIX {
                    if let res = imagePix.resizedResolution {
                        return res
                    }
                    guard let image = imagePix.image else { return nil }
                    #if !os(macOS)
                    return Resolution.cgSize(image.size) * LiveFloat(image.scale)
                    #else
                    return Resolution.cgSize(image.size)
                    #endif
                } else {
                    #if !os(tvOS)
                    if let webPix = pixResource as? WebPIX {
                        return webPix.resolution
                    }
                    #endif
                    guard let pixelBuffer = pixResource.pixelBuffer else { return nil }
                    var bufferRes = Resolution(pixelBuffer: pixelBuffer)
                    if pixResource.flop {
                        bufferRes = Resolution(bufferRes.raw.flopped)
                    }
                    return bufferRes
                }
            } else if let pixGenerator = pixContent as? PIXGenerator {
                return pixGenerator.resolution
            } else if let pixSprite = pixContent as? PIXSprite {
                return .cgSize(pixSprite.scene?.size ?? CGSize(width: 128, height: 128))
            } else if let pixCustom = pixContent as? PIXCustom {
                return pixCustom.resolution
            } else { return nil }
        } else if let resPix = self as? ResolutionPIX {
            let resRes: Resolution
            if resPix.inheritInResolution {
                guard let inResolution = (resPix.inputList.first as? PIX)?.realResolution else { return nil }
                resRes = inResolution
            } else {
                resRes = resPix.resolution
            }
            return resRes * resPix.resMultiplier
        } else if let pixIn = self as? PIX & NODEInIO {
            if let remapPix = pixIn as? RemapPIX {
                guard let inResB = (remapPix.inputB as? PIX)?.realResolution else { return nil }
                return inResB
            }
            guard let inRes = (pixIn.inputList.first as? PIX)?.realResolution else { return nil }
            if let cropPix = self as? CropPIX {
                return .size(inRes.size * LiveSize(cropPix.resScale))
            } else if let convertPix = self as? ConvertPIX {
                return .size(inRes.size * LiveSize(convertPix.resScale))
            } else if let flipFlopPix = self as? FlipFlopPIX {
                return flipFlopPix.flop != .none ? Resolution(inRes.raw.flopped) : inRes
            }
            return inRes
        } else { return nil }
    }
    
    public func nextRealResolution(callback: @escaping (Resolution) -> ()) {
        if let res = realResolution {
            callback(res)
            return
        }
        PixelKit.main.render.delay(frames: 1, done: {
            self.nextRealResolution(callback: callback)
        })
    }
    
    public func applyResolution(applied: @escaping () -> ()) {
        let res = renderResolution
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
        guard view.resolutionSize == nil || view.resolutionSize! != res.size.cg else {
            applied()
            return
        }
        view.setResolution(res)
        pixelKit.logger.log(node: self, .info, .res, "Applied: \(res) [\(res.w)x\(res.h)]")
        applied()
//        delegate?.pixResChanged(self, to: res)
        // FIXME: Check if this is extra work..
        if let pixOut = self as? NODEOutIO {
            for pathList in pixOut.outputPathList {
                pathList.nodeIn.applyResolution(applied: {})
            }
        }
    }
    
    func removeRes() {
        view.setResolution(nil)
    }
    
}
