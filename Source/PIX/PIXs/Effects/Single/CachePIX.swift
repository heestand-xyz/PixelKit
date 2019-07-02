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

public class CachePIX: PIXSingleEffect, PixelCustomRenderDelegate {
    
    override open var shader: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    struct CachedTexture {
        let date: Date
        let texture: MTLTexture
    }
    
    var cachedTextures: [CachedTexture] = []
    
    // MARK: - Public Properties
    
    public var cache: Bool = false { didSet { setNeedsRender() } }
    public var index: Int? = nil {
        didSet {
            guard index != nil else { return }
            setNeedsRender()
        }
    }
    public var count: Int {
        return cachedTextures.count
    }
    
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
        cachedTextures.append(CachedTexture(date: Date(), texture: texture))
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if cache {
            cachedTextures.append(CachedTexture(date: Date(), texture: texture))
        }
        return index != nil && index! < cachedTextures.count ? cachedTextures[index!].texture : nil
    }
    
    // MARK: - Seek
    
    func seek(to i: Int) {
        index = nil
        guard !cachedTextures.isEmpty else { return }
        guard i < cachedTextures.count else { return }
        index = i
    }
    
    func seek(to fraction: CGFloat) {
        index = nil
        guard !cachedTextures.isEmpty else { return }
        index = Int(round(fraction * CGFloat(cachedTextures.count - 1)))
    }
    
    func seek(to date: Date) {
        index = nil
        guard !cachedTextures.isEmpty else { return }
        for i in 0..<cachedTextures.count - 1 {
            let cachedTextureA = cachedTextures[i]
            let cachedTextureB = cachedTextures[i + 1]
            if -cachedTextureA.date.timeIntervalSinceNow <= -date.timeIntervalSinceNow && -cachedTextureB.date.timeIntervalSinceNow >= -date.timeIntervalSinceNow {
                index = i
            }
        }
        if index == nil {
            if -date.timeIntervalSinceNow < -cachedTextures.first!.date.timeIntervalSinceNow {
                index = 0
            } else if -date.timeIntervalSinceNow > -cachedTextures.last!.date.timeIntervalSinceNow {
                index = cachedTextures.count - 1
            }
        }
    }
    
    // MARK: - Clear
    
    public func clear() {
        cachedTextures = []
        index = nil
    }
    
}
