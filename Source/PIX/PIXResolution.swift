//
//  PIXResolution.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-13.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
    public var resolution: CGSize? {
        if let pixContent = self as? PIXContent {
            return pixContent.res?.size
        } else if let resPix = self as? ResPIX {
            let resSize: CGSize
            if !resPix.inheritInRes {
                resSize = resPix.res.size
            } else {
                guard let inRes = resPix.pixInList.first?.resolution else { return nil }
                resSize = inRes
            }
            var multRes = CGSize(width: resSize.width * resPix.resMult, height: resSize.height * resPix.resMult)
            if multRes.width < 1 { multRes.width = 1 }
            if multRes.height < 1 { multRes.height = 1 }
            return multRes
        } else if let pixIn = self as? PIX & PIXInIO {
            return pixIn.pixInList.first?.resolution
        }
        return nil
    }
    
    func applyRes(applied: @escaping () -> ()) {
        guard let resolution = resolution else {
            if HxPxE.main.frameIndex < 10 { print(self, "ERROR", "Res:", "Resolution unknown.") }
            return
        }
        view.setResolution(resolution)
        if HxPxE.main.frameIndex < 10 { print(self, "Applied Res:", resolution) }
        applied()
    }
    
}
