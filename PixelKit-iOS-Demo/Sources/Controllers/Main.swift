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
    let rainbowBlurPix: RainbowBlurPIX
//    let rainbowLumaBlurPix: RainbowLumaBlurPIX
    let finalPix: PIX
    
    init() {
        
        PixelKit.main.logAll()
        
        imagePix = ImagePIX()
        imagePix.image = UIImage(named: "test")!
        
//        gradientPix = GradientPIX()
        
        rainbowBlurPix = RainbowBlurPIX()
        rainbowBlurPix.input = imagePix
        rainbowBlurPix.style = .circle
        rainbowBlurPix.quality = .epic
        
//        rainbowLumaBlurPix = RainbowLumaBlurPIX()
//        rainbowLumaBlurPix.inputA = imagePix
//        rainbowLumaBlurPix.inputB = gradientPix !** 0.5
//        rainbowLumaBlurPix.style = .circle
//        rainbowLumaBlurPix.quality = .epic
        
        finalPix = rainbowBlurPix
        
    }
    
}
