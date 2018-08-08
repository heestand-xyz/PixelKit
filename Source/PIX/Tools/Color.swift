//
//  PIXColor.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-08.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
    class Color: Codable {
        
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
        
        enum Space {
            case sRGB
            case P3
        }
        static let space: Space = .P3
        
        var ui: UIColor {
            switch Color.space {
            case .sRGB:
                return UIColor(red: r, green: g, blue: b, alpha: a)
            case .P3:
                return UIColor(displayP3Red: r, green: g, blue: b, alpha: a)
            }
        }
        
        var list: [CGFloat] {
            return [r, g, b, a]
        }
        
        init(_ uiColor: UIColor) {
            let ciColor = CIColor(color: uiColor)
            r = ciColor.red
            g = ciColor.green
            b = ciColor.blue
            a = ciColor.alpha
        }
        
    }
    
}

