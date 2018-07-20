//
//  PIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public class PIX {
    
    var texture: MTLTexture?
    
    public let view: UIView
    
    public var image: UIImage? {
        guard let texture = texture else { return nil }
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else { return nil }
        return UIImage(ciImage: ciImage)
    }
    
    public init() {
        
        view = UIView()
        
    }
    
}
