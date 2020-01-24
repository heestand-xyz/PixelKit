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
    
    let imagePix: ImagePIX
    let colorConvertPix: ColorConvertPIX
    let finalPix: PIX
    
    init() {
        
        PixelKit.main.logAll()
        
        imagePix = ImagePIX()
        imagePix.image = UIImage(named: "test")!
        
        colorConvertPix = ColorConvertPIX()
        colorConvertPix.ccWay = .hsvToRgb
//        colorConvertPix.ccIndex = .third
        colorConvertPix.input = imagePix
        
        finalPix = colorConvertPix
        
    }
    
}
