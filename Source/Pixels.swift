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
    
    #if os(iOS)
    let kBundleId = "se.hexagons.pixels"
    let kMetalLibName = "PixelsShaders"
    #elseif os(macOS)
    let kBundleId = "se.hexagons.pixels.macos"
    let kMetalLibName = "PixelsShaders-macOS"
    #endif
    
    public struct Signature: Encodable {
        public let id: String
        public let version: String
        public let build: Int
        public var formatted: String {
            return "\(id) - v\(version) - b\(build)"
        }
    }
    public var signature: Signature {
        return Signature(id: kBundleId,
                         version: Bundle(identifier: kBundleId)!.infoDictionary!["CFBundleShortVersionString"] as! String,
                         build: Int(Bundle(identifier: kBundleId)!.infoDictionary!["CFBundleVersion"] as! String) ?? -1)
    }
    
    public var renderMode: RenderMode = .frameLoop
    
    // FIXME: Metal Lib Delivery Pipeline
    let overrideWithMetalLibFromApp: Bool = true
    
    // MARK: Log
    
    public var logLevel: LogLevel = .error
    
    public var logLoopLimitActive = true
    public var logLoopLimitFrameCount = 10
    var logLoopLimitIndicated = false

    public var logTime = false
    public var logPadding = false
    public var logExtra = false

    public var logDynamicShaderCode = false
    
    public var logCallback: ((Log) -> ())?
    
    public var metalErrorCodeCallback: ((MetalErrorCode) -> ())?
    
    // MARK: Color
    
    public var colorBits: PIX.Color.Bits = ._8
    public var colorSpace: PIX.Color.Space = .sRGB // .displayP3
    
    // MARK: Linked PIXs
    
    var linkedPixs: [PIX] = []
    
    func linkIndex(of pix: PIX) -> Int? {
        for (i, linkedPix) in linkedPixs.enumerated() {
            if linkedPix == pix {
                return i
            }
        }
        return nil
    }
    
    // MARK: Frames
    
    #if os(iOS)
    typealias _DisplayLink = CADisplayLink
    #elseif os(macOS)
    typealias _DisplayLink = CVDisplayLink
    #endif
    var displayLink: _DisplayLink?
    
    var frameCallbacks: [(id: UUID, callback: () -> ())] = []
    
    public var frame = 0
    let startDate = Date()
    var frameDate = Date()
    public var seconds: CGFloat {
        return CGFloat(-startDate.timeIntervalSinceNow)
    }

    var _fps: Int = -1
    public var fps: Int { return min(_fps, fpsMax) }
    public var fpsMax: Int { if #available(iOS 10.3, *) {
        #if os(iOS)
        return UIScreen.main.maximumFramesPerSecond
        #elseif os(macOS)
        return 60
        #endif
    } else { return -1 } }
    
    // MARK: Metal
    
    public var metalDevice: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var textureCache: CVMetalTextureCache!
    var metalLibrary: MTLLibrary!
    var quadVertecis: Vertecies!
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
            quadVertecis = try makeQuadVertecis()
            quadVertexShader = try loadQuadVertexShader()
        } catch {
            log(.fatal, .pixels, "Initialization failed.", e: error)
        }
        
        #if os(iOS)
        displayLink = CADisplayLink(target: self, selector: #selector(self.frameLoop))
        displayLink!.add(to: RunLoop.main, forMode: .common)
        #elseif os(macOS)
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = { (displayLink: CVDisplayLink,
                                                                        inNow: UnsafePointer<CVTimeStamp>,
                                                                        inOutputTime: UnsafePointer<CVTimeStamp>,
                                                                        flagsIn: CVOptionFlags,
                                                                        flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                                                                        displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
            Pixels.main.frameLoop()
            return kCVReturnSuccess
        }
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
        #endif
        
        log(.info, .pixels, signature.version, clean: true)
        
    }

    
    // MARK: - Frame Loop
    
    @objc func frameLoop() {
        DispatchQueue.main.async {
            self.delegate?.pixelsFrameLoop()
            for frameCallback in self.frameCallbacks {
                frameCallback.callback()
            }
            self.renderPIXs()
        }
//        DispatchQueue(label: "pixels-frame-loop").async {}
        calcFPS()
        frame += 1
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
        let startFrameIndex = frame
        listenToFrames(callback: {
            if self.frame >= startFrameIndex + frames {
                done()
                return true
            } else {
                return false
            }
        })
    }
    
    // MARK: Flow Timer
    
//    public struct PixRenderState {
//        public let ref: PIXRef
//        public var requested: Bool = false
//        public va´r rendered: Bool = false
//        init(_ pix: PIX) {
//            ref = PIXRef(for: pix)
//        }
//    }
//    public class FlowTime: Equatable {
//        let id: UUID = UUID()
//        public let requestTime: Date = Date()
//        public var startTime: Date!
//        public var renderedFrames: Int = 0
//        public var fromPixRenderState: PixRenderState
//        public var thoughPixRenderStates: [PixRenderState] = []
//        public var toPixRenderState: PixRenderState
//        public var renderedSeconds: CGFloat!
//        public var endTime: Date!
//        var callback: (FlowTime) -> ()
//        init(from fromPixRenderState: PixRenderState, to toPixRenderState: PixRenderState, callback: @escaping (FlowTime) -> ()) {
//            self.fromPixRenderState = fromPixRenderState
//            self.toPixRenderState = toPixRenderState
//            self.callback = callback
//        }
//        public static func == (lhs: Pixels.FlowTime, rhs: Pixels.FlowTime) -> Bool {
//            return lhs.id == rhs.id
//        }
//    }
//
//    var flowTimes: [FlowTime] = []
//
//    public func flowTime(from pixIn: PIX & PIXOut, to pixOut: PIX & PIXIn, callback: @escaping (FlowTime) -> ()) {
//        let fromPixRenderState = PixRenderState(pixIn)
//        let toPixRenderState = PixRenderState(pixOut)
//        let flowTime = FlowTime(from: fromPixRenderState, to: toPixRenderState) { flowTime in
//            callback(flowTime)
//        }
//        flowTimes.append(flowTime)
//    }
//
//    func unfollowTime(_ flowTime: FlowTime) {
//        for (i, iFlowTime) in flowTimes.enumerated() {
//            if iFlowTime == flowTime {
//                flowTimes.remove(at: i)
//                break
//            }
//        }
//    }
    
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
    
    enum MetalLibraryError: Error {
        case runtimeERROR(String)
    }
    
    func loadMetalShaderLibrary() throws -> MTLLibrary {
        let bundle = overrideWithMetalLibFromApp ? Bundle.main : Bundle(identifier: kBundleId)!
        if overrideWithMetalLibFromApp {
            let bundleId = bundle.bundleIdentifier ?? "unknown-bundle-id"
            log(.info, .metal, "Metal Lib from Bundle: \(bundleId) [OVERRIDE]")
        }
        guard let libraryFile = bundle.path(forResource: kMetalLibName, ofType: "metallib") else {
            throw MetalLibraryError.runtimeERROR("Pixels Shaders: Metal Library not found.")
        }
        do {
            return try metalDevice.makeLibrary(filepath: libraryFile)
        } catch { throw error }
    }
    
    // MARK: Quad
    
    enum QuadError: Error {
        case runtimeERROR(String)
    }
    
    public struct Vertex {
        public var x,y,z: CGFloat
        public var s,t: CGFloat
        public var buffer: [Float] {
            return [x,y,s,t].map({ v -> Float in return Float(v) })
        }
        public init(x: CGFloat, y: CGFloat, z: CGFloat = 0.0, s: CGFloat, t: CGFloat) {
            self.x = x; self.y = y; self.z = z; self.s = s; self.t = t
        }
    }
    
    public struct Vertecies {
        public let buffer: MTLBuffer
        public let vertexCount: Int
        public let instanceCount: Int
        public let type: MTLPrimitiveType
        public let wireframe: Bool
        public init(buffer: MTLBuffer, vertexCount: Int, instanceCount: Int, type: MTLPrimitiveType = .triangle, wireframe: Bool = false) {
            self.buffer = buffer
            self.vertexCount = vertexCount
            self.instanceCount = instanceCount
            self.type = type
            self.wireframe = wireframe
        }
    }
    
    func makeQuadVertecis() throws -> Vertecies {
        return Vertecies(buffer: try makeQuadVertexBuffer(), vertexCount: 6, instanceCount: 2)
    }
    
    func makeQuadVertexBuffer() throws -> MTLBuffer {
        #if os(iOS)
        let vUp: CGFloat = 0.0
        let vDown: CGFloat = 1.0
        #elseif os(macOS)
        let vUp: CGFloat = 1.0
        let vDown: CGFloat = 0.0
        #endif
        let a = Vertex(x: -1.0, y: -1.0, z: 0.0, s: 0.0, t: vDown)
        let b = Vertex(x: 1.0, y: -1.0, z: 0.0, s: 1.0, t: vDown)
        let c = Vertex(x: -1.0, y: 1.0, z: 0.0, s: 0.0, t: vUp)
        let d = Vertex(x: 1.0, y: 1.0, z: 0.0, s: 1.0, t: vUp)
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
    
    // MARK: Vertex
    
    func makeVertexShader(_ vertexShaderName: String, with customMetalLibrary: MTLLibrary? = nil) throws -> MTLFunction {
        let lib = (customMetalLibrary ?? metalLibrary)!
        guard let vtxShader = lib.makeFunction(name: vertexShaderName) else {
            throw QuadError.runtimeERROR("Custom Vertex Shader failed to make.")
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
    
    enum ShaderError: Error {
        case metal(String)
        case sampler(String)
        case metalCode
        case metalErrorError
        case notFound(String)
    }
    
    // MARK: Frag
    
    func makeFrag(_ shaderName: String, with customMetalLibrary: MTLLibrary? = nil, from pix: PIX) throws -> MTLFunction {
        let frag: MTLFunction
        if let metalPix = pix as? PIXMetal {
            do {
                guard let metalCode = metalPix.metalCode else {
                    throw ShaderError.metalCode
                }
                let metalFrag = try makeMetalFrag(code: metalCode, name: shaderName)
                frag = metalFrag
            } catch {
                log(.error, nil, "Metal code in \"\(shaderName)\".", e: error)
                guard let errorFrag = metalLibrary.makeFunction(name: "error") else {
                    throw ShaderError.metalErrorError
                }
                frag = errorFrag
            }
        } else {
            let lib = (customMetalLibrary ?? metalLibrary)!
            guard let shaderFrag = lib.makeFunction(name: shaderName) else {
                throw ShaderError.notFound(shaderName)
            }
            frag = shaderFrag
        }
        return frag
    }
    
    // MARK: Metal
    
    func makeMetalFrag(code: String, name: String) throws -> MTLFunction {
        do {
            let codeLib = try metalDevice!.makeLibrary(source: code, options: nil)
            guard let frag = codeLib.makeFunction(name: name) else {
                throw ShaderError.metal("Metal func \"\(name)\" not found.")
            }
            return frag
        } catch {
            throw error
        }
    }
    
    // MARK: Pipeline
    
    func makeShaderPipeline(_ fragmentShader: MTLFunction, with customVertexShader: MTLFunction? = nil) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = customVertexShader ?? quadVertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = colorBits.mtl
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        do {
            return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch { throw error }
    }
    
    // MARK: Sampler
    
    func makeSampler(interpolate: MTLSamplerMinMagFilter, extend: MTLSamplerAddressMode, compare: MTLCompareFunction = .never) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = interpolate
        samplerInfo.magFilter = interpolate
        samplerInfo.sAddressMode = extend
        samplerInfo.tAddressMode = extend
        samplerInfo.compareFunction = compare
        guard let s = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw ShaderError.sampler("Shader Sampler failed to make.")
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
    
    
    // MARK: - Metal
    
    enum MetalError: Error {
        case fileNotFound(String)
        case uniform(String)
        case placeholder(String)
    }
    
    func embedMetalCode(uniforms: [MetalUniform], code: String, fileName: String) throws -> String {
        guard let metalFile = Bundle(identifier: kBundleId)!.url(forResource: fileName, withExtension: "txt") else {
            throw MetalError.fileNotFound(fileName)
        }
        do {
            var metalCode = try String(contentsOf: metalFile)
            let uniformsCode = try dynamicUniforms(uniforms: uniforms)
            metalCode = try insert(uniformsCode, in: metalCode, at: "uniforms")
            let comment = "/// Pixels Dynamic Shader Code"
            metalCode = try insert("\(comment)\n\n\n\(code)\n", in: metalCode, at: "code")
            #if DEBUG
            if logDynamicShaderCode {
                print("\nDYNAMIC SHADER CODE\n\n>>>>>>>>>>>>>>>>>\n\n\(metalCode)\n<<<<<<<<<<<<<<<<<\n")
            }
            #endif
            return metalCode
        } catch {
            throw error
        }
    }
    
    func dynamicUniforms(uniforms: [MetalUniform]) throws -> String {
        var code = ""
        for (i, uniform) in uniforms.enumerated() {
            guard uniform.name.range(of: " ") == nil else {
                throw MetalError.uniform("Uniform \"\(uniform.name)\" can not contain a spaces.")
            }
            if i > 0 {
                code += "\t"
            }
            code += "float \(uniform.name);"
            if i < uniforms.count - 1 {
                code += "\n"
            }
        }
        return code
    }
    
    func insert(_ snippet: String, in code: String, at placeholder: String) throws -> String {
        let placeholderComment = "/*<\(placeholder)>*/"
        guard code.range(of: placeholderComment) != nil else {
            throw MetalError.placeholder("Placeholder <\(placeholder)> not found.")
        }
        return code.replacingOccurrences(of: placeholderComment, with: snippet)
    }
    
}
