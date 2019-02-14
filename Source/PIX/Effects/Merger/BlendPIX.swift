//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics

public class BlendPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var blendingMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
//    enum CodingKeys: String, CodingKey {
//        case blendingMode; case bypassTransform; case position; case rotation; case scale; case size
//    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendingMode.index), !bypassTransform.value ? 1 : 0, position.x.cg, position.y.cg, rotation.cg, scale.cg, size.width.cg, size.height.cg]
    }
    
}

