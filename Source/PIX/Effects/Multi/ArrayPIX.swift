//
//  ArrayPIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-04-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public struct Coordinate {
    public var position: LivePoint
    public var scale: LiveFloat
    public var rotation: LiveFloat
    public var textueIndex: LiveInt
    public init(_ position: LivePoint, scale: LiveFloat = 1.0, rotation: LiveFloat = 0.0, textueIndex: LiveInt = 0) {
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.textueIndex = textueIndex
    }
}

public class ArrayPIX: PIXMultiEffect, PIXAuto {
    
    override open var shader: String { return "effectMultiArrayPIX" }
    
    override var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var coordinates: [Coordinate] = [] { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(blendMode.index), CGFloat(coordinates.count)]
    }
    
    public override var uniformArray: [[CGFloat]] {
        return coordinates.map({ coordinate -> [CGFloat] in
            var uniforms: [CGFloat] = []
            uniforms.append(contentsOf: coordinate.position.uniformList)
            uniforms.append(coordinate.scale.uniform)
            uniforms.append(coordinate.rotation.uniform)
            return uniforms
        })
    }
    
    // MARK - Life Cycle
    
    public required init() {
        
        super.init()
        
//        buildGrid(xCount: 5, yCount: 5)
        
    }
    
    // MARK - Builders

    func buildGrid(xCount: Int, xRange: ClosedRange<CGFloat> = -0.5...0.5, yCount: Int, yRange: ClosedRange<CGFloat> = -0.5...0.5) {
        coordinates = []
        for x in 0..<xCount {
            for y in 0..<yCount {
                let xFraction = CGFloat(x) / CGFloat(xCount - 1);
                let yFraction = CGFloat(y) / CGFloat(yCount - 1);
                let xRangeBounds = xRange.upperBound - xRange.lowerBound
                let yRangeBounds = yRange.upperBound - yRange.lowerBound
                let position = LivePoint(x: LiveFloat(xRange.lowerBound + xRangeBounds * xFraction),
                                         y: LiveFloat(yRange.lowerBound + yRangeBounds * yFraction))
                let coordinate = Coordinate(position, scale: LiveFloat(yRangeBounds) / LiveFloat(yCount))
                coordinates.append(coordinate)
            }
        }
    }
    
}
