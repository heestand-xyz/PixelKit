//
//  ArrayPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-12.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct Coordinate: Codable {
    public var position: CGPoint
    public var scale: CGFloat
    public var rotation: CGFloat
    public var opacity: CGFloat
    public var textureIndex: Int
    public init(_ position: CGPoint, scale: CGFloat = 1.0, rotation: CGFloat = 0.0, opacity: CGFloat = 1.0, textureIndex: Int = 0) {
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.opacity = opacity
        self.textureIndex = textureIndex
    }
}

final public class ArrayPIX: PIXMultiEffect, PIXViewable {
    
    public typealias Model = ArrayPixelModel
    
    private var model: Model {
        get { multiEffectModel as! Model }
        set { multiEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectMultiArrayPIX" }
    
    override public var shaderNeedsResolution: Bool { return true }
    
    // MARK: - Public Properties
    
    @LiveEnum("blendMode") public var blendMode: BlendMode = .add
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black

    public var coordinates: [Coordinate] {
        get { model.coordinates }
        set {
            model.coordinates = newValue
            render()
        }
    }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_blendMode, _backgroundColor]
    }
    
    override public var values: [Floatable] {
        var values: [Floatable] = [backgroundColor]
        for coordinate in coordinates {
            values.append(coordinate.position)
            values.append(coordinate.rotation)
            values.append(coordinate.scale)
            values.append(coordinate.opacity)
            values.append(coordinate.textureIndex)
        }
        return values
    }
    
    public override var uniforms: [CGFloat] {
        var uniforms = [CGFloat(blendMode.index), CGFloat(coordinates.count)]
        uniforms.append(contentsOf: backgroundColor.components)
        return uniforms
    }
    
    public override var uniformArray: [[CGFloat]] {
        return coordinates.map({ coordinate -> [CGFloat] in
            var uniforms: [CGFloat] = []
            uniforms.append(contentsOf: [coordinate.position.x, coordinate.position.y])
            uniforms.append(coordinate.scale)
            uniforms.append(coordinate.rotation)
            uniforms.append(coordinate.opacity)
            uniforms.append(CGFloat(coordinate.textureIndex))
            return uniforms
        })
    }
    
    public override var uniformArrayLength: Int? { 6 }
    
    // TODO: Add Resolution
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        #warning("Build Initial Grid in App")
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        blendMode = model.blendMode
        backgroundColor = model.backgroundColor

        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.blendMode = blendMode
        model.backgroundColor = backgroundColor

        super.liveUpdateModelDone()
    }
    
    // MARK - Builders
    
    public func buildGrid(xCount: Int,
                          xRange: ClosedRange<CGFloat> = -0.5...0.5,
                          yCount: Int,
                          yRange: ClosedRange<CGFloat> = -0.5...0.5,
                          scaleMultiplier: CGFloat = 1.0) {
        var coordinates: [Coordinate] = []
        for x in 0..<xCount {
            for y in 0..<yCount {
                let i = x * xCount + y
                let xFraction = CGFloat(x) / CGFloat(xCount - 1);
                let yFraction = CGFloat(y) / CGFloat(yCount - 1);
                let xBounds = CGFloat(xRange.upperBound - xRange.lowerBound)
                let yBounds = CGFloat(yRange.upperBound - yRange.lowerBound)
                let position = CGPoint(x: CGFloat(xRange.lowerBound) + xBounds * xFraction,
                                       y: CGFloat(yRange.lowerBound) + yBounds * yFraction)
                let coordinate = Coordinate(position, scale: (yBounds / CGFloat(yCount)) * scaleMultiplier, textureIndex: Int(inputs.count > 0 ? i % inputs.count : 0))
                coordinates.append(coordinate)
            }
        }
        self.coordinates = coordinates
    }
    
    public func buildHexagonalGrid(scale: CGFloat = 0.4,
                                   scaleMultiplier: CGFloat = 1.0) {
        guard scale != 0.0 else { return }
        var coordinates: [Coordinate] = []
        let aspect = finalResolution.aspect
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
                let position = CGPoint(x: CGFloat(x) * CGFloat(xScale) + CGFloat(isOdd ? xScale / 2 : 0),
                                         y: CGFloat(y) * CGFloat(yScale))
                let coordinate = Coordinate(position, scale: CGFloat(scale) * scaleMultiplier, textureIndex: Int(inputs.count > 0 ? i % inputs.count : 0))
                coordinates.append(coordinate)
                i += 1
            }
        }
        self.coordinates = coordinates
    }
    
    public func buildCircle(count: Int,
                            scale: CGFloat = 0.5,
                            scaleMultiplier: CGFloat = 1.0) {
        var coordinates: [Coordinate] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count);
            let position = CGPoint(x: cos(fraction * .pi * 2) * scale,
                                   y: sin(fraction * .pi * 2) * scale)
            let coordinate = Coordinate(position, scale: (1.0 / CGFloat(count)) * .pi * scaleMultiplier, rotation: fraction + 0.25, textureIndex: Int(inputs.count > 0 ? i % inputs.count : 0))
            coordinates.append(coordinate)
        }
        self.coordinates = coordinates
    }
    
    public func buildLine(count: Int,
                          from fromPoint: CGPoint,
                          to toPoint: CGPoint,
                          scaleMultiplier: CGFloat = 1.0) {
        var coordinates: [Coordinate] = []
        for i in 0..<count {
            let fraction = CGFloat(i) / CGFloat(count - 1);
            let vector = CGPoint(x: toPoint.x - fromPoint.x,
                                 y: toPoint.y - fromPoint.y)
            let position = CGPoint(x: fromPoint.x + vector.x * fraction,
                                   y: fromPoint.y + vector.y * fraction)
            let rotation: CGFloat = atan2(vector.y, vector.x) / (.pi * 2) + 0.25
            let coordinate = Coordinate(position, scale: (1.0 / CGFloat(count)) * scaleMultiplier, rotation: rotation, textureIndex: Int(inputs.count > 0 ? i % inputs.count : 0))
            coordinates.append(coordinate)
        }
        self.coordinates = coordinates
    }
    
    public func buildRandom(count: Int,
                            scale: CGFloat,
                            randomPosition: Bool = true,
                            randomScale: Bool = true,
                            randomRotation: Bool = true) {
        var coordinates: [Coordinate] = []
        let pixCount = inputs.isEmpty ? 1 : inputs.count
        for _ in 0..<count {
            let aspect: CGFloat = finalResolution.aspect
            let position: CGPoint = randomPosition ? CGPoint(x: CGFloat.random(in: (-aspect / 2)...(aspect / 2)), y: CGFloat.random(in: -0.5...0.5)) : .zero
            let rotation: CGFloat = randomRotation ? .random(in: 0.0...1.0) : 0.0
            let scale: CGFloat = randomScale ? .random(in: 0.0...scale) : scale
            let textureIndex: Int = .random(in: 0..<pixCount)
            let coordinate = Coordinate(position, scale: scale, rotation: rotation, textureIndex: Int(textureIndex))
            coordinates.append(coordinate)
        }
        self.coordinates = coordinates
    }
    
}

