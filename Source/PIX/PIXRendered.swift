//
//  PIXRendered.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-12.
//  Open Source - MIT License
//

import MetalKit

public extension PIX {
    
    var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    
    
    var renderedCIImage: CIImage? {
        guard let texture = renderedTexture else { return nil }
        return CIImage(mtlTexture: texture, options: nil)
    }
    
    
    var renderedCGImage: CGImage? {
        guard let ciImage = renderedCIImage else { return nil }
        return CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: pixels.bits.ci, colorSpace: pixels.colorSpace.cg)
    }
    
    #if os(iOS)
    typealias _Image = UIImage
    #elseif os(macOS)
    typealias _Image = NSImage
    #endif
    var renderedImage: _Image? {
        guard let cgImage = renderedCGImage else { return nil }
        #if os(iOS)
        return UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
        #elseif os(macOS)
        guard let size = resolution?.size else { return nil }
        return NSImage(cgImage: cgImage, size: size)
        #endif
    }
    func nextRenderedImage(callback: @escaping (_Image) -> ()) {
        if let image = renderedImage {
            callback(image)
        }
        Pixels.main.delay(frames: 1, done: {
            self.nextRenderedImage(callback: callback)
        })
    }
    
    public var renderedPixelBuffer: CVPixelBuffer? {
        guard let res = resolution else { pixels.log(.error, nil, "renderedPixelBuffer: no res."); return nil }
        guard let cgImage = renderedCGImage else { pixels.log(.error, nil, "renderedPixelBuffer: no cgImage."); return nil }
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, res.w, res.h, Pixels.main.bits.os, attrs as CFDictionary, &maybePixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else { pixels.log(.error, nil, "renderedPixelBuffer: CVPixelBufferCreate failed with status \(status)"); return nil }
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else { pixels.log(.error, nil, "renderedPixelBuffer: CVPixelBufferLockBaseAddress failed."); return nil }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer), width: res.w, height: res.h, bitsPerComponent: Pixels.main.bits.rawValue, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: Pixels.main.colorSpace.cg, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { pixels.log(.error, nil, "renderedPixelBuffer: context failed to be created."); return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: res.width, height: res.height))
        return pixelBuffer
    }
    
    var renderedRaw8: [UInt8]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw8(texture: texture)
    }
    
    var renderedRaw16: [Float]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw16(texture: texture)
    }
    
    var renderedRaw32: [float4]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.raw32(texture: texture)
    }
    
    var renderedRawNormalized: [CGFloat]? {
        guard let texture = renderedTexture else { return nil }
        return pixels.rawNormalized(texture: texture)
    }
    
    struct PixelPack {
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
            color /= LiveFloat(CGFloat(res.count))
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
                    if Bool(px.color > color!) {
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
                    if Bool(px.color < color!) {
                        color = px.color
                    }
                }
            }
            return color
        }
    }
    
    var renderedPixels: PixelPack? {
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
                let color = LiveColor(c)
                let uv = CGVector(dx: u, dy: v)
                let pixel = Pixels.Pixel(x: x, y: y, uv: uv, color: color)
                pixelRow.append(pixel)
            }
            pixels.append(pixelRow)
        }
        return PixelPack(res: res, raw: pixels)
    }
    
}
