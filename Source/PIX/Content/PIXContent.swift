//
//  PIXContent.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXContent: PIX, PIXOutIO {
    
    var _res: PIX.Res?
    public var res: PIX.Res? {
        set { _res = newValue; applyRes { self.setNeedsRender() } }
        get { return _res != nil ? _res! * HxPxE.main.globalContentResMultiplier : nil }
    }
    
    var pixOutPathList: [PIX.OutPath] = []
    var connectedOut: Bool { return !pixOutPathList.isEmpty }

    let isResource: Bool
    var contentPixelBuffer: CVPixelBuffer?
    
    init(res: PIX.Res?, resource: Bool = false) {
        isResource = resource
        _res = res
        super.init()
        pixOutPathList = []
        if !resource {
            applyRes {
                self.setNeedsRender()
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("PIXContent Decoder Initializer is not supported.") // CHECK
    }
    
}
