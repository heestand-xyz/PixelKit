//
//  PIXDecleration.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-10.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension PIX {
    
    enum Kind: String, Codable {
        case camera
        case levels
        case blur
        case res
        case edge
        case image
        case circle
        case gradient
        case lumaBlur
        case twirl
        case noise
        var type: PIX.Type {
            switch self {
            case .camera: return CameraPIX.self
            case .levels: return LevelsPIX.self
            case .blur: return BlurPIX.self
            case .res: return ResPIX.self
            case .edge: return EdgePIX.self
            case .image: return ImagePIX.self
            case .circle: return CirclePIX.self
            case .gradient: return GradientPIX.self
            case .lumaBlur: return LumaBlurPIX.self
            case .twirl: return TwirlPIX.self
            case .noise: return NoisePIX.self
            }
        }
    }
    
}
