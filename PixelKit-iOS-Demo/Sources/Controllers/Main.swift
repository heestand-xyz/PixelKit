//
//  Main.swift
//  PixelKit-iOS-Demo
//
//  Created by Anton Heestand on 2020-01-20.
//  Copyright © 2020 Hexagons. All rights reserved.
//

import UIKit
import LiveValues
import RenderKit
import PixelKit

class Main: ObservableObject {
    
    let paintPix: PaintPIX
    let finalPix: PIX
    var finalView: UIView { paintPix.canvasView }
    
    init() {
        
        PixelKit.main.logAll()
        
        paintPix = PaintPIX()
        
        finalPix = paintPix
        
    }
    
}
