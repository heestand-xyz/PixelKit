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

class Main: ObservableObject, NDIPIXDelegate {
    
//    let polygonPix: PolygonPIX
    let ndiPix: NDIPIX
    let finalPix: PIX
    
    init() {
//        polygonPix = PolygonPIX()
        ndiPix = NDIPIX()
        finalPix = ndiPix
        ndiPix.ndiDelegate = self
    }
    
    func ndiPIXUpdated(sources: [String]) {
        guard let source = sources.first else { return }
        ndiPix.connect(to: source)
    }
    
}
