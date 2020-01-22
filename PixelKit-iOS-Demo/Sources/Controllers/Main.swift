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
//    let gradientPix: GradientPIX
//    let rainbowLumaBlurPix: RainbowLumaBlurPIX
    let rainbowBlurPix: RainbowBlurPIX
    let finalPix: PIX
    
    init() {
        
        PixelKit.main.logAll()
        
        imagePix = ImagePIX()
        imagePix.image = UIImage(named: "test")!
        
//        gradientPix = GradientPIX()
//
//        rainbowLumaBlurPix = RainbowLumaBlurPIX()
//        rainbowLumaBlurPix.inputA = imagePix
//        rainbowLumaBlurPix.inputB = gradientPix
//        rainbowLumaBlurPix.radius = 0.5
//        rainbowLumaBlurPix.style = .angle
//        rainbowLumaBlurPix.angle = 0.25
        
        rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.input = imagePix
        rainbowBlurPix.radius = 0.5
        rainbowBlurPix.style = .angle
        rainbowBlurPix.angle = 0.25
        rainbowBlurPix.quality = .epic
        
        finalPix = rainbowBlurPix
        finalPix.pixView.liveTouch(active: true)
        
    }
    
}
