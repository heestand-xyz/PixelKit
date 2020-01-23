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
    let saliencyPix: SaliencyPIX
    let blendPix: BlendPIX
    let finalPix: PIX
    
    init() {
        
        PixelKit.main.logAll()
        
        imagePix = ImagePIX()
        imagePix.image = UIImage(named: "test")!
        
        saliencyPix = SaliencyPIX()
        saliencyPix.input = imagePix
        
        blendPix = BlendPIX()
        blendPix.blendMode = .multiply
        blendPix.inputA = imagePix
        blendPix.inputB = saliencyPix
        blendPix.placement = .fill
        blendPix.extend = .hold
        
        finalPix = blendPix
        
    }
    
}
