//
//  CachePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-06-10.
//  Open Source - MIT License
//


import Metal
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public class CachePIX: PIXSingleEffect, PixelCustomRenderDelegate {
    
    override open var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    public var cachedInfo: [(id: UUID, date: Date)] = []
    public var cachedTextures: [UUID: MTLTexture] = [:]
    public var cacheActive: Bool = false { didSet { setNeedsRender() } }
    public var cacheId: UUID? = nil {
        didSet {
            guard cacheId != nil else { return }
            setNeedsRender()
        }
    }
    public var lastCacheId: UUID?
    public var diskCache: Bool = false
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        customRenderActive = true
        customRenderDelegate = self
        name = "cache"
    }
    
    // MARK: - Cache
    
//    func cacheTexture() {
//        guard let texture = texture else {
//            pixelKit.log(.warning, nil, "Cache failed. No texture avalible.")
//            return
//        }
//        cachedTextures.append(CachedTexture(id: UUID(), date: Date(), texture: texture))
//    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        if cacheActive {
            if let textureCopy = try? pixelKit.copy(texture: texture) {
                let cacheId = UUID()
                if diskCache {
                    saveToDisk(texture: textureCopy, with: cacheId)
                } else {
                    cachedTextures[cacheId] = textureCopy
                }
                cachedInfo.append((id: cacheId, date: Date()))
                lastCacheId = cacheId
            }
        }
        guard let cacheId = self.cacheId else { return nil }
        guard let texture = getTexture(for: cacheId) else {
            pixelKit.logger.log(node: self, .warning, nil, "Custom Render - Texture not found.")
            return nil
        }
        return texture
    }
    
    func getTexture(for id: UUID) -> MTLTexture? {
        if diskCache {
            return loadFromDisk(id: id)
        }
        guard let texture = cachedTextures[id] else { return nil }
        return texture
    }
    
    func saveToDisk(texture: MTLTexture, with id: UUID) {
        let url = mtlTextureUrl(for: id)
        guard let image = pixelKit.image(from: texture) else {
            pixelKit.logger.log(node: self, .error, nil, "Save to Disk Failed - Texture to Image conversion failed.")
            return
        }
        #if os(iOS) || os(tvOS)
        guard let data = image.pngData() else {
            pixelKit.logger.log(node: self, .error, nil, "Save to Disk Failed - PNG Data not found.")
            return
        }
        #elseif os(macOS)
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let newRep = NSBitmapImageRep(cgImage: cgImage)
        newRep.size = image.size
        guard let data = newRep.representation(using: .png, properties: [:]) else { return }
        #endif
        do {
            try data.write(to: url)
        } catch {
            pixelKit.logger.log(node: self, .error, nil, "Save to Disk Failed - Data save failed.")
        }
    }
    
    func loadFromDisk(id: UUID) -> MTLTexture? {
        let url = mtlTextureUrl(for: id)
        do {
            let data = try Data(contentsOf: url)
            guard let image = _Image(data: data) else {
                pixelKit.logger.log(node: self, .error, nil, "Load from Disk Failed - Image not found.")
                return nil
            }
            guard let texture = pixelKit.texture(from: image) else {
                pixelKit.logger.log(node: self, .error, nil, "Load from Disk Failed - Texture conversion failed.")
                return nil
            }
            return texture
        } catch {
            pixelKit.logger.log(node: self, .error, nil, "Load from Disk Failed - Data not found.")
            return nil
        }
    }
    
    public func mtlTexturesURl() -> URL {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pixelKitUrl = documentUrl.appendingPathComponent("pixelkit")
        let texturesUrl = pixelKitUrl.appendingPathComponent("cachepix")
        return texturesUrl
    }
    
    func mtlTextureUrl(for id: UUID) -> URL {
        mtlTexturesURl().appendingPathComponent("\(id.uuidString).png")
    }
    
    // MARK: - Seek
    
    public func seek(to index: Int) {
        guard !cachedInfo.isEmpty else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        guard index >= 0 && index < cachedInfo.count else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - Index out of bounds.")
            return
        }
        cacheId = cachedInfo[index].id
    }
    
    public func seek(to fraction: CGFloat) {
        guard !cachedInfo.isEmpty else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        guard fraction >= 0.0 && fraction <= 1.0 else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - Fraction out of bounds.")
            return
        }
        let index = Int(round(fraction * CGFloat(cachedInfo.count - 1)))
        cacheId = cachedInfo[index].id
    }
    
    public func seek(to date: Date) {
        guard !cachedInfo.isEmpty else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - No textures cached.")
            return
        }
        var index: Int?
        for i in 0..<cachedInfo.count - 1 {
            let infoA = cachedInfo[i]
            let infoB = cachedInfo[i + 1]
            if -infoA.date.timeIntervalSinceNow <= -date.timeIntervalSinceNow &&
               -infoB.date.timeIntervalSinceNow >= -date.timeIntervalSinceNow {
                index = i
                break
            }
        }
        if index == nil {
            if -date.timeIntervalSinceNow < -cachedInfo.first!.date.timeIntervalSinceNow {
                index = 0
            } else if -date.timeIntervalSinceNow > -cachedInfo.last!.date.timeIntervalSinceNow {
                index = cachedInfo.count - 1
            }
        }
        guard index != nil else { return }
        cacheId = cachedInfo[index!].id
    }
    
    public func seek(to id: UUID) {
        var exists = false
        for info in cachedInfo {
            if info.id == id {
                exists = true
                break
            }
        }
        guard exists else {
            pixelKit.logger.log(node: self, .warning, nil, "Seek - Id not found in cached textures.")
            return
        }
        cacheId = id
    }
    
    // MARK: - Clear
    
    public func clear() {
        cachedInfo = []
        cacheId = nil
    }
    
}
