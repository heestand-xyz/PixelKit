//
//  Main.swift
//  PixelKit-iOS-Demo
//
//  Created by Anton Heestand on 2020-01-20.
//  Copyright © 2020 Hexagons. All rights reserved.
//

import Foundation
import LiveValues
import RenderKit
import PixelKit

class Main: ObservableObject {
    
    let gradientPix: GradientPIX
    let clampPix: ClampPIX
    let finalPix: PIX
    
    init() {
        
        gradientPix = GradientPIX()
        gradientPix.direction = .vertical
        
        clampPix = ClampPIX()
        clampPix.input = gradientPix
        clampPix.low = 0.4
        clampPix.high = 0.6
        clampPix.style = .relative
//        clampPix.clampAlpha = true
        
        finalPix = clampPix
        
    }
    
}
