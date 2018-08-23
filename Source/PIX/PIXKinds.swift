//
//  PIXKinds.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-10.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

extension PIX {
    
    enum Kind: String, Codable {
        case `nil`
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
        case blends
        case threshold
        case kaleidoscope
        case lookup
        case quantize
        case polygon
        case feedback
        case cross
        case color
        case rectangle
        case channelMix
        var type: PIX.Type {
            switch self {
            case .nil: return NilPIX.self
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
            case .blends: return BlendsPIX.self
            case .threshold: return ThresholdPIX.self
            case .kaleidoscope: return KaleidoscopePIX.self
            case .lookup: return LookupPIX.self
            case .quantize: return QuantizePIX.self
            case .polygon: return PolygonPIX.self
            case .feedback: return FeedbackPIX.self
            case .cross: return CrossPIX.self
            case .color: return ColorPIX.self
            case .rectangle: return RectanglePIX.self
            case .channelMix: return ChannelMixPIX.self
            }
        }
    }
    
}
