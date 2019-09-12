//
//  CachePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-06-10.
//  Open Source - MIT License
//

#if os(iOS) && targetEnvironment(simulator)
import MetalPerformanceShadersProxy
#else
import Metal
#endif
import CoreGraphics

public class CachePIX: PIXSingleEffect, PixelCustomRenderDelegate {
    
    override open var shader: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    public struct CachedTexture {
        public let id: UUID
        public let date: Date
        public let texture: MTLTexture
    }
    
    public var cachedTextures: [CachedTexture] = []
    public var cacheActive: Bool = false { didSet { setNeedsRender() } }
    public var cacheId: UUID? = nil {
        didSet {
            guard cacheId != nil else { return }
            setNeedsRender()
        }
    }
    public var lastCacheId: UUID?
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        customRenderActive = true
        customRenderDelegate = self
        name = "cache"
    }
    
    // MARK: - Cache
    
    func cacheTexture() {
        guard let texture = texture else {
            pixelKit.log(.warning, nil, "Cache failed. No texture avalible.")
            return
        }
        cachedTextures.append(CachedTexture(id: UUID(), date: Date(), texture: texture))
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if cacheActive {
            let id = UUID()
            cachedTextures.append(CachedTexture(id: id, date: Date(), texture: texture))
            lastCacheId = id
        }
        guard let cacheId = cacheId else { return nil }
        for iCachedTexture in cachedTextures {
            if cacheId == iCachedTexture.id {
                return iCachedTexture.texture
            }
        }
        pixelKit.log(pix: self, .warning, nil, "Custom Render - Cache Id not found.")
        return nil
    }
    
    // MARK: - Seek
    
    public func seek(to index: Int) {
        guard !cachedTextures.isEmpty else {
            pixelKit.log(pix: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        guard index >= 0 && index < cachedTextures.count else {
            pixelKit.log(pix: self, .warning, nil, "Seek - Index out of bounds.")
            return
        }
        cacheId = cachedTextures[index].id
    }
    
    public func seek(to fraction: CGFloat) {
        guard !cachedTextures.isEmpty else {
            pixelKit.log(pix: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        guard fraction >= 0.0 && fraction <= 1.0 else {
            pixelKit.log(pix: self, .warning, nil, "Seek - Fraction out of bounds.")
            return
        }
        let index = Int(round(fraction * CGFloat(cachedTextures.count - 1)))
        cacheId = cachedTextures[index].id
    }
    
    public func seek(to date: Date) {
        guard !cachedTextures.isEmpty else {
            pixelKit.log(pix: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        var index: Int?
        for i in 0..<cachedTextures.count - 1 {
            let cachedTextureA = cachedTextures[i]
            let cachedTextureB = cachedTextures[i + 1]
            if -cachedTextureA.date.timeIntervalSinceNow <= -date.timeIntervalSinceNow && -cachedTextureB.date.timeIntervalSinceNow >= -date.timeIntervalSinceNow {
                index = i
                break
            }
        }
        if index == nil {
            if -date.timeIntervalSinceNow < -cachedTextures.first!.date.timeIntervalSinceNow {
                index = 0
            } else if -date.timeIntervalSinceNow > -cachedTextures.last!.date.timeIntervalSinceNow {
                index = cachedTextures.count - 1
            }
        }
        guard index != nil else { return }
        cacheId = cachedTextures[index!].id
    }
    
    public func seek(to id: UUID) {
        var exists = false
        for cachedTexture in cachedTextures {
            if cachedTexture.id == id {
                exists = true
                break
            }
        }
        guard exists else {
            pixelKit.log(pix: self, .warning, nil, "Seek - Id not found in cached textures.")
            return
        }
        cacheId = id
    }
    
    // MARK: - Clear
    
    public func clear() {
        cachedTextures = []
        cacheId = nil
    }
    
}
