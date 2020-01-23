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
        realResolution ?? PixelKit.main.fallbackResolution
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
        } else if let pixIn = self as? PIX & NODEInIO {
            if let resPix = self as? ResolutionPIX {
                let resRes: Resolution
                if resPix.inheritInResolution {
                    guard let inResolution = (resPix.inputList.first as? PIX)?.realResolution else { return nil }
                    resRes = inResolution
                } else {
                    resRes = resPix.resolution
                }
                return resRes * resPix.resMultiplier
            }
            if #available(iOS 13.0, *) {
                if #available(OSX 10.15, *) {
                    if #available(tvOS 13.0, *) {
                        if self is SaliencyPIX {
                            return SaliencyPIX.saliencyResolution
                        }
                    }
                }
            }
            if #available(iOS 12.0, *) {
                if #available(OSX 10.14, *) {
                    if #available(tvOS 12.0, *) {
                        if self is DeepLabPIX {
                            return DeepLabPIX.deepLabResolution
                        }
                    }
                }
            }
            if let slicePix = self as? SlicePIX {
                guard let node3d = slicePix.input as? NODE3D else { return nil }
                let res3d = node3d.renderedResolution3d
                switch slicePix.axis {
                case .x: return .custom(w: res3d.y, h: res3d.z)
                case .y: return .custom(w: res3d.x, h: res3d.z)
                case .z: return .custom(w: res3d.x, h: res3d.y)
                }
            } else if let averagePix = self as? AveragePIX {
                guard let node3d = averagePix.input as? NODE3D else { return nil }
                let res3d = node3d.renderedResolution3d
                switch averagePix.axis {
                case .x: return .custom(w: res3d.y, h: res3d.z)
                case .y: return .custom(w: res3d.x, h: res3d.z)
                case .z: return .custom(w: res3d.x, h: res3d.y)
                }
            }
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
        if !pixelKit.render.engine.renderMode.isManual {
            if pixelKit.render.frame == 0 {
                #if os(macOS)
                let delayFrames = 2
                #else
                let delayFrames = 1
                #endif
                pixelKit.logger.log(node: self, .detail, .res, "Waiting for potential layout, delayed \(delayFrames) frames.")
                pixelKit.render.delay(frames: delayFrames, done: {
                    self.applyResolution(applied: applied)
                })
                return
            }
        }
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
