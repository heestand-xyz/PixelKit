//
//  ArrayPIX.swift
//  Pixels
//
//  Created by Hexagons on 2019-04-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import CoreGraphics

public struct Coordinate {
    public var position: CGPoint
    public var scale: CGFloat
    public var rotation: CGFloat
    public var textueIndex: Int
    public init(_ position: CGPoint, scale: CGFloat = 1.0, rotation: CGFloat = 0.0, textueIndex: Int = 0) {
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
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [bgColor]
    }
    
    open override var uniforms: [CGFloat] {
        var uniforms = [CGFloat(blendMode.index), CGFloat(coordinates.count)]
        uniforms.append(contentsOf: bgColor.uniformList)
        return uniforms
    }
    
    public override var uniformArray: [[CGFloat]] {
        return coordinates.map({ coordinate -> [CGFloat] in
            var uniforms: [CGFloat] = []
            uniforms.append(coordinate.position.x)
            uniforms.append(coordinate.position.y)
            uniforms.append(coordinate.scale)
            uniforms.append(coordinate.rotation)
            uniforms.append(CGFloat(coordinate.textueIndex))
            return uniforms
        })
    }
    
    // MARK - Life Cycle
    
    public required init() {
        
        super.init()
        
        buildGrid(xCount: 5, yCount: 5)
        
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
                let position = CGPoint(x: xRange.lowerBound + xRangeBounds * xFraction,
                                         y: yRange.lowerBound + yRangeBounds * yFraction)
                let coordinate = Coordinate(position, scale: yRangeBounds / CGFloat(yCount))
                coordinates.append(coordinate)
            }
        }
    }
    
}
