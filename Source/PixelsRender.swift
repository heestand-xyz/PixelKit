//
//  PixelsRender.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-22.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

extension Pixels {
    
    func renderPIXs() {
        loop: for pix in linkedPixs {
            if pix.needsRender {
                if let pixIn = pix as? PIX & PIXInIO {
                    let pixOuts = pixIn.pixInList
                    for (i, pixOut) in pixOuts.enumerated() {
                        if pixOut.texture == nil {
                            log(pix: pix, .warning, .render, "PIX Ins \(i) not rendered.", loop: true)
                            pix.needsRender = false // CHECK
                            continue loop
                        }
                    }
                }
                if pix.view.superview != nil {
                    pix.view.metalView.setNeedsDisplay()
                    log(pix: pix, .info, .render, "View Render requested.", loop: true)
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
    
    func renderPIX(_ pix: PIX, force: Bool = false, completed: (() -> ())? = nil) {
        guard !pix.rendering else {
            log(pix: pix, .warning, .render, "Render in progress...", loop: true)
            return
        }
        pix.needsRender = false
        let renderStartTime = Date()
        let renderStartFrame = frame
        log(pix: pix, .info, .render, "Starting render.\(force ? " Forced." : "")", loop: true)
        do {
            try render(pix, force: force, completed: { texture in
                let renderTime = -renderStartTime.timeIntervalSinceNow
                let renderTimeMs = Int(round(renderTime * 1000))
                let renderFrames = self.frame - renderStartFrame
                self.log(pix: pix, .info, .render, "Render successful!\(force ? " Forced." : "") [\(renderFrames):\(renderTimeMs)ms]", loop: true)
                pix.didRender(texture: texture, force: force)
                completed?()
            }, failed: { error in
                self.log(pix: pix, .error, .render, "Render of shader failed.\(force ? " Forced." : "")", loop: true)//, e: error)
            })
        } catch {
            log(pix: pix, .error, .render, "Render setup failed.\(force ? " Forced." : "")", loop: true, e: error)
        }
    }
    
    enum RenderError: Error {
        case commandBuffer
        case texture(String)
        case custom(String)
        case drawable(String)
        case commandEncoder
        case uniformsBuffer
        case vertecies
        case vertexTexture
    }
    
    func render(_ pix: PIX, force: Bool, completed: @escaping (MTLTexture) -> (), failed: @escaping (Error) -> ()) throws {

//        if #available(iOS 11.0, *) {
//            let sharedCaptureManager = MTLCaptureManager.shared()
//            let myCaptureScope = sharedCaptureManager.makeCaptureScope(device: metalDevice)
//            myCaptureScope.label = "Pixels GPU Capture Scope"
//            sharedCaptureManager.defaultCaptureScope = myCaptureScope
//            myCaptureScope.begin()
//        }
        
        // MARK: Command Buffer
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw RenderError.commandBuffer
        }
        
        // MARK: Input Texture
        
        let generator: Bool = pix is PIXGenerator
        let (inputTexture, secondInputTexture) = try textures(from: pix, with: commandBuffer)
        
        // MARK: Drawable
        
        var viewDrawable: CAMetalDrawable? = nil
        let drawableTexture: MTLTexture
        if pix.view.superview != nil {
            guard let currentDrawable: CAMetalDrawable = pix.view.metalView.currentDrawable else {
                throw RenderError.drawable("Current Drawable not found.")
            }
            viewDrawable = currentDrawable
            drawableTexture = currentDrawable.texture
        } else {
            guard let res = pix.resolution else {
                throw RenderError.drawable("PIX Resolution not set.")
            }
            drawableTexture = try emptyTexture(size: res.size)
        }
        
        let drawRes = PIX.Res(texture: drawableTexture)
        if (drawRes >= ._16384) != false {
            log(pix: pix, .warning, .render, "Epic res: \(drawRes)")
        } else if (drawRes >= ._8192) != false {
            log(pix: pix, .warning, .render, "Extreme res: \(drawRes)")
        } else if (drawRes >= ._4096) != false {
            log(pix: pix, .warning, .render, "High res: \(drawRes)")
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
        
        // MARK: Uniforms
        
        var unifroms: [Float] = pix.uniforms.map { uniform -> Float in return Float(uniform) }
        if let genPix = pix as? PIXGenerator {
            unifroms.append(genPix.premultiply ? 1 : 0)
        }
        if let mergerEffectPix = pix as? PIXMergerEffect {
            unifroms.append(Float(mergerEffectPix.fillMode.index))
        }
        if pix.shaderNeedsAspect {
            unifroms.append(Float(drawableTexture.width) / Float(drawableTexture.height))
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
        
        // MARK: Fragment Texture
        
        if !generator {
            commandEncoder.setFragmentTexture(inputTexture!, index: 0)
        }
        
        if secondInputTexture != nil {
            commandEncoder.setFragmentTexture(secondInputTexture!, index: 1)
        }
        
        commandEncoder.setFragmentSamplerState(pix.sampler, index: 0)
        
        // MARK: Vertecies
        
        let vertecies: Vertecies
        if pix.customGeometryActive {
            guard let customVertecies = pix.customGeometryDelegate?.customVertecies() else {
                commandEncoder.endEncoding()
                throw RenderError.vertecies
            }
            vertecies = customVertecies
        } else {
            vertecies = quadVertecis
        }
        
        if vertecies.wireframe {
            commandEncoder.setTriangleFillMode(.lines)
        }

        commandEncoder.setVertexBuffer(vertecies.buffer, offset: 0, index: 0)
        
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
        
        // MARK: Custom Vertex Texture
        
        if pix.customVertexTextureActive {
            
            guard let vtxPixInTexture = pix.customVertexPixIn?.texture else {
                commandEncoder.endEncoding()
                throw RenderError.vertexTexture
            }
            
            commandEncoder.setVertexTexture(vtxPixInTexture, index: 0)
            
            let sampler = try makeSampler(interpolate: .linear, extend: .clampToEdge)
            commandEncoder.setVertexSamplerState(pix.sampler, index: 0)
            
        }
        
        // MARK: Draw
        
        commandEncoder.drawPrimitives(type: vertecies.type, vertexStart: 0, vertexCount: vertecies.vertexCount, instanceCount: vertecies.instanceCount)
        
        // MARK: Render
        
        commandEncoder.endEncoding()
        
        pix.rendering = true
        
        if viewDrawable != nil {
            commandBuffer.present(viewDrawable!)
        }
        
        commandBuffer.addCompletedHandler({ _ in
            pix.rendering = false
            if let error = commandBuffer.error {
                failed(error)
                return
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
