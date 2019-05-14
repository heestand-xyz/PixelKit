//
//  PIXResolution.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-13.
//  Open Source - MIT License
//

import CoreGraphics

extension PIX {
    
    public var resolution: Res? {
        if let pixContent = self as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else { return nil }
                var bufferRes = Res(pixelBuffer: pixelBuffer)
                if pixResource.flop {
                    bufferRes = Res(bufferRes.raw.flopped)
                }
                return bufferRes
            } else if let pixGenerator = pixContent as? PIXGenerator {
                return pixGenerator.res
            } else if let pixSprite = pixContent as? PIXSprite {
                return .cgSize(pixSprite.scene?.size ?? CGSize(width: 128, height: 128))
            } else { return nil }
        } else if let resPix = self as? ResPIX {
            let resRes: Res
            if resPix.inheritInRes {
                guard let inResolution = resPix.pixInList.first?.resolution else { return nil }
                resRes = inResolution
            } else {
                resRes = resPix.res
            }
            return resRes * resPix.resMultiplier
        } else if let pixIn = self as? PIX & PIXInIO {
            if let remapPix = pixIn as? RemapPIX {
                guard let inResB = remapPix.inPixB?.resolution else { return nil }
                return inResB
            }
            guard let inRes = pixIn.pixInList.first?.resolution else { return nil }
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
    
    public func nextResolution(callback: @escaping (Res) -> ()) {
        if let res = resolution {
            callback(res)
            return
        }
        PixelKit.main.delay(frames: 1, done: {
            self.nextResolution(callback: callback)
        })
    }
    
    public func applyRes(applied: @escaping () -> ()) {
        guard let res = resolution else {
            if pixelKit.frame == 0 {
                pixelKit.log(pix: self, .detail, .res, "Waiting for potential layout, delayed one frame.")
                pixelKit.delay(frames: 1, done: {
                    self.applyRes(applied: applied)
                })
                return
            }
            pixelKit.log(pix: self, .error, .res, "Unknown.")
            return
        }
        guard view.res == nil || view.res! != res else {
            applied()
            return
        }
        view.setRes(res)
        pixelKit.log(pix: self, .info, .res, "Applied: \(res)")
        applied()
//        delegate?.pixResChanged(self, to: res)
        // FIXME: Check if this is extra work..
        if let pixOut = self as? PIXOutIO {
            for pathList in pixOut.pixOutPathList {
                pathList.pixIn.applyRes(applied: {})
            }
        }
    }
    
}
