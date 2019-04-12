//
//  ArrayPIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-04-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public class ArrayPIX: PIXMultiEffect, PIXAuto {
    
    override open var shader: String { return "effectMultiArrayPIX" }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var points: [LivePoint] = [.zero] { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index)]
    }
    
    public override var uniformArray: [[CGFloat]] {
        return points.map({ point -> [CGFloat] in
            return point.uniformList
        })
    }
    
}
