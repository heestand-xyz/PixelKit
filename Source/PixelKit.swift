//
//  PixelKit.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import CoreGraphics
#if os(iOS) && targetEnvironment(simulator)
import MetalPerformanceShadersProxy
#else
import MetalKit
#endif
import simd

public class PixelKit {
    
    public static let main = PixelKit()
    
    public weak var delegate: PixelDelegate?
    
    // MARK: Signature
    
    #if os(iOS)
    let kBundleId = "se.hexagons.pixelkit"
    let kMetalLibName = "PixelKitShaders"
    #elseif os(macOS)
    let kBundleId = "se.hexagons.pixelkit.macos"
    let kMetalLibName = "PixelKitShaders-macOS"
    #endif
    
    public var renderMode: RenderMode = .frameLoop
    
    // MARK: Log
    
    public var logActive: Bool = true
    public var logLevel: LogLevel = .error
    public var logSource: Bool = false
    public var logLoopLimitActive = true
    public var logLoopLimitFrameCount = 30
    public var logHighResWarnings = true
    var logLoopLimitIndicated = false

    public var logTime = false
    public var logPadding = false
    public var logExtra = false

    public var logDynamicShaderCode = false
    
    public var logCallback: ((Log) -> ())?
    
    public var metalErrorCodeCallback: ((MetalErrorCode) -> ())?
    
    // MARK: Color
    
    public var bits: LiveColor.Bits = ._8
    public var colorSpace: LiveColor.Space = .sRGB
    
    // MARK: Linked PIXs
    
    public var finalPix: PIX?
    
    public var pixLinks: PIX.Links = PIX.Links([])
    public var linkedPixs: [PIX] {
        return pixLinks.reduce([], { arr, pix -> [PIX] in
            var arr = arr
            if pix != nil {
                arr.append(pix!)
            }
            return arr
        })
    }

//    struct RenderedPIX {
//        let pix: PIX
//        let rendered: Bool
//    }
//    var renderedPixs: [RenderedPIX] = []
//    var allPixRendered: Bool {
//        for renderedPix in renderedPixs {
//            if !renderedPix.rendered {
//                return false
//            }
//        }
//        return true
//    }
//    var noPixRendered: Bool {
//        for renderedPix in renderedPixs {
//            if renderedPix.rendered {
//                return false
//            }
//        }
//        return true
//    }

