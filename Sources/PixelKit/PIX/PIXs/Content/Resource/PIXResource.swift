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
    
    public var resourceModel: PixelResourceModel {
        get { contentModel as! PixelResourceModel }
        set { contentModel = newValue }
    }
    
    var resourceResolution: Resolution? {
        if let texture: MTLTexture = resourceTexture {
            return texture.resolution
        } else if let pixelBuffer: CVPixelBuffer = resourcePixelBuffer {
            return .custom(w: CVPixelBufferGetWidth(pixelBuffer),
                           h: CVPixelBufferGetHeight(pixelBuffer))
        }
        return nil
    }
    @Published public var hasResourceTexture: Bool = false
    @Published public var hasResourcePixelBuffer: Bool = false
    public var hasResource: Bool { hasResourceTexture || hasResourcePixelBuffer }
    
    public var resourceTexture: MTLTexture? {
        didSet {
            hasResourceTexture = resourceTexture != nil
        }
    }
    public var resourcePixelBuffer: CVPixelBuffer? {
        didSet {
            hasResourcePixelBuffer = resourcePixelBuffer != nil
        }
    }
    var flop: Bool = false
    
    public override func clearRender() {
        resourceTexture = nil
        resourcePixelBuffer = nil
        super.clearRender()
    }
    
    // MARK: - Life Cycle -
    
    public init(model: PixelResourceModel) {
        super.init(model: model)
    }
    
    public required init() {
        fatalError("please use init(model:)")
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
