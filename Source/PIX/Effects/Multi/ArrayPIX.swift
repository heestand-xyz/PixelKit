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
    
    override public var liveValues: [LiveValue] {
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
    
    public func buildGrid(xCount: Int, xRange: ClosedRange<CGFloat> = -0.5...0.5, yCount: Int, yRange: ClosedRange<CGFloat> = -0.5...0.5, scaleMultiplier: CGFloat = 1.0) {
        coordinates = []
        for x in 0..<xCount {
            for y in 0..<yCount {
                let xFraction = CGFloat(x) / CGFloat(xCount - 1);
                let yFraction = CGFloat(y) / CGFloat(yCount - 1);
                let xBounds = xRange.upperBound - xRange.lowerBound
                let yBounds = yRange.upperBound - yRange.lowerBound
                let position = CGPoint(x: xRange.lowerBound + xBounds * xFraction,
                                       y: yRange.lowerBound + yBounds * yFraction)
                let coordinate = Coordinate(position, scale: (yBounds / CGFloat(yCount)) * scaleMultiplier)
                coordinates.append(coordinate)
            }
        }
    }
    
    public func buildHexagonalGrid(scale: CGFloat = 0.4) {
        coordinates = []
        let aspect = resolution?.aspect ?? 1.0
        let hexScale: CGFloat = sqrt(0.75)
        let xScale = hexScale * scale
        let yScale = (3 / 4) * scale
        var xEdge = (aspect - xScale) / xScale / 2
        var yEdge = (1.0 - yScale) / yScale / 2
        xEdge = round(xEdge * 1_000_000) / 1_000_000
        yEdge = round(yEdge * 1_000_000) / 1_000_000
        let xEdgeCount = Int(ceil(xEdge))
        let yEdgeCount = Int(ceil(yEdge))
        for x in (-xEdgeCount - 1)...xEdgeCount {
            for y in -yEdgeCount...yEdgeCount {
                let isOdd = abs(y) % 2 == 1
                let position = CGPoint(x: CGFloat(x) * xScale + (isOdd ? xScale / 2 : 0),
                                       y: CGFloat(y) * yScale)
                let coordinate = Coordinate(position, scale: scale)
                coordinates.append(coordinate)
            }
        }
    }
    
    public func buildCircle(count: Int, scale: CGFloat = 0.5, scaleMultiplier: CGFloat = 1.0) {
        coordinates = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count);
            let position = CGPoint(x: cos(fraction * .pi * 2) * scale,
                                   y: sin(fraction * .pi * 2) * scale)
            let coordinate = Coordinate(position, scale: (1.0 / CGFloat(count)) * .pi * scaleMultiplier, rotation: fraction + 0.25)
            coordinates.append(coordinate)
        }
    }
    
    public func buildLine(count: Int, from fromPoint: CGPoint, to toPoint: CGPoint, scaleMultiplier: CGFloat = 1.0) {
        coordinates = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1);
            let vector = CGPoint(x: toPoint.x - fromPoint.x,
                                 y: toPoint.y - fromPoint.y)
            let position = CGPoint(x: fromPoint.x + vector.x * fraction,
                                   y: fromPoint.y + vector.y * fraction)
            let rotation = atan2(vector.y, vector.x) / (.pi * 2) + 0.25
            let coordinate = Coordinate(position, scale: (1.0 / CGFloat(count)) * scaleMultiplier, rotation: rotation)
            coordinates.append(coordinate)
        }
    }
    
    public func buildRandom(count: Int) {
        coordinates = []
        let pixCount = inPixs.isEmpty ? 1 : inPixs.count
        for _ in 0..<count {
            let aspect = resolution?.aspect ?? 1.0
            let position = CGPoint(x: CGFloat.random(in: (-aspect / 2)...(aspect / 2)),
                                   y: CGFloat.random(in: -0.5...0.5))
            let rotation = CGFloat.random(in: 0.0...1.0)
            let scale = CGFloat.random(in: 0.1...0.5)
            let textueIndex = Int.random(in: 0..<pixCount)
            let coordinate = Coordinate(position, scale: scale, rotation: rotation, textueIndex: textueIndex)
            coordinates.append(coordinate)
        }
    }
    
}
