//
//  PIXContent.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXContent: PIX, PIXOutIO {
    
    public var res: PIX.Res? { didSet { applyRes { self.setNeedsRender() } } }
    
    var pixOutPathList: [PIX.OutPath] = []
    var connectedOut: Bool { return !pixOutPathList.isEmpty }

    let isResource: Bool
    var contentPixelBuffer: CVPixelBuffer?
    
    init(res: PIX.Res?, resource: Bool = false) {
        isResource = resource
        self.res = res
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
