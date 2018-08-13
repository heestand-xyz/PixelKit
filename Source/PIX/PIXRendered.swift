//
//  PIXRendered.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-12.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public extension PIX {
    
    public var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    
    public var renderedImage: UIImage? {
        guard let texture = renderedTexture else { return nil }
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else { return nil }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: HxPxE.main.colorBits.ci, colorSpace: HxPxE.main.colorSpace.cg) else { return nil }
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
        return uiImage
    }
    
    public var renderedRaw8: [UInt8]? {
        guard let texture = renderedTexture else { return nil }
        return HxPxE.main.raw8(texture: texture)
    }
    
    public var renderedRaw16: [Float]? {
        guard let texture = renderedTexture else { return nil }
        return HxPxE.main.raw16(texture: texture)
    }
    
    public var renderedRaw32: [float4]? {
        guard let texture = renderedTexture else { return nil }
        return HxPxE.main.raw32(texture: texture)
    }
    
    public var renderedRawNormalized: [CGFloat]? {
        guard let texture = renderedTexture else { return nil }
        return HxPxE.main.rawNormalized(texture: texture)
    }
    
    public struct Pixels {
        public let resolution: CGSize
        public let raw: [[PIX.Color]]
        public func pixel(uv: CGVector) -> PIX.Color {
            let xMax = resolution.width - 1
            let yMax = resolution.height - 1
            let x = max(0, min(Int(round(uv.dx * xMax + 0.5)), Int(xMax)))
            let y = max(0, min(Int(round(uv.dy * yMax + 0.5)), Int(yMax)))
            return pixel(pos: CGPoint(x: x, y: y))
        }
        public func pixel(pos: CGPoint) -> PIX.Color {
            let xMax = resolution.width - 1
            let yMax = resolution.height - 1
            let x = max(0, min(Int(round(pos.x)), Int(xMax)))
            let y = max(0, min(Int(round(pos.y)), Int(yMax)))
            return raw[y][x]
        }
    }

    public var renderedPixels: Pixels? {
        guard let resolution = resolution else { return nil }
        guard let rawPixels = renderedRawNormalized else { return nil }
        var pixels: [[PIX.Color]] = []
        let w = Int(resolution.width)
        let h = Int(resolution.height)
        for y in 0..<h {
            var pixelRow: [PIX.Color] = []
            for x in 0..<w {
                var pixel: [CGFloat] = []
                for i in 0..<4 {
                    let j = y * w * 4 + x * 4 + i
                    guard j < rawPixels.count else { return nil }
                    let chan = rawPixels[j]
                    pixel.append(chan)
                }
                let color = PIX.Color(pixel)
                pixelRow.append(color)
            }
            pixels.append(pixelRow)
        }
        return Pixels(resolution: resolution, raw: pixels)
    }
    
}
