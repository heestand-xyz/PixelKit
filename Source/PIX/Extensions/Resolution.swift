//
//  PIXResolution.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-13.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import RenderKit
import Resolution
import CoreGraphics

extension PIX {
    
    public var derivedResolution: Resolution? {
        guard !bypass else {
            if let pixIn = self as? NODEInIO {
                return (pixIn.inputList.first as? PIX)?.derivedResolution
            } else { return nil }
        }
        if let resolution: Resolution = customResolution {
            return resolution
        }
        if let pixContent = self as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                if let imagePix = pixResource as? ImagePIX {
                    if let res = imagePix.resizedResolution {
                        return res
                    }
                    guard let image = imagePix.image else { return nil }
                    #if !os(macOS)
                    let scale: CGFloat = image.scale
                    #else
                    var scale: CGFloat = 1.0
                    if let pixelsWide: Int = image.representations.first?.pixelsWide {
                        scale = CGFloat(pixelsWide) / image.size.width
                    }
                    #endif
                    return Resolution.size(image.size) * scale
                } else {
                    #if !os(tvOS)
                    if #available(OSX 10.13, *) {
                        if let webPix = pixResource as? WebPIX {
                            return webPix.resolution
                        }
                    }
                    #endif
                    guard var resourceResolution: Resolution = pixResource.resourceResolution else { return nil }
                    if pixResource.flop {
                        resourceResolution = Resolution(resourceResolution.raw.flopped)
                    }
                    return resourceResolution
                }
            } else if let pixGenerator = pixContent as? PIXGenerator {
                return pixGenerator.resolution
            } else if let pixSprite = pixContent as? PIXSprite {
                return .size(pixSprite.scene?.size ?? CGSize(width: 128, height: 128)) * Resolution.scale
            } else if let pixCustom = pixContent as? PIXCustom {
                return pixCustom.resolution
            } else { return nil }
        } else if let pixIn = self as? PIX & NODEInIO {
            if let resPix = self as? ResolutionPIX {
                let resRes: Resolution
                if resPix.inheritResolution {
                    guard let inResolution = (resPix.inputList.first as? PIX)?.derivedResolution else { return nil }
                    resRes = inResolution
                } else {
                    resRes = resPix.resolution
                }
                return resRes * resPix.resolutionMultiplier
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
            if let stackPix = self as? StackPIX {
                return stackPix.resolution
            }
            if let remapPix = pixIn as? RemapPIX {
                guard let inResB = (remapPix.inputB as? PIX)?.derivedResolution else { return nil }
                return inResB
            }
            guard let inRes = (pixIn.inputList.first as? PIX)?.derivedResolution else { return nil }
            if let cropPix = self as? CropPIX {
                return .size(CGSize(width: inRes.size.width * cropPix.resScale.width,
                                    height: inRes.size.height * cropPix.resScale.height))
            } else if let convertPix = self as? ConvertPIX {
                return .size(CGSize(width: inRes.size.width * convertPix.resScale.width,
                                    height: inRes.size.height * convertPix.resScale.height))
            } else if let flipFlopPix = self as? FlipFlopPIX {
                return flipFlopPix.flop != .none ? Resolution(inRes.raw.flopped) : inRes
            }
            return inRes
        } else { return nil }
    }
    
//    public func nextRealResolution(callback: @escaping (Resolution) -> ()) {
//        if let resolution: Resolution = derivedResolution {
//            callback(resolution)
//            return
//        }
//        PixelKit.main.render.delay(frames: 1, done: {
//            self.nextRealResolution(callback: callback)
//        })
//    }
    
    #warning("PixelKit - Apply Resolution without closure")
    public func applyResolution(applied: @escaping () -> ()) {
        if derivedResolution == nil {
            pixelKit.logger.log(node: self, .warning, .resolution, "Apply Resolution - Derived Resolution not found. Using fallback resolution of \(PixelKit.main.fallbackResolution).")
        }
        finalResolution = derivedResolution ?? PixelKit.main.fallbackResolution
//        if !pixelKit.render.engine.renderMode.isManual {
//            if pixelKit.render.frame == 0 {
//                #if os(macOS)
//                let delayFrames = 2
//                #else
//                let delayFrames = 1
//                #endif
//                pixelKit.logger.log(node: self, .detail, .resolution, "Waiting for potential layout, delayed \(delayFrames) frames.")
//                pixelKit.render.delay(frames: delayFrames, done: {
//                    self.applyResolution(applied: applied)
//                })
//                return
//            }
//        }
        additionalViews.forEach { view in
            guard view.resolutionSize == nil || view.resolutionSize! != finalResolution.size else { return }
            view.setResolution(finalResolution)
        }
        guard view.resolutionSize == nil || view.resolutionSize! != finalResolution.size else {
            applied()
            return
        }
        view.setResolution(finalResolution)
        pixelKit.logger.log(node: self, .info, .resolution, "Apply Resolution: \(finalResolution)")
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
        additionalViews.forEach { view in
            view.setResolution(nil)
        }
    }
    
}
