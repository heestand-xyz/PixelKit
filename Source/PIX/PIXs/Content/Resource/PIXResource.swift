//
//  PIXResource.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-16.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import CoreVideo

open class PIXResource: PIXContent, NODEResource {
    
    var resourceResolution: Resolution? {
        if let texture: MTLTexture = resourceTexture {
            return .custom(w: texture.width,
                           h: texture.height)
        } else if let pixelBuffer: CVPixelBuffer = resourcePixelBuffer {
            return .custom(w: CVPixelBufferGetWidth(pixelBuffer),
                           h: CVPixelBufferGetHeight(pixelBuffer))
        }
        return nil
    }
    
    public var resourceTexture: MTLTexture?
    public var resourcePixelBuffer: CVPixelBuffer?
    var flop: Bool = false
    
    public override func clearRender() {
        resourceTexture = nil
        resourcePixelBuffer = nil
        super.clearRender()
    }
    
    public required init() {
        fatalError("please use init(name:typeName:)")
    }
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
    }
    
    // MARK: Codable
    
    enum CodingKeys: CodingKey {
        case flop
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flop = try container.decode(Bool.self, forKey: .flop)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(flop, forKey: .flop)
        try super.encode(to: encoder)
    }
    
    // MARK: Texture
    
    public func getResourceTexture(commandBuffer: MTLCommandBuffer) throws -> MTLTexture {
        if let texture: MTLTexture = resourceTexture {
            return texture
        }
        guard let pixelBuffer = resourcePixelBuffer else {
            throw Engine.RenderError.texture("Pixel Buffer is nil.")
        }
        let force8bit: Bool
        #if os(tvOS)
        force8bit = false
        #else
        force8bit = self is CameraPIX
        #endif
        do {
            return try Texture.makeTextureFromCache(from: pixelBuffer, bits: force8bit ? ._8 : PixelKit.main.render.bits, in: PixelKit.main.render.textureCache)
        } catch {
            PixelKit.main.logger.log(node: self, .detail, .resource, "Texture genration failed, using backup method.", e: error)
            return try Texture.makeTexture(from: pixelBuffer, with: commandBuffer, force8bit: force8bit, on: PixelKit.main.render.metalDevice)
        }
    }
    
}
