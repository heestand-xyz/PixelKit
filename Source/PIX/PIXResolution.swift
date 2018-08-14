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
            return pixContent.res.isAutoLayout ? view.autoLayoutRes : pixContent.res.resolution
        } else if let resPix = self as? ResPIX {
            let resResolution: CGSize
            if !resPix.inheritInRes {
                guard let res = resPix.res.isAutoLayout ? view.autoLayoutRes : resPix.res.resolution else { return nil }
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
    
    var wantsAutoLayoutRes: Bool? {
        if let pixContent = self as? PIXContent {
            return pixContent.res.isAutoLayout
        } else if let resPix = self as? ResPIX {
            return resPix.res.isAutoLayout && !resPix.inheritInRes
        }
        return nil
    }
    
//    var inPixWantsAutoUpstreamRes: Bool? {
//        // CHECK scenario; post connect, addSubview
//        guard let pixIn = self as? PIXInIO else { print(self, "ERROR", "inPixWantsAutoUpstreamRes", "PIXIn's Only"); return nil }
//        guard let pixOut = pixIn.pixInList.first else { print(self, "ERROR", "inPixWantsAutoUpstreamRes", "No PIX Out found."); return nil }
//        if let wantsAutoRes = pixOut.wantsAutoRes {
//            return wantsAutoRes && pixOut.view.superview == nil
//        } else {
//            guard let pixInOut = pixOut as? PIX & PIXIn else { print(self, "ERROR", "inPixWantsAutoUpstreamRes", "PIX Out is not PIX In."); return nil }
//            return pixInOut.inPixWantsAutoUpstreamRes
//        }
//    }
    
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
            if wantsAutoLayoutRes == true {
                view.autoResReadyCallback = {
                    self.view.autoResReadyCallback = nil
                    self.applyRes(applied: {
                        applied()
                    })
                }
            } else {
//                if let pixIn = self as? PIXInIO {
//                    if pixIn.connectedIn {
//                        if inPixWantsAutoUpstreamRes! {
//                            if HxPxE.main.frameIndex < 10 { print(self, "Will Find Res") }
//                            pixIn.pixInList.first!.applyRes {
//                                self.applyRes {
//                                    applied()
//                                }
//                            }
//                            return
//                        }
//                    }
//                }
                if HxPxE.main.frameIndex < 10 { print(self, "ERROR", "Res:", "Resolution unknown.") }
            }
            return
        }
        view.setResolution(resolution)
        if HxPxE.main.frameIndex < 10 { print(self, "Did Apply Res:", resolution) }
        applied()
    }
    
}
