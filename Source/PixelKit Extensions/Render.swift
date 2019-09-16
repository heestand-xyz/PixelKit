//
//  PixelKitRender.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-22.
//  Open Source - MIT License
//

import CoreGraphics
//#if os(iOS) && targetEnvironment(simulator)
//import MetalPerformanceShadersProxy
//#else
//import MetalKit
//#endif
import MetalKit

extension PixelKit {
    
    public enum MetalErrorCode {
        case IOAF(Int)
        public var info: String {
            switch self {
            case .IOAF(let code):
                return "IOAF code \(code)"
            }
        }
    }
    
    public enum RenderMode {
        case frameTree
        case frameLoop
        case frameLoopQueue
        case instantQueue
        case instantQueueSemaphore
        case direct
    }
    
    func renderPIXsTree() {
        let pixsNeedsRender: [PIX] = linkedPixs.filter { pix -> Bool in
            return pix.needsRender
        }
        guard !pixsNeedsRender.isEmpty else { return }
        self.frameTreeRendering = true
        DispatchQueue.global(qos: .background).async {
            self.log(.debug, .render, "-=-=-=-> Tree Started <-=-=-=-")
            var renderedPixs: [PIX] = []
            func render(_ pix: PIX) {
                self.log(.debug, .render, "-=-=-=-> Tree Render PIX: \"\(pix.name ?? "#")\"")
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.main.async {                
                    if pix.view.superview != nil {
                        #if os(iOS)
                        pix.view.metalView.setNeedsDisplay()
                        #elseif os(macOS)
                        guard let size = pix.resolution?.size else {
                            self.log(pix: pix, .warning, .render, "PIX Resolutuon unknown. Can't render in view.", loop: true)
                            return
                        }
                        pix.view.metalView.setNeedsDisplay(CGRect(x: 0, y: 0, width: size.width.cg, height: size.height.cg))
                        #endif
                        self.log(pix: pix, .detail, .render, "View Render requested.", loop: true)
                        guard let currentDrawable: CAMetalDrawable = pix.view.metalView.currentDrawable else {
                            self.log(pix: pix, .error, .render, "Current Drawable not found.")
                            return
                        }
                        pix.view.metalView.readyToRender = {
                            pix.view.metalView.readyToRender = nil
                            self.renderPIX(pix, with: currentDrawable, done: { success in
                                self.log(.debug, .render, "-=-=-=-> View Tree Did Render PIX: \"\(pix.name ?? "#")\"")
                                semaphore.signal()
                            })
                        }
                    } else {
                        self.renderPIX(pix, done: { success in
                            self.log(.debug, .render, "-=-=-=-> Tree Did Render PIX: \"\(pix.name ?? "#")\"")
                            semaphore.signal()
                        })
                    }
                }
                _ = semaphore.wait(timeout: .distantFuture)
                renderedPixs.append(pix)
            }
            func reverse(_ inPix: PIX & PIXInIO) {
                self.log(.debug, .render, "-=-=-=-> Tree Reverse PIX: \"\(inPix.name ?? "#")\"")
                for subPix in inPix.pixInList {
                    if !renderedPixs.contains(subPix) {
                        if let subInPix = subPix as? PIX & PIXInIO {
                            reverse(subInPix)
                        }
                        render(subPix)
                    }
                }
            }
            func traverse(_ pix: PIX) {
                self.log(.debug, .render, "-=-=-=-> Tree Traverse PIX: \"\(pix.name ?? "#")\"")
                if let outPix = pix as? PIXOutIO {
                    for inPixPath in outPix.pixOutPathList {
                        let inPix = inPixPath.pixIn as! PIX & PIXInIO
                        self.log(.debug, .render, "-=-=-=-> Tree Traverse Sub PIX: \"\(inPix.name ?? "#")\"")
                        var allInsRendered = true
                        for subPix in inPix.pixInList {
                            if !renderedPixs.contains(subPix) {
                                allInsRendered = false
                                break
                            }
                        }
                        if !allInsRendered {
                            reverse(inPix)
                        }
                        if !renderedPixs.contains(inPix) {
                            render(inPix)
                            traverse(inPix)
                        }
                    }
                }
            }
            for pix in pixsNeedsRender {
                if !renderedPixs.contains(pix) {
                    render(pix)
                    traverse(pix)
                }
            }
            self.log(.debug, .render, "-=-=-=-> Tree Ended <-=-=-=-")
            self.frameTreeRendering = false
        }
    }
    
    func renderPIXs() {
        loop: for pix in linkedPixs {
            if pix.needsRender {
                
                if [.frameLoopQueue, .instantQueue, .instantQueueSemaphore].contains(renderMode) {
                    guard !pix.rendering else {
                        self.log(pix: pix, .warning, .render, "Render in progress.", loop: true)
                        continue
                    }
                    if let pixIn = pix as? PIXInIO {
                        for pixOut in pixIn.pixInList {
                            guard pix.renderIndex + 1 == pixOut.renderIndex else {
                                log(pix: pix, .detail, .render, "Queue In: \(pix.renderIndex) + 1 != \(pixOut.renderIndex)")
                                continue
                            }
//                            log(pix: pix, .warning, .render, ">>> Queue In: \(pix.renderIndex) + 1 == \(pixOut.renderIndex)")
                        }
                    }
                    if let pixOut = pix as? PIXOutIO {
                        for pixOutPath in pixOut.pixOutPathList {
                            guard pix.renderIndex == pixOutPath.pixIn.renderIndex else {
                                log(pix: pix, .detail, .render, "Queue Out: \(pix.renderIndex) != \(pixOutPath.pixIn.renderIndex)")
                                continue
                            }
//                            log(pix: pix, .warning, .render, ">>> Queue Out: \(pix.renderIndex) == \(pixOutPath.pixIn.renderIndex)")
                        }
                    }
                }
                
//                if let pixIn = pix as? PIX & PIXInIO {
//                    let pixOuts = pixIn.pixInList
//                    for (i, pixOut) in pixOuts.enumerated() {
//                        if pixOut.texture == nil {
//                            log(pix: pix, .warning, .render, "PIX Ins \(i) not rendered.", loop: true)
//                            pix.needsRender = false // CHECK
//                            continue loop
//                        }
//                    }
//                }
                
                var semaphore: DispatchSemaphore?
                if renderMode == .instantQueueSemaphore {
                    semaphore = DispatchSemaphore(value: 0)
                }
                
                DispatchQueue.main.async {
//                    #if targetEnvironment(simulator)
//                    let isSimulator = true
//                    #else
//                    let isSimulator = false
//                    #endif
                    if pix.view.superview != nil/* && !isSimulator*/ {
                        #if os(iOS)
                        pix.view.metalView.setNeedsDisplay()
                        #elseif os(macOS)
                        guard let size = pix.resolution?.size else {
                            self.log(pix: pix, .warning, .render, "PIX Resolutuon unknown. Can't render in view.", loop: true)
                            return
                        }
                        pix.view.metalView.setNeedsDisplay(CGRect(x: 0, y: 0, width: size.width.cg, height: size.height.cg))
                        #endif
                        self.log(pix: pix, .detail, .render, "View Render requested.", loop: true)
                        let currentDrawable: CAMetalDrawable? = pix.view.metalView.currentDrawable
                        if currentDrawable == nil {
                            self.log(pix: pix, .error, .render, "Current Drawable not found.")
                        }
                        pix.view.metalView.readyToRender = {
                            pix.view.metalView.readyToRender = nil
                            self.renderPIX(pix, with: currentDrawable, done: { success in
                                if self.renderMode == .instantQueueSemaphore {
                                    semaphore!.signal()
                                }
                            })
                        }
                    } else {
                        self.renderPIX(pix, done: { success in
                            if self.renderMode == .instantQueueSemaphore {
                                semaphore!.signal()
                            }
                        })
                    }
                }
                
                if self.renderMode == .instantQueueSemaphore {
                    _ = semaphore!.wait(timeout: .distantFuture)
                }
                
            }
        }
    }
    
    func renderPIX(_ pix: PIX, with currentDrawable: CAMetalDrawable? = nil, force: Bool = false, done: @escaping (Bool?) -> ()) {
        guard !pix.bypass else {
            self.log(pix: pix, .info, .render, "Render bypassed.", loop: true)
            done(nil)
            return
        }
        guard !pix.rendering else {
            self.log(pix: pix, .debug, .render, "Render in progress...", loop: true)
            done(nil)
            return
        }
        pix.needsRender = false
//        let queue = DispatchQueue(label: "pixelKit-render", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .never, target: nil)
//        queue.async {
//            DispatchQueue.main.async {
//            }
            let renderStartTime = CFAbsoluteTimeGetCurrent()
//        let renderStartFrame = frame
            self.log(pix: pix, .detail, .render, "Starting render.\(force ? " Forced." : "")", loop: true)
//        for flowTime in flowTimes {
//            if flowTime.fromPixRenderState.ref.id == pix.id {
//                if !flowTime.fromPixRenderState.requested {
//                    flowTime.fromPixRenderState.requested = true
//                } else {
//
//                }
//            } else {
//
//            }
//        }
            do {
                try self.render(pix, with: currentDrawable, force: force, completed: { texture in
                    let renderTime = CFAbsoluteTimeGetCurrent() - renderStartTime
                    let renderTimeMs = CGFloat(Int(round(renderTime * 10_000))) / 10
//                let renderFrames = self.frame - renderStartFrame
                    self.log(pix: pix, .info, .render, "Rendered! \(force ? "Forced. " : "")[\(renderTimeMs)ms]", loop: true)
//                for flowTime in self.flowTimes {
//                    if flowTime.fromPixRenderState.requested {
//                        if !flowTime.fromPixRenderState.rendered {
//                            flowTime.fromPixRenderState.rendered = true
//                        }
//                    }
//                }
//                    DispatchQueue.main.async {
                        pix.didRender(texture: texture, force: force)
                        done(true)
//                    }
                }, failed: { error in
                    var ioafMsg: String? = nil
                    let err = error.localizedDescription
                    if err.contains("IOAF code") {
                        if let iofaCode = Int(err[err.count - 2..<err.count - 1]) {
                            DispatchQueue.main.async {
                                self.metalErrorCodeCallback?(.IOAF(iofaCode))
                            }
                            ioafMsg = "IOAF code \(iofaCode). Sorry, this is an Metal GPU error, usually seen on older devices."
                        }
                    }
                    self.log(pix: pix, .error, .render, "Render of shader failed... \(force ? "Forced." : "") \(ioafMsg ?? "")", loop: true, e: error)
//                    DispatchQueue.main.async {
                        done(false)
//                    }
                })
            } catch {
                self.log(pix: pix, .error, .render, "Render setup failed.\(force ? " Forced." : "")", loop: true, e: error)
            }
//        }
    }
    
    enum RenderError: Error {
        case commandBuffer
        case texture(String)
        case custom(String)
        case drawable(String)
        case commandEncoder
        case uniformsBuffer
        case vertices
        case vertexTexture
        case nilCustomTexture
    }
    
    func render(_ pix: PIX, with currentDrawable: CAMetalDrawable?, force: Bool, completed: @escaping (MTLTexture) -> (), failed: @escaping (Error) -> ()) throws {

        // Render Time
        let globalRenderTime = CFAbsoluteTimeGetCurrent()
        var localRenderTime = CFAbsoluteTimeGetCurrent()
        var renderTime: Double = -1
        var renderTimeMs: Double = -1
        log(pix: pix, .debug, .metal, "Render Timer: Started")

        
        // MARK: Command Buffer
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Command Buffer ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        // MARK: Template
        
        let needsInTexture = pix is PIXInIO
        let hasInTexture = needsInTexture && (pix as! PIXInIO).pixInList.first?.texture != nil
        let needsContent = pix.contentLoaded != nil
        let hasContent = pix.contentLoaded == true
        let template = (needsInTexture && !hasInTexture) || (needsContent && !hasContent)
        
        
        // MARK: Input Texture
        
        let generator: Bool = pix is PIXGenerator
        var (inputTexture, secondInputTexture, customTexture): (MTLTexture?, MTLTexture?, MTLTexture?)
        if !template {
            (inputTexture, secondInputTexture, customTexture) = try textures(from: pix, with: commandBuffer)
        }
        
        // MARK: Drawable
        
        let res = pix.resolution
//        guard let res = pix.resolution else {
//            throw RenderError.drawable("PIX Resolution not set.")
//        }
        
        var viewDrawable: CAMetalDrawable? = nil
        let drawableTexture: MTLTexture
        if currentDrawable != nil {
            viewDrawable = currentDrawable!
            drawableTexture = currentDrawable!.texture
        } else if pix.texture != nil && res == PIX.Res.custom(w: pix.texture!.width, h: pix.texture!.height) {
            drawableTexture = pix.texture!
        } else {
            drawableTexture = try emptyTexture(size: res.size.cg)
        }
        
        if logHighResWarnings {
            let drawRes = PIX.Res(texture: drawableTexture)
            if (drawRes >= ._16384) != false {
                log(pix: pix, .detail, .render, "Epic res: \(drawRes)")
            } else if (drawRes >= ._8192) != false {
                log(pix: pix, .detail, .render, "Extreme res: \(drawRes)")
            } else if (drawRes >= ._4096) != false {
                log(pix: pix, .detail, .render, "High res: \(drawRes)")
            }
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Drawable ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        // Custom
        
        if let pixCustom = pix as? PIXCustom, pix.customRenderActive {
            guard let customRenderedTexture = pixCustom.customRender(drawableTexture, with: commandBuffer) else {
                throw RenderError.nilCustomTexture
            }
            customTexture = customRenderedTexture
        }
        
        let customRenderActive = pix.customRenderActive || pix.customMergerRenderActive
        if customRenderActive, let customTexture = customTexture {
            inputTexture = customTexture
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Custom ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }

        
        // MARK: Command Encoder
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawableTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            throw RenderError.commandEncoder
        }
        commandEncoder.setRenderPipelineState(pix.pipeline)
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Command Encoder ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Uniforms
        
        var unifroms: [Float] = []
        if !template {
            unifroms = pix.uniforms.map { uniform -> Float in return Float(uniform) }
        }
        if let genPix = pix as? PIXGenerator {
            unifroms.append(genPix.premultiply ? 1 : 0)
        }
        if let mergerEffectPix = pix as? PIXMergerEffect {
            unifroms.append(Float(mergerEffectPix.placement.index))
        }
        if template {
            unifroms.append(Float(res.width.cg))
            unifroms.append(Float(res.height.cg))
        }
        if pix.shaderNeedsAspect || template {
            unifroms.append(Float(res.aspect.cg))
        }
        if !unifroms.isEmpty {
            let size = MemoryLayout<Float>.size * unifroms.count
            guard let uniformsBuffer = metalDevice.makeBuffer(length: size, options: []) else {
                commandEncoder.endEncoding()
                throw RenderError.uniformsBuffer
            }
            let bufferPointer = uniformsBuffer.contents()
            memcpy(bufferPointer, &unifroms, size)
            commandEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Uniforms ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Uniform Arrays
        
        // Hardcoded at 128
        // Defined as ARRMAX in shaders
        let uniformArrayMaxLimit = 128
        
        var uniformArray: [[Float]] = pix.uniformArray.map { uniformValues -> [Float] in
            return uniformValues.map({ uniform -> Float in return Float(uniform) })
        }
        
        if !uniformArray.isEmpty && !template {
            
            var uniformArrayActive: [Bool] = uniformArray.map { _ -> Bool in return true }
            
            if uniformArray.count < uniformArrayMaxLimit {
                let arrayCount = uniformArray.first!.count
                for _ in uniformArray.count..<uniformArrayMaxLimit {
                    var emptyArray: [Float] = []
                    for _ in 0..<arrayCount {
                        emptyArray.append(0.0)
                    }
                    uniformArray.append(emptyArray)
                    uniformArrayActive.append(false)
                }
            } else if uniformArray.count > uniformArrayMaxLimit {
                let origialCount = uniformArray.count
                let overflow = origialCount - uniformArrayMaxLimit
                for _ in 0..<overflow {
                    uniformArray.removeLast()
                    uniformArrayActive.removeLast()
                }
                log(pix: pix, .warning, .render, "Max limit of uniform arrays exceeded. Last values will be truncated. \(origialCount) / \(uniformArrayMaxLimit)")
            }
            
            var uniformFlatMap = uniformArray.flatMap { uniformValues -> [Float] in return uniformValues }
            
            let size: Int = MemoryLayout<Float>.size * uniformFlatMap.count
            guard let uniformsArraysBuffer = metalDevice.makeBuffer(length: size, options: []) else {
                commandEncoder.endEncoding()
                throw RenderError.uniformsBuffer
            }
            let bufferPointer = uniformsArraysBuffer.contents()
            memcpy(bufferPointer, &uniformFlatMap, size)
            commandEncoder.setFragmentBuffer(uniformsArraysBuffer, offset: 0, index: 1)
            
            let activeSize: Int = MemoryLayout<Bool>.size * uniformArrayActive.count
            guard let uniformsArraysActiveBuffer = metalDevice.makeBuffer(length: activeSize, options: []) else {
                commandEncoder.endEncoding()
                throw RenderError.uniformsBuffer
            }
            let activeBufferPointer = uniformsArraysActiveBuffer.contents()
            memcpy(activeBufferPointer, &uniformArrayActive, activeSize)
            commandEncoder.setFragmentBuffer(uniformsArraysActiveBuffer, offset: 0, index: 2)
            
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Uniform Arrays ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Fragment Texture
        
        if !generator && !template {
            commandEncoder.setFragmentTexture(inputTexture!, index: 0)
        }
        
        if secondInputTexture != nil {
            commandEncoder.setFragmentTexture(secondInputTexture!, index: 1)
        }
        
        commandEncoder.setFragmentSamplerState(pix.sampler, index: 0)
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Fragment Texture ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Vertices
        
        let vertices: Vertices
        if pix.customGeometryActive {
            guard let customVertices = pix.customGeometryDelegate?.customVertices() else {
                commandEncoder.endEncoding()
                throw RenderError.vertices
            }
            vertices = customVertices
        } else {
            vertices = quadVertecis
        }
        
        if vertices.wireframe {
            commandEncoder.setTriangleFillMode(.lines)
        }

        commandEncoder.setVertexBuffer(vertices.buffer, offset: 0, index: 0)
        
        // MARK: Matrix
        
        if !pix.customMatrices.isEmpty {
            var matrices = pix.customMatrices
            guard let uniformBuffer = metalDevice.makeBuffer(length: MemoryLayout<Float>.size * 16 * matrices.count, options: []) else {
                commandEncoder.endEncoding()
                throw RenderError.uniformsBuffer
            }
            let bufferPointer = uniformBuffer.contents()
            memcpy(bufferPointer, &matrices, MemoryLayout<Float>.size * 16 * matrices.count)
            commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        }

        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Vertices ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Vertex Uniforms
        
        var vertexUnifroms: [Float] = pix.vertexUniforms.map { uniform -> Float in return Float(uniform) }
        if !vertexUnifroms.isEmpty {
            let size = MemoryLayout<Float>.size * vertexUnifroms.count
            guard let uniformsBuffer = metalDevice.makeBuffer(length: size, options: []) else {
                commandEncoder.endEncoding()
                throw RenderError.uniformsBuffer
            }
            let bufferPointer = uniformsBuffer.contents()
            memcpy(bufferPointer, &vertexUnifroms, size)
            commandEncoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Vertex Uniforms ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Custom Vertex Texture
        
        if pix.customVertexTextureActive {
            
            guard let vtxPixInTexture = pix.customVertexPixIn?.texture else {
                commandEncoder.endEncoding()
                throw RenderError.vertexTexture
            }
            
            commandEncoder.setVertexTexture(vtxPixInTexture, index: 0)
            
            let sampler = try makeSampler(interpolate: .linear, extend: .clampToEdge, mipFilter: .linear)
            commandEncoder.setVertexSamplerState(sampler, index: 0)
            
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Custom Vertex Texture ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Draw
        
        commandEncoder.drawPrimitives(type: vertices.type, vertexStart: 0, vertexCount: vertices.vertexCount, instanceCount: 1)
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Draw ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        
        // MARK: Encode
        
        commandEncoder.endEncoding()
        
        if viewDrawable != nil {
            commandBuffer.present(viewDrawable!)
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] Encode ")
            localRenderTime = CFAbsoluteTimeGetCurrent()
        }
        
        // Render Time
        if logTime {
            renderTime = CFAbsoluteTimeGetCurrent() - globalRenderTime
            renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
            log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] CPU ")
        }
        
        
        // MARK: Render
        
        pix.rendering = true
        
//        if #available(iOS 11.0, *) {
//            let sharedCaptureManager = MTLCaptureManager.shared()
//            let myCaptureScope = sharedCaptureManager.makeCaptureScope(device: metalDevice)
//            myCaptureScope.label = "PixelKit GPU Capture Scope"
//            sharedCaptureManager.defaultCaptureScope = myCaptureScope
//            myCaptureScope.begin()
//        }
        
        commandBuffer.addCompletedHandler({ _ in
            pix.rendering = false
            if let error = commandBuffer.error {
                failed(error)
                return
            }
            
            // Render Time
            if self.logTime {
                
                renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
                renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
                self.log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] GPU ")
                
                renderTime = CFAbsoluteTimeGetCurrent() - globalRenderTime
                renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
                self.log(pix: pix, .debug, .metal, "Render Timer: [\(renderTimeMs)ms] CPU + GPU ")
                
                self.log(pix: pix, .debug, .metal, "Render Timer: Ended")
                
            }

            DispatchQueue.main.async {
                completed(drawableTexture)
            }
        })
        
        commandBuffer.commit()
    
//        if #available(iOS 11.0, *) {
//            let sharedCaptureManager = MTLCaptureManager.shared()
//            guard !sharedCaptureManager.isCapturing else { fatalError() }
//            sharedCaptureManager.defaultCaptureScope?.end()
//        }
        
    }
    
}
