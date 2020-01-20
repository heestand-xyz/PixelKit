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
    
    let polygonPix: PolygonPIX
    let finalPix: PIX
    
    init() {
        polygonPix = PolygonPIX()
        finalPix = polygonPix
    }
    
}
