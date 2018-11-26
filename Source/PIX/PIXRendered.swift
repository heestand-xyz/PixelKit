//
//  PIXRendered.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-12.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public extension PIX {
    
    public var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    
    #if os(iOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    public var renderedImage: _Image? {
        guard let texture = renderedTexture else { return nil }
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else { return nil }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: pixels.bits.ci, colorSpace: pixels.colorSpace.cg) else { return nil }
        #if os(iOS)
        return UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
        #elseif os(macOS)
        guard let size = resolution?.size else { return nil }
        return NSImage(cgImage: cgImage, size: size)
        #endif
    }
    
    public var renderedRaw8: [UInt8]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw8(texture: texture)
    }
    
    public var renderedRaw16: [Float]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw16(texture: texture)
    }
    
    public var renderedRaw32: [float4]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw32(texture: texture)
    }
    
    public var renderedRawNormalized: [CGFloat]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.rawNormalized(texture: texture)
    }
    
    public struct PixelPack {
        public let res: Res
        public let raw: [[Pixels.Pixel]]
        public func pixel(x: Int, y: Int) -> Pixels.Pixel {
            return raw[y][x]
        }
        public func pixel(uv: CGVector) -> Pixels.Pixel {
            let xMax = res.width - 1
            let yMax = res.height - 1
            let x = max(0, min(Int(round(uv.dx * xMax + 0.5)), Int(xMax)))
            let y = max(0, min(Int(round(uv.dy * yMax + 0.5)), Int(yMax)))
            return pixel(pos: CGPoint(x: x, y: y))
        }
        public func pixel(pos: CGPoint) -> Pixels.Pixel {
            let xMax = res.width - 1
            let yMax = res.height - 1
            let x = max(0, min(Int(round(pos.x)), Int(xMax)))
            let y = max(0, min(Int(round(pos.y)), Int(yMax)))
            return raw[y][x]
        }
        public var average: LiveColor {
            var color: LiveColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    color += px.color
                }
            }
            color /= CGFloat(res.count)
            return color
        }
        public var maximum: LiveColor {
            var color: LiveColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    if px.color > color {
                        color = px.color
                    }
                }
            }
            return color
        }
        public var minimum: LiveColor {
            var color: LiveColor!
            for row in raw {
                for px in row {
                    guard color != nil else {
                        color = px.color
                        continue
                    }
                    if px.color < color {
                        color = px.color
                    }
                }
            }
            return color
        }
    }
    
    public var renderedPixels: PixelPack? {
        guard let res = resolution else { return nil }
        guard let rawPixels = renderedRawNormalized else { return nil }
        var pixels: [[Pixels.Pixel]] = []
        let w = Int(res.width)
        let h = Int(res.height)
        for y in 0..<h {
            let v = (CGFloat(y) + 0.5) / CGFloat(h)
            var pixelRow: [Pixels.Pixel] = []
            for x in 0..<w {
                let u = (CGFloat(x) + 0.5) / CGFloat(w)
                var c: [CGFloat] = []
                for i in 0..<4 {
                    let j = y * w * 4 + x * 4 + i
                    guard j < rawPixels.count else { return nil }
                    let chan = rawPixels[j]
                    c.append(chan)
                }
                let color = Color(c)
                let uv = CGVector(dx: u, dy: v)
                let pixel = Pixels.Pixel(x: x, y: y, uv: uv, color: color)
                pixelRow.append(pixel)
            }
            pixels.append(pixelRow)
        }
        return PixelPack(res: res, raw: pixels)
    }
    
}
