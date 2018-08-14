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
            return pixContent.res.isAuto ? view.autoRes : pixContent.res.resolution
        } else if let resPix = self as? ResPIX {
            let resResolution: CGSize
            if !resPix.inheritInRes {
                guard let res = resPix.res.isAuto ? view.autoRes : resPix.res.resolution else { return nil }
                resResolution = res
            } else {
                guard let inRes = resPix.pixInList.first?.resolution else { return nil }
                resResolution = inRes
            }
            var multRes = CGSize(width: resResolution.width * resPix.resMult, height: resResolution.height * resPix.resMult)
            if multRes.width < 1 { multRes.width = 1 }
            if multRes.height < 1 { multRes.height = 1 }
            return multRes
        } else if let pixIn = self as? PIX & PIXInIO {
            return pixIn.pixInList.first?.resolution
        } else {
            return nil
        }
    }
    
    var wantsAutoRes: Bool {
        if let pixContent = self as? PIXContent {
            if pixContent.res.isAuto {
                return true
            }
        } else if let resPix = self as? ResPIX {
            if resPix.res.isAuto && !resPix.inheritInRes {
                return true
            }
        }
        return false
    }
    
//    var wantsInheritedRes: Bool? {
//        if let resPix = self as? ResPIX {
//            if resPix.inheritInRes {
//                return true
//            }
//        } else if self is PIXIn {
//            return true
//        }
//        return false
//    }
    
    func applyRes(applied: @escaping () -> ()) {
        if HxPxE.main.frameIndex < 10 { print(self, "Will Apply Res") }
        guard let resolution = resolution else {
            if wantsAutoRes { // CHECK downstream
                view.autoResReadyCallback = {
                    self.view.autoResReadyCallback = nil
                    self.applyRes(applied: {
                        applied()
                    })
                }
            } else {
                if HxPxE.main.frameIndex < 10 { print(self, "ERROR", "Res:", "Resolution unknown.") }
            }
            return
        }
        view.setResolution(resolution)
        if HxPxE.main.frameIndex < 10 { print(self, "Did Apply Res:", resolution) }
        applied()
    }
    
}
