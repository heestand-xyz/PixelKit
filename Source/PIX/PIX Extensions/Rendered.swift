//
//  PIXRendered.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-12.
//  Open Source - MIT License
//

import MetalKit

public extension PIX {
    
    var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    
    var renderedCIImage: CIImage? {
        guard let texture = renderedTexture else { return nil }
        return CIImage(mtlTexture: texture, options: [.colorSpace: PixelKit.main.colorSpace.cg])
    }
    
    var renderedCGImage: CGImage? {
        guard let ciImage = renderedCIImage else { return nil }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: pixelKit.bits.ci, colorSpace: pixelKit.colorSpace.cg) else { return nil }
        #if os(iOS)
        return cgImage
        #elseif os(macOS)
        guard let size = resolution?.size else { return nil }
        guard let context = CGContext(data: nil, width: Int(size.width.cg), height: Int(size.height.cg), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width.cg), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -size.height.cg)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width.cg, height: size.height.cg))
        guard let image = context.makeImage() else { return nil }
        return image
        #endif
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
        return NSImage(cgImage: cgImage, size: size.cg)
        #endif
    }
    func nextRenderedImage(callback: @escaping (_Image) -> ()) {
        if let image = renderedImage {
            callback(image)
            return
        }
        PixelKit.main.delay(frames: 1, done: {
            self.nextRenderedImage(callback: callback)
        })
    }
    
    var renderedPixelBuffer: CVPixelBuffer? {
        guard let res = resolution else { pixelKit.log(.error, nil, "renderedPixelBuffer: no res."); return nil }
        guard let cgImage = renderedCGImage else { pixelKit.log(.error, nil, "renderedPixelBuffer: no cgImage."); return nil }
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault, res.w, res.h, PixelKit.main.bits.os, attrs as CFDictionary, &maybePixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else { pixelKit.log(.error, nil, "renderedPixelBuffer: CVPixelBufferCreate failed with status \(status)"); return nil }
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else { pixelKit.log(.error, nil, "renderedPixelBuffer: CVPixelBufferLockBaseAddress failed."); return nil }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer), width: res.w, height: res.h, bitsPerComponent: PixelKit.main.bits.rawValue, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: PixelKit.main.colorSpace.cg, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { pixelKit.log(.error, nil, "renderedPixelBuffer: context failed to be created."); return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: res.width.cg, height: res.height.cg))
        return pixelBuffer
    }
    
    var renderedRaw8: [UInt8]? {
        guard let texture = renderedTexture else { return nil }
        return pixelKit.raw8(texture: texture)
    }
    
    var renderedRaw16: [Float]? {
        guard let texture = renderedTexture else { return nil }
        return pixelKit.raw16(texture: texture)
    }
    
    var renderedRaw32: [float4]? {
        guard let texture = renderedTexture else { return nil }
        return pixelKit.raw32(texture: texture)
    }
    
    var renderedRawNormalized: [CGFloat]? {
        guard let texture = renderedTexture else { return nil }
        return pixelKit.rawNormalized(texture: texture)
    }
    
    struct PixelPack {
        public let res: Res
        public let raw: [[PixelKit.Pixel]]
        public func pixel(x: Int, y: Int) -> PixelKit.Pixel {
            return raw[y][x]
        }
        public func pixel(uv: CGVector) -> PixelKit.Pixel {
            let xMax = res.width.cg - 1
            let yMax = res.height.cg - 1
            let x = max(0, min(Int(round(uv.dx * xMax + 0.5)), Int(xMax)))
            let y = max(0, min(Int(round(uv.dy * yMax + 0.5)), Int(yMax)))
            return pixel(pos: CGPoint(x: x, y: y))
        }
        public func pixel(pos: CGPoint) -> PixelKit.Pixel {
            let xMax = res.width.cg - 1
            let yMax = res.height.cg - 1
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
    
    var renderedPixelKit: PixelPack? {
        guard let res = resolution else { return nil }
        guard let rawPixelKit = renderedRawNormalized else { return nil }
        var pixelKit: [[PixelKit.Pixel]] = []
        let w = Int(res.width.cg)
        let h = Int(res.height.cg)
        for y in 0..<h {
            let v = (CGFloat(y) + 0.5) / CGFloat(h)
            var pixelRow: [PixelKit.Pixel] = []
            for x in 0..<w {
                let u = (CGFloat(x) + 0.5) / CGFloat(w)
                var c: [CGFloat] = []
                for i in 0..<4 {
                    let j = y * w * 4 + x * 4 + i
                    guard j < rawPixelKit.count else { return nil }
                    let chan = rawPixelKit[j]
                    c.append(chan)
                }
                let color = LiveColor(c)
                let uv = CGVector(dx: u, dy: v)
                let pixel = PixelKit.Pixel(x: x, y: y, uv: uv, color: color)
                pixelRow.append(pixel)
            }
            pixelKit.append(pixelRow)
        }
        return PixelPack(res: res, raw: pixelKit)
    }
    
}
