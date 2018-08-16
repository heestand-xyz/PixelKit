//
//  PIXResolution.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-13.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
    var resolution: Res? {
        if let pixContent = self as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else { return nil }
                return Res(pixelBuffer: pixelBuffer)
            } else if let pixGenerator = pixContent as? PIXGenerator {
                return pixGenerator.res
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
            return pixIn.pixInList.first?.resolution
        } else { return nil }
    }
    
    func applyRes(applied: @escaping () -> ()) {
        guard let res = resolution else {
            Logger.main.log(pix: self, .error, .res, "Unknown.")
            return
        }
        view.setRes(res)
        Logger.main.log(pix: self, .info, .res, "Applied: \(res)")
        applied()
    }
    
}