    func linkIndex(of pix: PIX) -> Int? {
        for (i, linkedPix) in pixLinks.enumerated() {
            guard linkedPix != nil else { continue }
            if linkedPix! == pix {
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
    public var finalFrame = 0
    let startDate = Date()
    var frameDate = Date()
    var finalFrameDate: Date?
    public var seconds: CGFloat {
        return CGFloat(-startDate.timeIntervalSinceNow)
    }

    var _fps: Int = -1
    public var fps: Int { return min(_fps, fpsMax) }
    var _finalFps: Int = -1
    public var finalFps: Int? { return finalPix != nil && _finalFps != -1 ? min(_finalFps, fpsMax) : nil }
    public var fpsMax: Int { if #available(iOS 10.3, *) {
        #if os(iOS)
        return UIScreen.main.maximumFramesPerSecond
        #elseif os(macOS)
        return 60
        #endif
    } else { return -1 } }
    
    var instantQueueActivated: Bool = false
    
    // MARK: Metal
    
    public var metalDevice: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var textureCache: CVMetalTextureCache!
    var metalLibrary: MTLLibrary!
    var quadVertecis: Vertices!
    var quadVertexShader: MTLFunction!
    
    
    // MARK: - Life Cycle
    
    init() {
        
        metalDevice = MTLCreateSystemDefaultDevice()
        guard metalDevice != nil else {
            log(.fatal, .pixelKit, "Metal Device not found.")
            return
        }
        
        commandQueue = metalDevice.makeCommandQueue()
        guard commandQueue != nil else {
            log(.fatal, .pixelKit, "Command Queue failed to make.")
            return
        }
        
        do {
            textureCache = try makeTextureCache()
            metalLibrary = try loadMetalShaderLibrary()
            quadVertecis = try makeQuadVertecis()
            quadVertexShader = try loadQuadVertexShader()
        } catch {
            log(.fatal, .pixelKit, "Initialization failed.", e: error)
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
            PixelKit.main.frameLoop()
            return kCVReturnSuccess
        }
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
        #endif
        
        log(.info, .pixelKit, "ready to render.", clean: true)
        
    }

    
    // MARK: - Frame Loop
    
    @objc func frameLoop() {
        DispatchQueue.main.async {
            self.delegate?.pixelFrameLoop()
            for frameCallback in self.frameCallbacks {
                frameCallback.callback()
            }
            self.checkAllLive()
            if [.frameLoop, .frameLoopQueue].contains(self.renderMode) {
                self.renderPIXs()
            } else if [.instantQueue, .instantQueueSemaphore].contains(self.renderMode) {
                if !self.instantQueueActivated {
                    DispatchQueue.global(qos: .background).async {
                        while true {
                            self.renderPIXs()
                        }
                    }
                    self.instantQueueActivated = true
                }
            }
        }
//        DispatchQueue(label: "pixelKit-frame-loop").async {}
        calcFPS()
    }
    
    func checkAllLive() {
        for linkedPix in linkedPixs {
            linkedPix.checkLive()
        }
    }
    
    func calcFPS() {

        let frameTime = -frameDate.timeIntervalSinceNow
        _fps = Int(round(1.0 / frameTime))
        frameDate = Date()
        frame += 1

        if let finalFrameDate = finalFrameDate {
            let finalFrameTime = -finalFrameDate.timeIntervalSinceNow
            _finalFps = Int(round(1.0 / finalFrameTime))
        }
        let finalFrame = finalPix?.renderIndex ?? 0
        if finalFrame != self.finalFrame {
            finalFrameDate = Date()
        }
        self.finalFrame = finalFrame
        
    }
    
    public enum ListenState {
        case `continue`
        case done
    }
    
    public func listenToFramesUntil(callback: @escaping () -> (ListenState)) {
        let id = UUID()
        frameCallbacks.append((id: id, callback: {
            if callback() == .done {
                self.unlistenToFrames(for: id)
            }
        }))
    }
    
    public func listenToFrames(id: UUID, callback: @escaping () -> ()) {
        frameCallbacks.append((id: id, callback: {
            callback()
        }))
    }
    
    public func listenToFrames(callback: @escaping () -> ()) {
        frameCallbacks.append((id: UUID(), callback: {
            callback()
        }))
    }
    
    public func unlistenToFrames(for id: UUID) {
        for (i, frameCallback) in self.frameCallbacks.enumerated() {
            if frameCallback.id == id {
                frameCallbacks.remove(at: i)
                break
            }
        }
    }
    
    
    public func delay(frames: Int, done: @escaping () -> ()) {
        let startFrameIndex = frame
        listenToFramesUntil(callback: {
            if self.frame >= startFrameIndex + frames {
                done()
                return .done
            } else {
                return .continue
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
//        public static func == (lhs: PixelKit.FlowTime, rhs: PixelKit.FlowTime) -> Bool {
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
        pixLinks.append(pix)
    }
    
    func remove(pix: PIX) {
        pixLinks.remove(pix)
    }
    
    
    // MARK: - Setup
    
    // MARK: Shaders
    
    enum MetalLibraryError: Error {
        case runtimeERROR(String)
    }
    
    func loadMetalShaderLibrary() throws -> MTLLibrary {
        guard let libraryFile = Bundle(for: type(of: self)).path(forResource: kMetalLibName, ofType: "metallib") else {
            throw MetalLibraryError.runtimeERROR("PixelKit Shaders: Metal Library not found.")
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
        public var x,y,z: LiveFloat
        public var s,t: LiveFloat
        public var buffer: [Float] {
            return [x,y,s,t].map({ v -> Float in return Float(v.uniform) })
        }
        public var buffer3d: [Float] {
            return [x,y,z,s,t].map({ v -> Float in return Float(v.uniform) })
        }
        public init(x: LiveFloat, y: LiveFloat, z: LiveFloat = 0.0, s: LiveFloat, t: LiveFloat) {
            self.x = x; self.y = y; self.z = z; self.s = s; self.t = t
        }
    }
    
    public struct Vertices {
        public let buffer: MTLBuffer
        public let vertexCount: Int
        public let type: MTLPrimitiveType
        public let wireframe: Bool
        public init(buffer: MTLBuffer, vertexCount: Int, type: MTLPrimitiveType = .triangle, wireframe: Bool = false) {
            self.buffer = buffer
            self.vertexCount = vertexCount
            self.type = type
            self.wireframe = wireframe
        }
    }
    
    func makeQuadVertecis() throws -> Vertices {
        return Vertices(buffer: try makeQuadVertexBuffer(), vertexCount: 6)
    }
    
    func makeQuadVertexBuffer() throws -> MTLBuffer {
//        #if os(iOS)
        let vUp: CGFloat = 0.0
        let vDown: CGFloat = 1.0
//        #elseif os(macOS)
//        let vUp: CGFloat = 1.0
//        let vDown: CGFloat = 0.0
//        #endif
        let a = Vertex(x: -1.0, y: -1.0, z: 0.0, s: 0.0, t: LiveFloat(vDown))
        let b = Vertex(x: 1.0, y: -1.0, z: 0.0, s: 1.0, t: LiveFloat(vDown))
        let c = Vertex(x: -1.0, y: 1.0, z: 0.0, s: 0.0, t: LiveFloat(vUp))
        let d = Vertex(x: 1.0, y: 1.0, z: 0.0, s: 1.0, t: LiveFloat(vUp))
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
        case metalError(Error, MTLFunction)
        case metalErrorError
        case notFound(String)
    }
    
    // MARK: Frag
    
    func makeFrag(_ shaderName: String, with customMetalLibrary: MTLLibrary? = nil, from pix: PIX) throws -> MTLFunction {
        let frag: MTLFunction
        if let metalPix = pix as? PIXMetal {
            return try makeMetalFrag(shaderName, from: metalPix)
        } else {
            let lib = (customMetalLibrary ?? metalLibrary)!
            guard let shaderFrag = lib.makeFunction(name: shaderName) else {
                throw ShaderError.notFound(shaderName)
            }
            frag = shaderFrag
        }
        return frag
    }
    
    func makeMetalFrag(_ shaderName: String, from metalPix: PIXMetal) throws -> MTLFunction {
        let frag: MTLFunction
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
            throw ShaderError.metalError(error, errorFrag)
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
    
    func makeShaderPipeline(_ fragmentShader: MTLFunction, with customVertexShader: MTLFunction? = nil, addMode: Bool = false) throws -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = customVertexShader ?? quadVertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = bits.mtl
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = true
        if addMode {
            pipelineStateDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineStateDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .one
            pipelineStateDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .one
            pipelineStateDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineStateDescriptor.colorAttachments[0].alphaBlendOperation = .add
        } else {
            pipelineStateDescriptor.colorAttachments[0].destinationRGBBlendFactor = .blendAlpha
        }
        do {
            return try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch { throw error }
    }
    
    // MARK: Sampler
    
    func makeSampler(interpolate: MTLSamplerMinMagFilter, extend: MTLSamplerAddressMode, mipFilter: MTLSamplerMipFilter, compare: MTLCompareFunction = .never) throws -> MTLSamplerState {
        let samplerInfo = MTLSamplerDescriptor()
        samplerInfo.minFilter = interpolate
        samplerInfo.magFilter = interpolate
        samplerInfo.sAddressMode = extend
        samplerInfo.tAddressMode = extend
        samplerInfo.compareFunction = compare
        samplerInfo.mipFilter = mipFilter
        guard let sampler = metalDevice.makeSamplerState(descriptor: samplerInfo) else {
            throw ShaderError.sampler("Shader Sampler failed to make.")
        }
        return sampler
    }
    
    
    // MARK: - Raw
    
    func raw8(texture: MTLTexture) -> [UInt8]? {
        guard bits == ._8 else { log(.error, .pixelKit, "Raw 8 - To access this data, change: \"pixelKit.bits = ._8\"."); return nil }
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
        guard bits == ._16 else { log(.error, .pixelKit, "Raw 16 - To access this data, change: \"pixelKit.bits = ._16\"."); return nil }
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
        guard bits != ._32 else { log(.error, .pixelKit, "Raw 32 - To access this data, change: \"pixelKit.bits = ._32\"."); return nil }
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
        switch bits {
        case ._8, ._10:
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
        guard let metalFile = Bundle(for: type(of: self)).url(forResource: fileName, withExtension: "txt") else {
            throw MetalError.fileNotFound(fileName)
        }
        do {
            var metalCode = try String(contentsOf: metalFile)
            let uniformsCode = try dynamicUniforms(uniforms: uniforms)
            metalCode = try insert(uniformsCode, in: metalCode, at: "uniforms")
            let comment = "/// PixelKit Dynamic Shader Code"
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
