//
//  PIXResolution.swift
//  Pixels
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
                return .size((LiveSize(inRes.size) * LiveSize(cropPix.resScale)).cg)
            } else if let convertPix = self as? ConvertPIX {
                return .size((LiveSize(inRes.size) * LiveSize(convertPix.resScale)).cg)
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
        Pixels.main.delay(frames: 1, done: {
            self.nextResolution(callback: callback)
        })
    }
    
    public var liveResSize: LiveSize {
        return LiveSize({ () -> (CGSize) in
            // FIXME: Optional LiveSize
            let res: PIX.Res = self.resolution ?? ._128
            return res.size
        })
    }
    
    public var liveSize: LiveSize {
        return LiveSize.fill(aspect: LiveFloat({ () -> (CGFloat) in
            // FIXME: Optional LiveSize
            return self.resolution?.aspect ?? 1.0
        }))
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
        pixels.log(pix: self, .info, .res, "Applied: \(res)")
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
