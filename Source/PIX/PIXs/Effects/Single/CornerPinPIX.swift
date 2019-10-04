//
//  CornerPinPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-27.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics

public class CornerPinPIX: PIXSingleEffect, CustomGeometryDelegate, PIXAuto {
    
    override open var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    public struct Corners/*: Codable*/ {
        public var topLeft: CGPoint
        public var topRight: CGPoint
        public var bottomLeft: CGPoint
        public var bottomRight: CGPoint
    }
    public var corners: Corners { didSet { setNeedsRender() } }
    
    public var perspective: Bool = false { didSet { setNeedsRender() } }
    public var subdivisions: Int = 16  { didSet { setNeedsRender() } }
    
    // MARK: - Life Cycle
    
    public required init() {
        corners = Corners(topLeft: CGPoint(x: 0, y: 1),
                          topRight: CGPoint(x: 1, y: 1),
                          bottomLeft: CGPoint(x: 0, y: 0),
                          bottomRight: CGPoint(x: 1, y: 0))
        super.init()
        customGeometryActive = true
        customGeometryDelegate = self
        name = "cornerPin"
    }
    
    // MAKR: - Corenr Pin
    
    public func customVertices() -> Vertices? {
        
        let verticesRaw = cornerPin()
        let verticesMapped = mapVertices(verticesRaw)
        var vertexBuffers: [Float] = []
        for vertex in verticesMapped {
            vertexBuffers += vertex.buffer
        }
        
        let vertexBuffersSize = vertexBuffers.count * MemoryLayout<Float>.size
        let verticesBuffer = pixelKit.render.metalDevice.makeBuffer(bytes: vertexBuffers, length: vertexBuffersSize, options: [])!

//        let instanceCount = ((divisions + 1) * (divisions + 1)) / 3
        
        return Vertices(buffer: verticesBuffer, vertexCount: verticesMapped.count)
        
    }
    
    func scale(_ point: CGPoint, by scale: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scale, y: point.y * scale)
    }
    
    func add(_ pointA: CGPoint, _ pointB: CGPoint) -> CGPoint {
        return CGPoint(x: pointA.x + pointB.x, y: pointA.y + pointB.y)
    }
    
    func cornerPin() -> [[Vertex]] {
        
        let cx = [corners.bottomLeft.x, corners.bottomRight.x, corners.topRight.x, corners.topLeft.x]
        let cy = [corners.bottomLeft.y, corners.bottomRight.y, corners.topRight.y, corners.topLeft.y]
        
        let sX = cx[0]-cx[1]+cx[2]-cx[3]
        let sY = cy[0]-cy[1]+cy[2]-cy[3]
        
        let dX1 = cx[1]-cx[2]
        let dX2 = cx[3]-cx[2]
        let dY1 = cy[1]-cy[2]
        let dY2 = cy[3]-cy[2]
        
        let a: CGFloat
        let b: CGFloat
        let c: CGFloat
        let d: CGFloat
        let e: CGFloat
        let f: CGFloat
        let g: CGFloat
        let h: CGFloat
        
        if sX == 0 && sY == 0 {
            a = cx[1] - cx[0]
            b = cx[2] - cx[1]
            c = cx[0]
            d = cy[1] - cy[0]
            e = cy[2] - cy[1]
            f = cy[0]
            g = 0
            h = 0
        } else {
            g = (sX*dY2-dX2*sY)/(dX1*dY2-dX2*dY1)
            h = (dX1*sY-sX*dY1)/(dX1*dY2-dX2*dY1)
            a = cx[1] - cx[0] + g * cx[1]
            b = cx[3] - cx[0] + h * cx[3]
            c = cx[0]
            d = cy[1] - cy[0] + g * cy[1]
            e = cy[3] - cy[0] + h * cy[3]
            f = cy[0]

        }
        
        var verts: [[Vertex]] = []
        
        for x in 0...subdivisions {
            var col_verts: [Vertex] = []
            for y in 0...subdivisions {
                let u = CGFloat(x) / CGFloat(subdivisions)
                let v = CGFloat(y) / CGFloat(subdivisions)
                let pos: CGPoint
                if perspective {
                    pos = CGPoint(x: (a*u + b*v + c)/(g*u+h*v+1), y: (d*u + e*v + f)/(g*u+h*v+1))
                } else {
                    let bottom = add(scale(corners.bottomLeft, by: 1.0 - u), scale(corners.bottomRight, by: u))
                    let top = add(scale(corners.topLeft, by: 1.0 - u), scale(corners.topRight, by: u))
                    pos = add(scale(bottom, by: 1.0 - v), scale(top, by: v))
                }
                let vert = Vertex(x: LiveFloat(pos.x * 2 - 1), y: LiveFloat(pos.y * 2 - 1), s: LiveFloat(u), t: LiveFloat(1.0 - v))
                col_verts.append(vert)
            }
            verts.append(col_verts)
        }
        
        return verts
        
    }
    
    func mapVertices(_ vertices: [[Vertex]]) -> [Vertex] {
        var verticesMap: [Vertex] = []
        for x in 0..<subdivisions {
            for y in 0..<subdivisions {
                let vertexBottomLeft = vertices[x][y]
                let vertexTopLeft = vertices[x][y + 1]
                let vertexBottomRight = vertices[x + 1][y]
                let vertexTopRight = vertices[x + 1][y + 1]
                verticesMap.append(vertexTopLeft)
                verticesMap.append(vertexTopRight)
                verticesMap.append(vertexBottomLeft)
                verticesMap.append(vertexBottomRight)
                verticesMap.append(vertexBottomLeft)
                verticesMap.append(vertexTopRight)
            }
        }
        return verticesMap
    }
    
}

public extension NODEOut {
    
    func _cornerPin(topLeft: CGPoint = CGPoint(x: 0, y: 1),
                    topRight: CGPoint = CGPoint(x: 1, y: 1),
                    bottomLeft: CGPoint = CGPoint(x: 0, y: 0),
                    bottomRight: CGPoint = CGPoint(x: 1, y: 0)) -> CornerPinPIX {
        let cornerPixPix = CornerPinPIX()
        cornerPixPix.name = ":cornerPin:"
        cornerPixPix.input = self as? PIX & NODEOut
        cornerPixPix.corners = CornerPinPIX.Corners(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
        return cornerPixPix
    }
    
}
