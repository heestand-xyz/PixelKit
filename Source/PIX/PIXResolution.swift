//
//  PIXResolution.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-13.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
    var resolution: PIX.Res? {
        if let pixContent = self as? PIXContent {
            return pixContent.res
        } else if let resPix = self as? ResPIX {
            let resRes: PIX.Res
            if resPix.inheritInRes {
                guard let inResolution = resPix.pixInList.first?.resolution else { return nil }
                resRes = inResolution
            } else {
                resRes = resPix.res
            }
            return resRes * resPix.resMultiplier
        } else if let pixIn = self as? PIX & PIXInIO {
            return pixIn.pixInList.first?.resolution
        } else {
            return nil
        }
    }
    
    func applyRes(applied: @escaping () -> ()) {
        guard let res = resolution else {
            if HxPxE.main.frameIndex < 10 { print(self, "ERROR", "Res:", "Resolution unknown.") }
            return
        }
        view.setRes(res)
        if HxPxE.main.frameIndex < 10 { print(self, "Applied Res:", res) }
        applied()
    }
    
}
