//
//  Pixels.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public class Pixels {
    
    public static let main = Pixels()
    
    public weak var delegate: PixelsDelegate?
    
    // MARK: Signature
    
    let kBundleId = "se.hexagons.pixels"
    let kMetalLibName = "PixelsShaders"
    
    struct Signature: Encodable {
        let id: String
        let version: String
        let build: Int
        var formatted: String {
            return "\(id) - v\(version) - b\(build)"
        }
    }
    
    var signature: Signature {
        return Signature(id: kBundleId, version: Bundle(identifier: kBundleId)!.infoDictionary!["CFBundleShortVersionString"] as! String, build: Int(Bundle(identifier: kBundleId)!.infoDictionary!["CFBundleVersion"] as! String) ?? -1)
    }
    
    // MARK: Log
    
    public var logLevel: LogLevel = .debug
    public var logLoopLimitActive = true
    public var logLoopLimitFrameCount = 10
    var logLoopLimitIndicated = false
    
    // MARK: Color
    
    public var colorBits: PIX.Color.Bits = ._8
    public var colorSpace: PIX.Color.Space = .sRGB // .displayP3
    
    // MARK: Linked PIXs
    
    var linkedPixs: [PIX] = []
    
    // MARK: Frames
    
    var displayLink: CADisplayLink?
    var frameCallbacks: [(id: UUID, callback: () -> ())] = []
    
    public var frameIndex = 0
    var frameDate = Date()

    var _fps: Int = -1
    public var fps: Int { return min(_fps, fpsMax) }
    public var fpsMax: Int { if #available(iOS 10.3, *) { return UIScreen.main.maximumFramesPerSecond } else { return -1 } }
    
    // MARK: Metal
    
    var metalDevice: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var textureCache: CVMetalTextureCache!
    var metalLibrary: MTLLibrary!
    var quadVertexBuffer: MTLBuffer!
    var quadVertexShader: MTLFunction!
    
    // MARK: - Life Cycle
    
    init() {
        
        metalDevice = MTLCreateSystemDefaultDevice()
        guard metalDevice != nil else {
            log(.fatal, .pixels, "Metal Device not found.")
            return
        }
        
        commandQueue = metalDevice.makeCommandQueue()
        guard commandQueue != nil else {
            log(.fatal, .pixels, "Command Queue failed to make.")
            return
        }
        
        do {
            textureCache = try makeTextureCache()
            metalLibrary = try loadMetalShaderLibrary()
            quadVertexBuffer = try makeQuadVertexBuffer()
            quadVertexShader = try loadQuadVertexShader()
        } catch {
            log(.fatal, .pixels, "Initialization failed.", e: error)
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.frameLoop))
        displayLink!.add(to: RunLoop.main, forMode: .common)
        
        log(.none, .pixels, signature.version, clean: true)
        
    }
    
    // MARK: - Frame Loop
    
    @objc func frameLoop() {
        delegate?.pixelsFrameLoop()
        renderPIXs()
        for frameCallback in frameCallbacks {
            frameCallback.callback()
        }
        calcFPS()
        frameIndex += 1
    }
    
    func calcFPS() {
        let frameTime = -frameDate.timeIntervalSinceNow
        _fps = Int(round(1.0 / frameTime))
        frameDate = Date()
    }
    
    func listenToFrames(callback: @escaping () -> (Bool)) {
        let id = UUID()
        frameCallbacks.append((id: id, callback: {
            if callback() {
                self.unlistenToFrames(for: id)
            }
        }))
    }
    
    func unlistenToFrames(for id: UUID) {
        for (i, frameCallback) in self.frameCallbacks.enumerated() {
            if frameCallback.id == id {
                frameCallbacks.remove(at: i)
                break
            }
        }
    }
    
    func delay(frames: Int, done: @escaping () -> ()) {
        let startFrameIndex = frameIndex
        listenToFrames(callback: {
            if self.frameIndex >= startFrameIndex + frames {
                done()
                return true
            } else {
                return false
            }
        })
    }
    
    // MARK: - PIX Linking
    
    func add(pix: PIX) {
        linkedPixs.append(pix)
    }
    
    func remove(pix: PIX) {
        for (i, iPix) in linkedPixs.enumerated() {
            if iPix == pix {
                linkedPixs.remove(at: i)
                break
            }
        }
    }
    
    // MARK: - Setup
    
    // MARK: Shaders
    
    enum ShadersError: Error {
        case runtimeERROR(String)
    }
    
    func loadMetalShaderLibrary() throws -> MTLLibrary {
        guard let libraryFile = Bundle(identifier: kBundleId)!.path(forResource: kMetalLibName, ofType: "metallib") else {
            throw ShadersError.runtimeERROR("Pixels Shaders: Metal Library not found.")
        }
        do {
            return try metalDevice.makeLibrary(filepath: libraryFile)
        } catch { throw error }
    }
    
    // MARK: Quad
    
    enum QuadError: Error {
        case runtimeERROR(String)
    }
    
    struct Vertex {
        var x,y: Float
        var s,t: Float
        var buffer: [Float] {
            return [x,y,s,t]
        }
    }
    
    func makeQuadVertexBuffer() throws -> MTLBuffer {
        let a = Vertex(x: -1.0, y: -1.0, s: 0.0, t: 1.0)
        let b = Vertex(x: 1.0, y: -1.0, s: 1.0, t: 1.0)
        let c = Vertex(x: -1.0, y: 1.0, s: 0.0, t: 0.0)
        let d = Vertex(x: 1.0, y: 1.0, s: 1.0, t: 0.0)
        let verticesArray: Array<Vertex> = [a,b,c,b,c,d]
        var vertexData = Array<Float>()
        for vertex in verticesArray {
            vertexData += vertex.buffer
        }
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        guard let buffer = metalDevice.makeBuffer(bytes: vertexData, length: dataSize, options: []) else {
            throw QuadError.runtimeERROR("Quad Buffer failed to create.")
        }
        return buffer
    }
    
    func loadQuadVertexShader() throws -> MTLFunction {
        guard let vtxShader = metalLibrary.makeFunction(name: "quadVTX") else {
            throw QuadError.runtimeERROR("Quad Vertex Shader failed to make.")
        }
        return vtxShader
    }
    
    // MARK: Cache
    
    enum CacheError: Error {
        case runtimeERROR(String)
    }
    
    func makeTextureCache() throws -> CVMetalTextureCache {
        var textureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &textureCache) != kCVReturnSuccess {
            throw CacheError.runtimeERROR("Texture Cache failed to create.")
        } else {
            guard let tc = textureCache else {
                throw CacheError.runtimeERROR("Texture Cache is nil.")
            }
            return tc
        }
    }
    
    // MARK: - Shader
    
    // MARK: Pipeline
    
    enum ShaderPipelineError: Error {
        case runtimeERROR(String)
    }
    
    func makeShaderPipeline(_ fragFuncName: String) throws -> MTLRenderPipelineState {
        guard let fragmentShader = metalLibrary.makeFunction(name: fragFuncName) else {
            throw ShaderPipelineError.runtimeERROR("Frag Func Name not found: \"\(fragFuncName)\"")
        }
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = quadVertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = colorBits.mtl
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        do {
            return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch { throw error }
    }
    
    // MARK: Sampler
    
    enum ShaderSamplerError: Error {
        case runtimeERROR(String)
    }
    
    func makeSampler(interpolate: MTLSamplerMinMagFilter, extend: MTLSamplerAddressMode) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = interpolate
        samplerInfo.magFilter = interpolate
        samplerInfo.sAddressMode = extend
        samplerInfo.tAddressMode = extend
        guard let s = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw ShaderSamplerError.runtimeERROR("Shader Sampler failed to make.")
        }
        return s
    }
    
    // MARK: - Raw
    
    func raw8(texture: MTLTexture) -> [UInt8]? {
        guard colorBits == ._8 else { log(.error, .pixels, "Raw 8 - To access this data, change: \"pixels.colorBits = ._8\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<UInt8>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<UInt8>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    // CHECK needs testing
    func raw16(texture: MTLTexture) -> [Float]? {
        guard colorBits == ._16 else { log(.error, .pixels, "Raw 16 - To access this data, change: \"pixels.colorBits = ._16\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<Float>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<Float>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    // CHECK needs testing
    func raw32(texture: MTLTexture) -> [float4]? {
        guard colorBits != ._32 else { log(.error, .pixels, "Raw 32 - To access this data, change: \"pixels.colorBits = ._32\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<float4>(repeating: float4(0), count: texture.width * texture.height)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<float4>.size * texture.width
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    func rawNormalized(texture: MTLTexture) -> [CGFloat]? {
        let raw: [CGFloat]
        switch colorBits {
        case ._8:
            raw = raw8(texture: texture)!.map({ chan -> CGFloat in return CGFloat(chan) / (pow(2, 8) - 1) })
        case ._16:
            raw = raw16(texture: texture)!.map({ chan -> CGFloat in return CGFloat(chan) }) // CHECK normalize
        case ._32:
            let rawArr = raw32(texture: texture)!
            var rawFlatArr: [CGFloat] = []
            for pixel in rawArr {
                // CHECK normalize
                rawFlatArr.append(CGFloat(pixel.x))
                rawFlatArr.append(CGFloat(pixel.y))
                rawFlatArr.append(CGFloat(pixel.z))
                rawFlatArr.append(CGFloat(pixel.w))
            }
            raw = rawFlatArr
        }
        return raw
    }
    
}
