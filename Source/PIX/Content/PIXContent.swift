//
//  PIXContent.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIXContent: PIX, PIXOut {
    
    var _contentAvailable: Bool = false
    public var contentAvailable: Bool { return _contentAvailable }
    var contentResolution: CGSize? { didSet { newResolution() } }
    var contentPixelBuffer: CVPixelBuffer?
//    var sourceImage: UIImage?
    
//    public init(shader: String) {
//        
//        super.init(shader: shader)
//    }
    
    override init(shader: String) {
        super.init(shader: shader)
        pixOutList = []
    }
    
    override func didRender(texture: MTLTexture) {
        super.didRender(texture: texture)
        _contentAvailable = true
    }
    
}
