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
    
    var _fps: Int = 0
    public var fps: Int { return _fps }
    public var fpsMax: Int { if #available(iOS 10.3, *) { return UIScreen.main.maximumFramesPerSecond } else { return -1 } }
    public var frameIndex = 0
    var frameDate = Date()
    var ping = true
    var rendersThisFrame = 0
    
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
            print("HxPxE ERROR:", "Metal Device:", "System Default Device not found.")
        } else {
            commandQueue = metalDevice!.makeCommandQueue()
            textureCache = makeTextureCache()
            metalLibrary = loadMetalShaderLibrary()
            if metalLibrary != nil {
                quadVertexBuffer = makeQuadVertexBuffer()
                quadVertexShader = loadQuadVertexShader()
            }
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkCallback))
        displayLink!.add(to: RunLoop.main, forMode: .commonModes)
        
        if aLive {
            print("HxPxE is aLive! ⬢")
        } else {
            print("HxPxE ERROR:", "Not aLive...")
        }
        
    }
    
    // MARK: - Frame Loop
    
    @objc func displayLinkCallback() {
        if frameIndex == 0 { print("HxPxE Running...") }
        let frameTime = -frameDate.timeIntervalSinceNow
        _fps = Int(round(1 / frameTime))
        frameDate = Date()
        for frameCallback in frameCallbacks { frameCallback.callback() }
        delegate?.hxpxeFrameLoop()
        renderPIXs()
        if frameIndex < 10 { print("#", rendersThisFrame) }
//        if frameIndex % fpsMax == 0 { print("HxPxE PING", frameIndex / fpsMax) }
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
    
    func delay(_ delayFrames: Int, done: @escaping () -> ()) {
        let startFrameIndex = frameIndex
        listenToFrames(callback: {
            if self.frameIndex >= startFrameIndex + delayFrames {
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
        //        pix.view.metalView.readyToRender = {
        //            self.render(pix)
        //        }
    }
    
    func remove(pix: PIX) {
        for (i, iPix) in pixList.enumerated() {
            if iPix == pix {
                pixList.remove(at: i)
                break
            }
        }
        //        pix.view.metalView.readyToRender = nil
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
//        guard let quadVertexShaderSource = loadMetalShaderSource(named: "QuadVTX", fullName: true) else {
//            print("HxPxE ERROR:", "Quad:", "Source not loaded.")
//            return nil
//        }
//        guard let vtxMetalLibrary = try? metalDevice!.makeLibrary(source: quadVertexShaderSource, options: nil) else {
//            print("HxPxE ERROR:", "Quad:", "Library not created.")
//            return nil
//        }
        guard let vtxShader = metalLibrary!.makeFunction(name: "quadVTX") else {
            print("HxPxE ERROR:", "Quad:", "Function not made.")
            return nil
        }
        return vtxShader
    }
    
    // MARK: Cache
    
    func makeTextureCache() -> CVMetalTextureCache? {
        var textureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice!, nil, &textureCache) != kCVReturnSuccess {
            print("HxPxE ERROR:", "Cache:", "Creation failed.")
//            fatalError("Unable to allocate texture cache.") // CHECK
            return nil
        } else {
            return textureCache
        }
    }
    
    // MARK: Load Shaders
    
    func loadMetalShaderLibrary() -> MTLLibrary? {
        guard let libraryFile = Bundle(identifier: kBundleId)!.path(forResource: "HxPxE_Shaders", ofType: "metallib") else {
            print("HxPxE ERROR:", "Loading Metal Shaders Library:", "Not found.")
            return nil
        }
        do {
            return try metalDevice!.makeLibrary(filepath: libraryFile)
        } catch let error {
            print("HxPxE ERROR:", "Loading Metal Shaders Library:", "Make failed:", error.localizedDescription)
            return nil
        }
    }
    
//    func loadMetalShaderSource(named: String, fullName: Bool = false) -> String? {
//        let shaderFileName = fullName ? named : named.prefix(1).uppercased() + named.dropFirst() + "PIX"
//        print(">>>", shaderFileName)
//        // Bundle(identifier: kBundleId)
//        // Bundle(for: type(of: self))
//        // Bundle.main
//        guard let shaderPath = Bundle(identifier: kBundleId)!.path(forResource: shaderFileName, ofType: "metal") else {
//            print("HxPxE ERROR:", "Loading Metal Shader:", "Resource not found.")
//            return nil
//        }
//        guard let shaderSource = try? String(contentsOfFile: shaderPath, encoding: .utf8) else {
//            print("HxPxE ERROR:", "Loading Metal Shader:", "Resource corrupt.")
//            return nil
//        }
//        return shaderSource
//    }
    
    // MARK: Shader Pipeline
    
    func makeShaderPipeline(_ fragFuncName: String/*, from source: String*/) -> MTLRenderPipelineState? {
//        var pixMetalLibrary: MTLLibrary? = nil
//        do {
//            pixMetalLibrary = try metalDevice!.makeLibrary(source: source, options: nil)
//        } catch {
//            print("HxPxE ERROR:", "Pipeline:", "PIX Metal Library corrupt:", error.localizedDescription)
//            return nil
//        }
        guard let fragmentShader = metalLibrary!.makeFunction(name: fragFuncName) else {
            print("HxPxE ERROR:", "Make Shader Pipeline:", "PIX Metal Func:", "Not found:", fragFuncName)
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
            print("HxPxE ERROR:", "Make Shader Pipeline:", "Failed:", error.localizedDescription)
            return nil
        }
    }
    
    // MARK: Texture
    
    func makeTexture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache!, pixelBuffer, nil, HxPxE.main.colorBits.mtl, width, height, 0, &cvTextureOut)
        guard let cvTexture = cvTextureOut, let inputTexture = CVMetalTextureGetTexture(cvTexture) else {
            print("HxPxE ERROR:", "Textrue:", "Creation failed.")
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
    
    func raw(texture: MTLTexture) -> Array<float4> {
        let pixelCount = texture.width * texture.height
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        var textureComponentsArray = Array<float4>(repeating: float4(0), count: pixelCount)
        textureComponentsArray.withUnsafeMutableBytes {
            texture.getBytes($0.baseAddress!, bytesPerRow: (MemoryLayout<float4>.size * texture.width), from: region, mipmapLevel: 0)
        }
        return textureComponentsArray
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
        rendersThisFrame = 0
        for pix in pixList {
            if pix.needsRender {
                pix.needsRender = false
                if let pixIn = pix as? PIXInIO {
                    let pixOut = pixIn.pixInList.first! // CHECK BANG
                    if pixOut.texture == nil {
                        if frameIndex < 10 { print(pixOut, "💎", "RENDER", "Forced by", pix) }
                        if HxPxE.main.render(pixOut, force: true) {
                            if frameIndex < 10 { print(pixOut, "☘️", "RENDER", "Forced by", pix) }
                            rendersThisFrame += 1
                        } else {
                            print(pixOut, "🚨", "RENDER", "Forced by", pix)
                        }
                        continue
                    }
                }
//                guard pix.view.superview != nil else {
//                    print(pix, "Skipping Render, No Superview")
//                    continue
//                }
                if pix.view.superview != nil {
                    pix.view.metalView.readyToRender = {
                        if self.frameIndex < 10 { print(pix, "💎", "RENDER") }
                        if self.render(pix) {
                            if self.frameIndex < 10 { print(pix, "☘️", "RENDER") }
                            self.rendersThisFrame += 1
                        } else {
                            print(pix, "🚨", "RENDER")
                        }
                        pix.view.metalView.readyToRender = nil
                    }
                    pix.view.metalView.setNeedsDisplay()
                } else {
                    if frameIndex < 10 { print(pix, "💎", "RENDER", "Gohst") }
                    if self.render(pix) {
                        if frameIndex < 10 { print(pix, "☘️", "RENDER", "Gohst") }
                        rendersThisFrame += 1
                    } else {
                        print(pix, "🚨", "RENDER", "Gohst")
                    }
                }
            }
        }
    }
    
    func render(_ pix: PIX, force: Bool = false) -> Bool {
        
        guard aLive else {
            print(pix, "ERROR", "Render:", "Not aLive...")
            return false
        }
        
//        if self.pixelBuffer == nil && self.uses_source_texture {
//            AnalyticsAssistant.shared.logERROR("Render canceled: Source Texture is specified & Pixel Buffer is nil.")
//            return false
//        }
        
        // MARK: Command Buffer
        
        guard let commandBuffer = commandQueue!.makeCommandBuffer() else {
            print(pix, "ERROR", "Render:", "Command Buffer:", "Make faild.")
            return false
        }
        
        // MARK: Input Texture
        
        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if pixContent.isResource {
                guard let contentPixelBuffer = pixContent.contentPixelBuffer else {
                    print(pix, "ERROR", "Render:", "Texture Creation:", "Pixel Buffer is empty.")
                    return false
                }
                guard let sourceTexture = makeTexture(from: contentPixelBuffer) else {
                    print(pix, "ERROR", "Render:", "Texture Creation:", "Make faild.")
                    return false
                }
                inputTexture = sourceTexture
            } else {
                generator = true
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            let pixOut = pixIn.pixInList.first!
            guard let pixOutTexture = pixOut.texture else {
                print(pix, "ERROR", "Render:", "IO Texture not found for:", pixOut)
                return false
            }
            inputTexture = pixOutTexture // CHECK copy?
            if pix is PIXInMerger {
                let pixOutB = pixIn.pixInList[1]
                guard let pixOutTextureB = pixOutB.texture else {
                    print(pix, "ERROR", "Render:", "IO Texture B not found for:", pixOutB)
                    return false
                }
                secondInputTexture = pixOutTextureB // CHECK copy?
            }
        }
        
        // MARK: Custom Render
        
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                print(pix, "ERROR", "Render:", "CustomRenderDelegate not implemented.")
                return false
            }
            guard let customRenderdTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) else {
                print(pix, "ERROR", "Render:", "Custom Render faild.")
                return false
            }
            inputTexture = customRenderdTexture
        }
        
        // MARK: Drawable Texture
        
        var viewDrawable: CAMetalDrawable? = nil
        let drawableTexture: MTLTexture
        if pix.view.superview != nil {
            guard let currentDrawable: CAMetalDrawable = pix.view.metalView.currentDrawable else {
                print(pix, "ERROR", "Render:", "Current Drawable:", "Not found.")
                return false
            }
            viewDrawable = currentDrawable
            drawableTexture = currentDrawable.texture
        } else {
            guard let resolution = pix.resolution else {
                print(pix, "ERROR", "Render:", "Drawable Textue:", "Resolution not set.")
                return false
            }
            guard let emptyTexture = emptyTexture(size: resolution) else {
                print(pix, "ERROR", "Render:", "Drawable Textue:", "Empty Texture Creation Failed.")
                return false
            }
            drawableTexture = emptyTexture
        }
        
        // MARK: Command Encoder
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawableTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            print(pix, "ERROR", "Render:", "Command Encoder:", "Make faild.")
            return false
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
        
        if frameIndex < 10 { print(pix, "Rendering") }
        
        if viewDrawable != nil {
            commandBuffer.present(viewDrawable!)
        }
        
        commandBuffer.commit()

        if commandBuffer.error != nil {
            print(pix, "ERROR", "Render:", "Failed:", commandBuffer.error!.localizedDescription)
        }
        
        pix.didRender(texture: drawableTexture, force: force)
        
        return true
        
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
            guard let pixKind = (pix as? PIXable)?.kind else {
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
