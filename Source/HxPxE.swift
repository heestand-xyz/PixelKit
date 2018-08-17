//
//  HxPxE.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public class HxPxE {
    
    public static let main = HxPxE()
    
    public var delegate: HxPxEDelegate?
    
    let kSlug = "HxPxE"
    let kName = "Hexagon Pixel Engine"
    let kBundleId = "house.hexagon.hxpxe"
    
    struct HxHSignature: Encodable {
        let slug: String
        let name: String
        let id: String
        let version: Float
        let build: Int
        var formatted: String {
            return "\(slug) - \(name) - \(id) - v\(version) - b\(build)"
        }
    }
    
    var hxhSignature: HxHSignature {
        return HxHSignature(slug: kSlug, name: kName, id: kBundleId, version: Float(Bundle(identifier: kBundleId)!.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-1")!, build: Int(Bundle(identifier: kBundleId)!.infoDictionary?["CFBundleVersion"] as? String ?? "-1")!)
    }
    
    var pixList: [PIX] = []
    
    var _fps: Int = -1
    public var fps: Int { return min(_fps, fpsMax) }
    public var fpsMax: Int { if #available(iOS 10.3, *) { return UIScreen.main.maximumFramesPerSecond } else { return -1 } }
    public var frameIndex = 0
    var frameDate = Date()
    
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
        print(hxhSignature.formatted)
        
        metalDevice = MTLCreateSystemDefaultDevice()
        if metalDevice == nil {
            Logger.main.log(.error, .engine, "Metal Device not found.")
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
            print("HxPxE is aLive! ⬢")
        } else {
            print("HxPxE is not aLive...")
        }
        
    }
    
    // MARK: - Frame Loop
    
    @objc func frameLoop() {
        let frameTime = -frameDate.timeIntervalSinceNow
        _fps = Int(round(1 / frameTime))
        frameDate = Date()
        for frameCallback in frameCallbacks { frameCallback.callback() }
        delegate?.hxpxeFrameLoop()
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
            Logger.main.log(.error, .engine, "Quad:", "Function not made.")
            return nil
        }
        return vtxShader
    }
    
    // MARK: Cache
    
    func makeTextureCache() -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice!, nil, &textureCache) != kCVReturnSuccess {
            Logger.main.log(.error, .engine, "Cache: Creation failed.")
//            fatalError("Unable to allocate texture cache.") // CHECK
            return nil
        } else {
            return textureCache
        }
    }
    
    // MARK: Load Shaders
    
    func loadMetalShaderLibrary() -> MTLLibrary? {
        guard let libraryFile = Bundle(identifier: kBundleId)!.path(forResource: "HxPxE_Shaders", ofType: "metallib") else {
            Logger.main.log(.error, .engine, "Loading Metal Shaders Library: Not found.")
            return nil
        }
        do {
            return try metalDevice!.makeLibrary(filepath: libraryFile)
        } catch let error {
            Logger.main.log(.error, .engine, "Loading Metal Shaders Library: Make failed:", e: error)
            return nil
        }
    }
    
    // MARK: Shader Pipeline
    
    func makeShaderPipeline(_ fragFuncName: String/*, from source: String*/) -> MTLRenderPipelineState? {
//        var pixMetalLibrary: MTLLibrary? = nil
//        do {
//            pixMetalLibrary = try metalDevice!.makeLibrary(source: source, options: nil)
//        } catch {
//            Logger.main.log(.error, .engine, "Pipeline:", "PIX Metal Library corrupt:", error.localizedDescription)
//            return nil
//        }
        guard let fragmentShader = metalLibrary!.makeFunction(name: fragFuncName) else {
            Logger.main.log(.error, .engine, "Make Shader Pipeline: PIX Metal Func: Not found: \(fragFuncName)")
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
            Logger.main.log(.error, .engine, "Make Shader Pipeline: Failed:", e: error)
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
            Logger.main.log(.error, .engine, "Textrue: Creation failed.")
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
        guard colorBits == ._8 else { Logger.main.log(.error, .engine, "Raw 8 - To access this data, change: \"HxPxE.main.colorBits = ._8\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<UInt8>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<UInt8>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    func raw16(texture: MTLTexture) -> [Float]? {
        guard colorBits == ._16 else { Logger.main.log(.error, .engine, "Raw 16 - To access this data, change: \"HxPxE.main.colorBits = ._16\"."); return nil }
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var raw = Array<Float>(repeating: 0, count: texture.width * texture.height * 4)
        raw.withUnsafeMutableBytes {
            let bytesPerRow = MemoryLayout<Float>.size * texture.width * 4
            texture.getBytes($0.baseAddress!, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
        }
        return raw
    }
    
    func raw32(texture: MTLTexture) -> [float4]? {
        guard colorBits != ._32 else { Logger.main.log(.error, .engine, "Raw 32 - To access this data, change: \"HxPxE.main.colorBits = ._32\"."); return nil }
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
    
    // MARK: - Render
    
    func renderPIXs() {
        for pix in pixList {
            if pix.needsRender {
                if let pixIn = pix as? PIX & PIXInIO {
                    guard let pixOut = pixIn.pixInList.first else {
                        Logger.main.log(pix: pixIn, .warning, .render, "Can't Render: PIX In's inPix is nil.")
                        continue
                    }
                    if pixOut.texture == nil {
                        // CHECK upstream, if connected & rendered
                        renderPIX(pixOut, force: true)
                        continue
                    }
                }
                if pix.view.superview != nil {
                    pix.view.metalView.setNeedsDisplay()
                    pix.view.metalView.readyToRender = {
                        pix.view.metalView.readyToRender = nil
                        self.renderPIX(pix)
                    }
                } else {
                    renderPIX(pix)
                }
            }
        }
    }
    
    func renderPIX(_ pix: PIX, force: Bool = false) {
        guard !pix.rendering else {
            Logger.main.log(pix: pix, .warning, .render, "Render in progress...")
            return
        }
        pix.rendering = true
        pix.needsRender = false
        Logger.main.log(pix: pix, .info, .render, "Starting render.")
        self.render(pix, force: force, completed: { texture in
            Logger.main.log(pix: pix, .info, .render, "Render successful!")
            pix.rendering = false
            pix.didRender(texture: texture, force: force)
        }, failed: {
            Logger.main.log(pix: pix, .error, .render, "Render failed...")
            pix.rendering = false
        })
    }
    
    func render(_ pix: PIX, force: Bool, completed: @escaping (MTLTexture) -> (), failed: @escaping () -> ()) {
        
//        if #available(iOS 11.0, *) {
//            let sharedCaptureManager = MTLCaptureManager.shared()
//            let myCaptureScope = sharedCaptureManager.makeCaptureScope(device: metalDevice!)
//            myCaptureScope.label = "HxPxE GPU Capture Scope"
//            sharedCaptureManager.defaultCaptureScope = myCaptureScope
//            myCaptureScope.begin()
//        }
        
        guard aLive else {
            Logger.main.log(pix: pix, .error, .metalRender, "Not aLive...")
            return
        }
        
//        if self.pixelBuffer == nil && self.uses_source_texture {
//            AnalyticsAssistant.shared.logERROR("Render canceled: Source Texture is specified & Pixel Buffer is nil.")
//            return
//        }
        
        // MARK: Command Buffer
        
        guard let commandBuffer = commandQueue!.makeCommandBuffer() else {
            Logger.main.log(pix: pix, .error, .metalRender, "Command Buffer: Make faild.")
            return
        }
        
        // MARK: Input Texture
        
        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else {
                    Logger.main.log(pix: pix, .error, .metalRender, "Texture Creation: Pixel Buffer is empty.")
                    return
                }
                guard let sourceTexture = makeTexture(from: pixelBuffer) else {
                    Logger.main.log(pix: pix, .error, .metalRender, "Texture Creation: Make faild.")
                    return
                }
                inputTexture = sourceTexture
            } else if pixContent is PIXGenerator {
                generator = true
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            guard let pixOut = pixIn.pixInList.first else {
                Logger.main.log(pix: pix, .error, .metalRender, "inPix not connected.")
                return
            }
            guard let pixOutTexture = pixOut.texture else {
                Logger.main.log(pix: pix, .error, .metalRender, "IO Texture not found for: \(pixOut)")
                return
            }
            inputTexture = pixOutTexture // CHECK copy?
            if pix is PIXInMerger {
                let pixOutB = pixIn.pixInList[1]
                guard let pixOutTextureB = pixOutB.texture else {
                    Logger.main.log(pix: pix, .error, .metalRender, "IO Texture B not found for: \(pixOutB)")
                    return
                }
                secondInputTexture = pixOutTextureB // CHECK copy?
            }
        }
        
        // MARK: Custom Render
        
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                Logger.main.log(pix: pix, .error, .metalRender, "CustomRenderDelegate not implemented.")
                return
            }
            guard let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) else {
                Logger.main.log(pix: pix, .error, .metalRender, "Custom Render faild.")
                return
            }
            inputTexture = customRenderedTexture
        }
        
        // MARK: Drawable Texture
        
        var viewDrawable: CAMetalDrawable? = nil
        let drawableTexture: MTLTexture
        if pix.view.superview != nil {
            guard let currentDrawable: CAMetalDrawable = pix.view.metalView.currentDrawable else {
                Logger.main.log(pix: pix, .error, .metalRender, "Current Drawable: Not found.")
                return
            }
            viewDrawable = currentDrawable
            drawableTexture = currentDrawable.texture
        } else {
            guard let res = pix.resolution else {
                Logger.main.log(pix: pix, .error, .metalRender, "Drawable Textue: Resolution not set.")
                return
            }
            guard let emptyTexture = emptyTexture(size: res.size) else {
                Logger.main.log(pix: pix, .error, .metalRender, "Drawable Textue: Empty Texture Creation Failed.")
                return
            }
            drawableTexture = emptyTexture
        }
        
//        let drawableRes = PIX.Res(texture: drawableTexture)
//        if (drawableRes > PIX.Res.customRes(w: 16384, h: 16384)) != false {
//            Logger.main.log(pix: pix, .warning, .metalRender, "Epic res: \(drawableRes)")
//        } else if (drawableRes > PIX.Res.customRes(w: 8192, h: 8192)) != false {
//            Logger.main.log(pix: pix, .warning, .metalRender, "Extreme res: \(drawableRes)")
//        } else if (drawableRes > PIX.Res._4096) != false {
//            Logger.main.log(pix: pix, .warning, .metalRender, "High res: \(drawableRes)")
//        }
        
        // MARK: Command Encoder
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawableTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            Logger.main.log(pix: pix, .error, .metalRender, "Command Encoder: Make faild.")
            return
        }
        commandEncoder.setRenderPipelineState(pix.pipeline!)
        
        // Wireframe Mode
//        commandEncoder.setTriangleFillMode(.lines)
        
        // MARK: Uniforms
        
        var unifroms: [Float] = pix.shaderUniforms.map { uniform -> Float in return Float(uniform) }
        if pix.shaderNeedsAspect {
            unifroms.append(Float(drawableTexture.width) / Float(drawableTexture.height))
        }
        if !unifroms.isEmpty {
            let uniformBuffer = metalDevice!.makeBuffer(length: MemoryLayout<Float>.size * unifroms.count, options: [])
            let bufferPointer = uniformBuffer?.contents()
            memcpy(bufferPointer, &unifroms, MemoryLayout<Float>.size * unifroms.count)
            commandEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        }
        
        // MARK: Texture
        
        if !generator {
            commandEncoder.setFragmentTexture(inputTexture!, index: 0)
        }
        
        if secondInputTexture != nil {
            commandEncoder.setFragmentTexture(secondInputTexture!, index: 1)
        }
        
//        if let texture = sourceTexture ?? blur_texture ?? self.inputTexture {
//
//            if timeMachineTexture3d != nil {
//                commandEncoder!.setFragmentTexture(timeMachineTexture3d!, index: 0)
//            } else {
//                commandEncoder!.setFragmentTexture(texture , index: 0)
//            }
//            if self.secondInputTexture != nil {
//                commandEncoder!.setFragmentTexture(self.secondInputTexture!, index: 1)
//            }
//
//        } else if inputsTexture != nil {
//            commandEncoder!.setFragmentTexture(inputsTexture!, index: 0)
//        }
        
        // MARK: Encode
        
        commandEncoder.setFragmentSamplerState(pix.sampler!, index: 0)
        
        commandEncoder.setVertexBuffer(quadVertexBuffer!, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
        
        commandEncoder.endEncoding()
        
        // MARK: Render
        
        if viewDrawable != nil {
            commandBuffer.present(viewDrawable!)
        }
        
        commandBuffer.addCompletedHandler({ _ in
            if let error = commandBuffer.error {
                Logger.main.log(pix: pix, .error, .metalRender, "Failed.", e: error)
                failed()
                return
            }
            DispatchQueue.main.async {   
                completed(drawableTexture)
            }
        })
        
        commandBuffer.commit()
        
//        if #available(iOS 11.0, *) {
//            let sharedCaptureManager = MTLCaptureManager.shared()
//            sharedCaptureManager.defaultCaptureScope?.end()
//        }
        
    }
    
    // MARK: - File IO
    
    struct HxPxSignature: Encodable {
        let name: String
        let id: UUID
    }
    
    enum HxPxEIOError: Error {
        case runtimeERROR(String)
    }
    
    struct PIXPack: Encodable {
        let id: UUID
        let type: PIX.Kind
        let pix: PIX
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
    }
    
    struct HxPxPack: Encodable {
        let hxh: HxHSignature
        let hxpx: HxPxSignature
        let pixs: [PIXPack]
    }
    
    public func export(as name: String, id: UUID = UUID(), share: Bool = false) throws -> String {
        let hxpxSignature = HxPxSignature(name: name, id: id)
        let pixPacks = try pixList.map { pix -> PIXPack in
            var inPixId: UUID? = nil
            var inPixAId: UUID? = nil
            var inPixBId: UUID? = nil
            var inPixsIds: [UUID]? = nil
            if let pixIn = pix as? PIX & PIXIn {
                if let pixInSingle = pixIn as? PIX & PIXInSingle {
                    inPixId = pixInSingle.inPix?.id
                } else if let pixInMerger = pixIn as? PIX & PIXInMerger {
                    inPixAId = pixInMerger.inPixA?.id
                    inPixBId = pixInMerger.inPixB?.id
                } else if let pixInMulti = pixIn as? PIX & PIXInMulti {
                    inPixsIds = pixInMulti.inPixs.map({ outPix -> UUID in return outPix.id })
                }
            }
            guard let pixKind = (pix as? PIXofaKind)?.kind else {
                throw HxPxEIOError.runtimeERROR("HxPx: PIX is not able.")
            }
            return PIXPack(id: pix.id, type: pixKind, pix: pix, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds)
        }
        let hxpxPack = HxPxPack(hxh: hxhSignature, hxpx: hxpxSignature, pixs: pixPacks)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let hxpxPackJsonData = try encoder.encode(hxpxPack)
        guard let hxpxPackJsonString = String(data: hxpxPackJsonData, encoding: .utf8) else {
            throw HxPxEIOError.runtimeERROR("HxPx: JSON data to string conversion failed.")
        }
        return hxpxPackJsonString
    }
    
    public struct HxPxFile {
        public let id: UUID
        public let name: String
        public let pixs: [PIX]
    }
    
    struct PIXWithInIds {
        let pix: PIX
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
    }
    
    public func create(from jsonString: String) throws -> HxPxFile {
        
        let decoder = JSONDecoder()
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw HxPxEIOError.runtimeERROR("HxPx: JSON string to data conversion failed.")
        }
        
        let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        
        guard let jsonDict = json as? [String: Any] else {
            throw HxPxEIOError.runtimeERROR("HxPx: JSON object to dict conversion failed.")
        }
        
        guard let hxhDict = jsonDict["hxh"] as? [String: Any] else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxH is not valid.")
        }
        guard let bundleId = hxhDict["id"] as? String else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxH ID is not valid.")
        }
        if bundleId != kBundleId {
            throw HxPxEIOError.runtimeERROR("This JSON file is for another engine.")
        }
        
        guard let hxpxDict = jsonDict["hxpx"] as? [String: Any] else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxPx is not valid.")
        }
        guard let idStr = hxpxDict["id"] as? String else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxPx ID is not valid.")
        }
        guard let id = UUID(uuidString: idStr) else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxPx ID is corrupt.")
        }
        guard let name = hxpxDict["name"] as? String else {
            throw HxPxEIOError.runtimeERROR("HxPx: HxPx Name is not valid.")
        }
        
        guard let pixPackDictList = jsonDict["pixs"] as? [[String: Any]] else {
            throw HxPxEIOError.runtimeERROR("HxPx: PIX List is corrupt.")
        }
        var pixsWithInIds: [PIXWithInIds] = []
        for pixPackDict in pixPackDictList {
            guard let idStr = pixPackDict["id"] as? String else {
                throw HxPxEIOError.runtimeERROR("HxPx: PIX ID is not valid.")
            }
            guard let id = UUID(uuidString: idStr) else {
                throw HxPxEIOError.runtimeERROR("HxPx: PIX ID is corrupt.")
            }
            guard let pixKindStr = pixPackDict["type"] as? String else {
                throw HxPxEIOError.runtimeERROR("HxPx: PIX Type is not valid.")
            }
            guard let pixType = PIX.Kind.init(rawValue: pixKindStr)?.type else {
                throw HxPxEIOError.runtimeERROR("HxPx: PIX Kind is not valid.")
            }
            guard let pixDict = pixPackDict["pix"] as? [String: Any] else {
                throw HxPxEIOError.runtimeERROR("HxPx: \(pixType) dict is corrupt.")
            }
            let pixJsonData = try JSONSerialization.data(withJSONObject: pixDict, options: .prettyPrinted)
            let pix = try decoder.decode(pixType, from: pixJsonData)
            pix.id = id
            
            var inPixId: UUID? = nil
            var inPixAId: UUID? = nil
            var inPixBId: UUID? = nil
            var inPixsIds: [UUID]? = nil
            func getInPixId(_ key: String) throws -> UUID {
                guard let inPixIdStr = pixPackDict[key] as? String else {
                    throw HxPxEIOError.runtimeERROR("HxPx: PIX In ID not found.")
                }
                guard let inPixId = UUID(uuidString: inPixIdStr) else {
                    throw HxPxEIOError.runtimeERROR("HxPx: PIX In ID is corrupt.")
                }
                return inPixId
            }
            if let pixIn = pix as? PIX & PIXIn {
                if let pixInSingle = pixIn as? PIX & PIXInSingle {
                    inPixId = try? getInPixId("inPixId")
                } else if let pixInMerger = pixIn as? PIX & PIXInMerger {
                    inPixAId = try? getInPixId("inPixAId")
                    inPixBId = try? getInPixId("inPixBId")
                } else if let pixInMulti = pixIn as? PIX & PIXInMulti {
                    guard let inPixsIdsStrArr = pixPackDict["inPixsIds"] as? [String] else {
                        throw HxPxEIOError.runtimeERROR("HxPx: PIX Ins IDs not found.")
                    }
                    inPixsIds = []
                    for inPixIdStr in inPixsIdsStrArr {
                        guard let iInPixId = UUID(uuidString: inPixIdStr) else {
                            throw HxPxEIOError.runtimeERROR("HxPx: PIX In(s) is corrupt.")
                        }
                        inPixsIds?.append(iInPixId)
                    }
                }
            }
            
            let pixWithInIds = PIXWithInIds(pix: pix, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds)
            pixsWithInIds.append(pixWithInIds)
        }
        
        let pixs = pixsWithInIds.map { pixWithInIds -> PIX in return pixWithInIds.pix }
        
        func findPixOut(by id: UUID) throws -> PIX & PIXOut {
            for pix in pixs {
                if pix.id == id {
                    guard let pixOut = pix as? PIX & PIXOut else {
                        throw HxPxEIOError.runtimeERROR("HxPx: PIX In is not Out.")
                    }
                    return pixOut
                }
            }
            throw HxPxEIOError.runtimeERROR("HxPx: PIX In not found.")
        }
        
        for pixWithInIds in pixsWithInIds {
            if let pixIn = pixWithInIds.pix as? PIX & PIXIn {
                if var pixInSingle = pixIn as? PIX & PIXInSingle {
                    if pixWithInIds.inPixId != nil {
                        pixInSingle.inPix = try findPixOut(by: pixWithInIds.inPixId!)
                    }
                } else if var pixInMerger = pixIn as? PIX & PIXInMerger {
                    if pixWithInIds.inPixAId != nil {
                        pixInMerger.inPixA = try findPixOut(by: pixWithInIds.inPixAId!)
                    }
                    if pixWithInIds.inPixBId != nil {
                        pixInMerger.inPixB = try findPixOut(by: pixWithInIds.inPixBId!)
                    }
                } else if var pixInMulti = pixIn as? PIX & PIXInMulti {
                    if pixWithInIds.inPixsIds != nil {
                        for pixId in pixWithInIds.inPixsIds! {
                            pixInMulti.inPixs.append(try findPixOut(by: pixId))
                        }
                    }
                }
            }
        }
        
        let hxpx = HxPxFile(id: id, name: name, pixs: pixs)
        return hxpx
    }
    
}
