//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics

public class BlendPIX: PIXMergerEffect, PIXAuto {
    
    override open var shader: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var mode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(mode.index), !bypassTransform.uniform ? 1 : 0, position.x.uniform, position.y.uniform, rotation.uniform, scale.uniform, size.width.uniform, size.height.uniform]
    }
    
}