public extension NODEOut {

    func pixArrayGrid(xCount: Int, xRange: ClosedRange<CGFloat> = -0.5...0.5,
                      yCount: Int, yRange: ClosedRange<CGFloat> = -0.5...0.5,
                      scaleMultiplier: CGFloat = 1.0,
                      blendMode: BlendMode = .over) -> ArrayPIX {
        let arrayPix = ArrayPIX()
        arrayPix.name = ":array:"
        arrayPix.inputs = self is PIX & NODEOut ? [self as! PIX & NODEOut] : []
        arrayPix.blendMode = blendMode
        arrayPix.buildGrid(xCount: xCount, xRange: xRange, yCount: yCount, yRange: yRange, scaleMultiplier: scaleMultiplier)
        return arrayPix
    }
    
    func pixArrayHexagonalGrid(scale: CGFloat = 0.4,
                               scaleMultiplier: CGFloat = 1.0,
                               blendMode: BlendMode = .over) -> ArrayPIX {
        let arrayPix = ArrayPIX()
        arrayPix.name = ":array:"
        arrayPix.inputs = self is PIX & NODEOut ? [self as! PIX & NODEOut] : []
        arrayPix.blendMode = blendMode
        arrayPix.buildHexagonalGrid(scale: scale, scaleMultiplier: scaleMultiplier)
        return arrayPix
    }
    
    func pixArrayCircle(count: Int,
                        scale: CGFloat = 0.5,
                        scaleMultiplier: CGFloat = 1.0,
                        blendMode: BlendMode = .over) -> ArrayPIX {
        let arrayPix = ArrayPIX()
        arrayPix.name = ":array:"
        arrayPix.inputs = self is PIX & NODEOut ? [self as! PIX & NODEOut] : []
        arrayPix.blendMode = blendMode
        arrayPix.buildCircle(count: count, scale: scale, scaleMultiplier: scaleMultiplier)
        return arrayPix
    }
    
    func pixArrayLine(count: Int,
                      from fromPoint: CGPoint,
                      to toPoint: CGPoint,
                      scaleMultiplier: CGFloat = 1.0,
                      blendMode: BlendMode = .over) -> ArrayPIX {
        let arrayPix = ArrayPIX()
        arrayPix.name = ":array:"
        arrayPix.inputs = self is PIX & NODEOut ? [self as! PIX & NODEOut] : []
        arrayPix.blendMode = blendMode
        arrayPix.buildLine(count: count, from: fromPoint, to: toPoint, scaleMultiplier: scaleMultiplier)
        return arrayPix
    }
    
    func pixArrayRadom(count: Int,
                       scale: CGFloat = 0.5,
                       blendMode: BlendMode = .over) -> ArrayPIX {
        let arrayPix = ArrayPIX()
        arrayPix.name = ":array:"
        arrayPix.inputs = self is PIX & NODEOut ? [self as! PIX & NODEOut] : []
        arrayPix.blendMode = blendMode
        arrayPix.buildRandom(count: count, scale: scale)
        return arrayPix
    }
    
}

