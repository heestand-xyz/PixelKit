//
//  ArrayPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2019-04-12.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit
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
    
    override open var shaderName: String { return "effectMultiArrayPIX" }
    
    override public var shaderNeedsAspect: Bool { return true }
    
    // MARK: - Public Properties
    
    public var blendMode: BlendMode = .add { didSet { setNeedsRender() } }
    public var coordinates: [Coordinate] = []
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        var liveValues: [LiveValue] = [bgColor]
        for coordinate in coordinates {
            liveValues.append(coordinate.position)
            liveValues.append(coordinate.rotation)
            liveValues.append(coordinate.scale)
            liveValues.append(coordinate.textueIndex)
        }
        return liveValues
    }
    
    open override var uniforms: [CGFloat] {
        var uniforms = [CGFloat(blendMode.index), CGFloat(coordinates.count)]
        uniforms.append(contentsOf: bgColor.uniformList)
        return uniforms
    }
    
    public override var uniformArray: [[CGFloat]] {
        return coordinates.map({ coordinate -> [CGFloat] in
            var uniforms: [CGFloat] = []
            uniforms.append(contentsOf: coordinate.position.uniformList)
            uniforms.append(coordinate.scale.uniform)
            uniforms.append(coordinate.rotation.uniform)
            uniforms.append(CGFloat(coordinate.textueIndex.uniform))
            return uniforms
        })
    }
    
    // MARK - Life Cycle
    
    public required init() {
        
        super.init()
        
        name = "array"
        
        buildGrid(xCount: 5, yCount: 5)
        
    }
    
    // MARK - Builders
    
    public func buildGrid(xCount: Int, xRange: ClosedRange<CGFloat> = -0.5...0.5, yCount: Int, yRange: ClosedRange<CGFloat> = -0.5...0.5, scaleMultiplier: LiveFloat = 1.0) {
        coordinates = []
        for x in 0..<xCount {
            for y in 0..<yCount {
                let i = x * xCount + y
                let xFraction = LiveFloat(x) / LiveFloat(xCount - 1);
                let yFraction = LiveFloat(y) / LiveFloat(yCount - 1);
                let xBounds = LiveFloat(xRange.upperBound - xRange.lowerBound)
                let yBounds = LiveFloat(yRange.upperBound - yRange.lowerBound)
                let position = LivePoint(x: LiveFloat(xRange.lowerBound) + xBounds * xFraction,
                                       y: LiveFloat(yRange.lowerBound) + yBounds * yFraction)
                let coordinate = Coordinate(position, scale: (yBounds / LiveFloat(yCount)) * scaleMultiplier, textueIndex: LiveInt(inputs.count > 0 ? i % inputs.count : 0))
                coordinates.append(coordinate)
            }
        }
    }
    
    public func buildHexagonalGrid(scale: CGFloat = 0.4, scaleMultiplier: LiveFloat = 1.0) {
        guard scale != 0.0 else { return }
        coordinates = []
        let aspect = renderResolution.aspect.cg
        let hexScale: CGFloat = sqrt(0.75)
        let xScale = hexScale * scale
        let yScale = (3 / 4) * scale
        var xEdge = (aspect - xScale) / xScale / 2
        var yEdge = (1.0 - yScale) / yScale / 2
        xEdge = round(xEdge * 1_000_000) / 1_000_000
        yEdge = round(yEdge * 1_000_000) / 1_000_000
        let xEdgeCount = Int(ceil(xEdge))
        let yEdgeCount = Int(ceil(yEdge))
        var i = 0
        for x in (-xEdgeCount - 1)...xEdgeCount {
            for y in -yEdgeCount...yEdgeCount {
                let isOdd = abs(y) % 2 == 1
                let position = LivePoint(x: LiveFloat(x) * LiveFloat(xScale) * scaleMultiplier + LiveFloat(isOdd ? xScale / 2 : 0) * scaleMultiplier,
                                         y: LiveFloat(y) * LiveFloat(yScale) * scaleMultiplier)
                let coordinate = Coordinate(position, scale: LiveFloat(scale) /* * sqrt(0.75) */ * scaleMultiplier, textueIndex: LiveInt(inputs.count > 0 ? i % inputs.count : 0))
                coordinates.append(coordinate)
                i += 1
            }
        }
    }
    
    public func buildCircle(count: Int, scale: LiveFloat = 0.5, scaleMultiplier: LiveFloat = 1.0) {
        coordinates = []
        for i in 0..<count {
            let fraction = LiveFloat(i) / LiveFloat(count);
            let position = LivePoint(x: cos(fraction * .pi * 2) * scale,
                                   y: sin(fraction * .pi * 2) * scale)
            let coordinate = Coordinate(position, scale: (1.0 / LiveFloat(count)) * .pi * scaleMultiplier, rotation: fraction + 0.25, textueIndex: LiveInt(inputs.count > 0 ? i % inputs.count : 0))
            coordinates.append(coordinate)
        }
    }
    
    public func buildLine(count: Int, from fromPoint: LivePoint, to toPoint: LivePoint, scaleMultiplier: LiveFloat = 1.0) {
        coordinates = []
        for i in 0..<count {
            let fraction = LiveFloat(i) / LiveFloat(count - 1);
            let vector = LivePoint(x: toPoint.x - fromPoint.x,
                                 y: toPoint.y - fromPoint.y)
            let position = LivePoint(x: fromPoint.x + vector.x * fraction,
                                   y: fromPoint.y + vector.y * fraction)
            let rotation: LiveFloat = atan2(vector.y, vector.x) / (.pi * 2) + 0.25
            let coordinate = Coordinate(position, scale: (1.0 / LiveFloat(count)) * scaleMultiplier, rotation: rotation, textueIndex: LiveInt(inputs.count > 0 ? i % inputs.count : 0))
            coordinates.append(coordinate)
        }
    }
    
    public func buildRandom(count: Int) {
        coordinates = []
        let pixCount = inputs.isEmpty ? 1 : inputs.count
        for _ in 0..<count {
            let aspect = renderResolution.aspect.cg
            let position = LivePoint(x: LiveFloat.random(in: (-aspect / 2)...(aspect / 2)),
                                   y: LiveFloat.random(in: -0.5...0.5))
            let rotation = LiveFloat.random(in: 0.0...1.0)
            let scale = LiveFloat.random(in: 0.1...0.5)
            let textueIndex = Int.random(in: 0..<pixCount)
            let coordinate = Coordinate(position, scale: scale, rotation: rotation, textueIndex: LiveInt(textueIndex))
            coordinates.append(coordinate)
        }
    }
    
}
