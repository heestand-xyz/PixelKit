//
//  ResPIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-03.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class ResPIX: PIXSingleEffector {
    
    public var res = CGSize(width: 128, height: 128) { didSet { view.setResolution(res) } }
    
    public init() {
        super.init(shader: "nil")
        view.setResolution(res)
    }
    
}
