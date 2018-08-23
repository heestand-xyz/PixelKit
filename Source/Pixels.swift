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
    
    let kName = "Pixels"
    let kBundleId = "se.hexagons.pixels"
    let kMetalLibName = "PixelsShaders"
    
    struct Signature: Encodable {
        let name: String
        let id: String
        let version: Float
        let build: Int
        var formatted: String {
            return "\(name) - \(id) - v\(version) - b\(build)"
        }
    }
    
    var signature: Signature {
        return Signature(name: kName, id: kBundleId, version: Float(Bundle(identifier: kBundleId)!.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-1")!, build: Int(Bundle(identifier: kBundleId)!.infoDictionary?["CFBundleVersion"] as? String ?? "-1")!)
    }
    
    var pixList: [PIX] = []
    
    var _fps: Int = -1
    public var fps: Int { return min(_fps, fpsMax) }
    public var fpsMax: Int { if #available(iOS 10.3, *) { return UIScreen.main.maximumFramesPerSecond } else { return -1 } }
    public var frameIndex = 0
    var frameDate = Date()
    
    public var logLevel: LogLevel = .debug
    let logLoopFrameCountLimit = 99
    var logLoopLimitIndicated = false
    
    public var colorBits: PIX.Color.Bits = ._8
    public var colorSpace: PIX.Color.Space = .sRGB // .displayP3
        
    struct Vertex {
        var x,y: Float
        var s,t: Float
        var buffer: [Float] {
            return [x,y,s,t]
        }
    }
    
    var metalDevice: MTLDevice?
    var commandQueue: MTLCommandQueue?
    var textureCache: CVMetalTextureCache?
    var metalLibrary: MTLLibrary?
    var quadVertexBuffer: MTLBuffer?
    var quadVertexShader: MTLFunction?
    var aLive: Bool {
        guard metalDevice != nil else { return false }
        guard commandQueue != nil else { return false }
        guard textureCache != nil else { return false }
        guard metalLibrary != nil else { return false }
        guard quadVertexBuffer != nil else { return false }
        guard quadVertexShader != nil else { return false }
        return true
    }
    
    var displayLink: CADisplayLink?
    var frameCallbacks: [(id: UUID, callback: () -> ())] = []
    
    // MARK: - Life Cycle
    
    public init() {
        log(.none, .engine, signature.formatted, clean: true)
        
        metalDevice = MTLCreateSystemDefaultDevice()
        if metalDevice == nil {
            log(.error, .engine, "Metal Device not found.")
        } else {
            commandQueue = metalDevice!.makeCommandQueue()
            textureCache = makeTextureCache()
            metalLibrary = loadMetalShaderLibrary()
            if metalLibrary != nil {
                quadVertexBuffer = makeQuadVertexBuffer()
                quadVertexShader = loadQuadVertexShader()
            }
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.frameLoop))
        displayLink!.add(to: RunLoop.main, forMode: .commonModes)
        
        if aLive {
            log(.none, .engine, "Pixels is aLive! ⬢", clean: true)
        } else {
            log(.fatal, .engine, "Pixels is not aLive...", clean: true)
        }
        
    }
    
    // MARK: - Frame Loop
    
    @objc func frameLoop() {
        let frameTime = -frameDate.timeIntervalSinceNow
        _fps = Int(round(1 / frameTime))
        frameDate = Date()
        for frameCallback in frameCallbacks { frameCallback.callback() }
        delegate?.pixelsFrameLoop()
        renderPIXs()
        frameIndex += 1
    }
    
    internal func listenToFrames(callback: @escaping () -> (Bool)) {
        let id = UUID()
        frameCallbacks.append((id: id, callback: {
            if callback() {
                for (i, frameCallback) in self.frameCallbacks.enumerated() {
                    if frameCallback.id == id {
                        self.frameCallbacks.remove(at: i)
                        break
                    }
                }
            }
        }))
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
    
    // MARK: - Add / Remove
    
    func add(pix: PIX) {
        pixList.append(pix)
    }
    
    func remove(pix: PIX) {
        for (i, iPix) in pixList.enumerated() {
            if iPix == pix {
                pixList.remove(at: i)
                break
            }
        }
    }
    
    // MARK: - Setup
    
    // MARK: Quad
    
    func makeQuadVertexBuffer() -> MTLBuffer {
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
        return metalDevice!.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
    }
    
    func loadQuadVertexShader() -> MTLFunction? {
        guard let vtxShader = metalLibrary!.makeFunction(name: "quadVTX") else {
            log(.error, .engine, "Quad:", "Function not made.")
            return nil
        }
        return vtxShader
    }
    
    // MARK: Cache
    
    func makeTextureCache() -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice!, nil, &textureCache) != kCVReturnSuccess {
            log(.error, .engine, "Cache: Creation failed.")
//            fatalError("Unable to allocate texture cache.") // CHECK
            return nil
        } else {
            return textureCache
        }
    }
    
    // MARK: Load Shaders
    
    func loadMetalShaderLibrary() -> MTLLibrary? {
        guard let libraryFile = Bundle(identifier: kBundleId)!.path(forResource: kMetalLibName, ofType: "metallib") else {
            log(.error, .engine, "Loading Metal Shaders Library: Not found.")
            return nil
        }
        do {
            return try metalDevice!.makeLibrary(filepath: libraryFile)
        } catch let error {
            log(.error, .engine, "Loading Metal Shaders Library: Make failed:", e: error)
            return nil
        }
    }
    
    // MARK: Shader Pipeline
    
    func makeShaderPipeline(_ fragFuncName: String/*, from source: String*/) -> MTLRenderPipelineState? {
//        var pixMetalLibrary: MTLLibrary? = nil
//        do {
//            pixMetalLibrary = try metalDevice!.makeLibrary(source: source, options: nil)
//        } catch {
//            log(.error, .engine, "Pipeline:", "PIX Metal Library corrupt:", error.localizedDescription)
//            return nil
//        }
        guard let fragmentShader = metalLibrary!.makeFunction(name: fragFuncName) else {
            log(.fatal, .engine, "Make Shader Pipeline: PIX Metal Func: Not found: \"\(fragFuncName)\"")
            return nil
        }
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = quadVertexShader!
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = colorBits.mtl
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        do {
            return try metalDevice!.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            log(.error, .engine, "Make Shader Pipeline: Failed:", e: error)
            return nil
        }
    }
    
    // MARK: Texture
    
    func makeTexture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache!, pixelBuffer, nil, PIX.Color.Bits._8.mtl, width, height, 0, &cvTextureOut) // CHECK add high bit support
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            log(.error, .engine, "Textrue: Creation failed.")
            return nil
        }
        return inputTexture
    }
    
    func copyTexture(from pix: PIX) -> MTLTexture? {
        guard pix.texture != nil else { return nil }
        guard let textureCopy = emptyTexture(size: CGSize(width: pix.texture!.width, height: pix.texture!.height)) else { return nil }
        let commandBuffer = commandQueue!.makeCommandBuffer()!
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else { return nil }
        blitEncoder.copy(from: pix.texture!, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: pix.texture!.width, height: pix.texture!.height, depth: 1), to: textureCopy, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        blitEncoder.endEncoding()
        commandBuffer.commit()
        return textureCopy
    }
    
    func emptyTexture(size: CGSize) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: colorBits.mtl, width: Int(size.width), height: Int(size.height), mipmapped: true)
        return metalDevice!.makeTexture(descriptor: descriptor)
    }
    
    // MARK: Raw
    
    func raw8(texture: MTLTexture) -> [UInt8]? {
        guard colorBits == ._8 else { log(.error, .engine, "Raw 8 - To access this data, change: \"pixels.colorBits = ._8\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<UInt8>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<UInt8>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    func raw16(texture: MTLTexture) -> [Float]? {
        guard colorBits == ._16 else { log(.error, .engine, "Raw 16 - To access this data, change: \"pixels.colorBits = ._16\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<Float>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<Float>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    func raw32(texture: MTLTexture) -> [float4]? {
        guard colorBits != ._32 else { log(.error, .engine, "Raw 32 - To access this data, change: \"pixels.colorBits = ._32\"."); return nil }
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
    
    // MARK: Sampler
    
    func makeSampler(interpolate: MTLSamplerMinMagFilter, extend: MTLSamplerAddressMode) -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = interpolate
        samplerInfo.magFilter = interpolate
        samplerInfo.sAddressMode = extend
        samplerInfo.tAddressMode = extend
        return metalDevice!.makeSamplerState(descriptor: samplerInfo)!
    }
    
}
