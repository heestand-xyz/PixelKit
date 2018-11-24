//
//  PIXResolution.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-13.
//  Copyright © 2018 Hexagons. All rights reserved.
//


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
                return .size(pixSprite.scene.size)
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
                return inRes * cropPix.resScale
            } else if let flipFlopPix = self as? FlipFlopPIX {
                return flipFlopPix.flop != nil ? Res(inRes.raw.flopped) : inRes
            }
            return inRes
        } else { return nil }
    }
    
    func applyRes(applied: @escaping () -> ()) {
        guard let res = resolution else {
            if pixels.frame == 0 {
                pixels.log(pix: self, .detail, .res, "Waiting for potential layout, delayed one frame.")
                pixels.delay(frames: 1, done: {
                    self.applyRes(applied: applied)
                })
                return
            }
            pixels.log(pix: self, .error, .res, "Unknown.")
            return
        }
        view.setRes(res)
        pixels.log(pix: self, .detail, .res, "Applied: \(res)")
        applied()
        delegate?.pixResChanged(self, to: res)
        // FIXME: Check if this is extra work..
        if let pixOut = self as? PIXOutIO {
            for pathList in pixOut.pixOutPathList {
                pathList.pixIn.applyRes(applied: {})
            }
        }
    }
    
}
