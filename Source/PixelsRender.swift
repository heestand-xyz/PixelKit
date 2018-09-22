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
        log(pix: pix, .info, .render, "Starting render.\(force ? " Forced." : "")", loop: true)
        do {
            try render(pix, force: force, completed: { texture in
                self.log(pix: pix, .info, .render, "Render successful!\(force ? " Forced." : "")", loop: true)
                pix.didRender(texture: texture, force: force)
                completed?()
            }, failed: { error in
                self.log(pix: pix, .error, .render, "Render fail.\(force ? " Forced." : "")", loop: true)
            })
        } catch {
            log(pix: pix, .error, .render, "Render setup fail.\(force ? " Forced." : "")", loop: true)
        }
    }
    
    enum RenderError: Error {
        case x(String)
        case commandBuffer
        case texture(String)
        case custom(String)
        case drawable(String)
        case commandEncoder
        case uniformsBuffer
        case vertecies
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
        
        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else {
                    throw RenderError.texture("Pixel Buffer is nil.")
                }
                inputTexture = try makeTexture(from: pixelBuffer)
            } else if pixContent is PIXGenerator {
                generator = true
            } else if let pixSprite = pixContent as? PIXSprite {
                guard let spriteTexture = pixSprite.sceneView.texture(from: pixSprite.scene) else {
                    throw RenderError.texture("Sprite Texture fail.")
                }
                let spriteImage = UIImage(cgImage: spriteTexture.cgImage())
                guard let spriteBuffer = buffer(from: spriteImage) else {
                    throw RenderError.texture("Sprite Buffer fail.")
                }
                inputTexture = try makeTexture(from: spriteBuffer)
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            if let pixInMulti = pixIn as? PIXInMulti {
                var inTextures: [MTLTexture] = []
                for (i, pixOut) in pixInMulti.inPixs.enumerated() {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture \(i) not found for: \(pixOut)")
                    }
                    inTextures.append(pixOutTexture)
                }
                inputTexture = try makeMultiTexture(from: inTextures, with: commandBuffer)
            } else {
                guard let pixOut = pixIn.pixInList.first else {
                    throw RenderError.texture("inPix not connected.")
                }
                var feed = false
                if let feedbackPix = pixIn as? FeedbackPIX {
                    if feedbackPix.readyToFeed && feedbackPix.feedActive {
                        if let feedPix = feedbackPix.feedPix {
                            guard let feedTexture = feedPix.texture else {
                                throw RenderError.texture("Feed Texture not found for: \(feedPix)")
                            }
                            inputTexture = feedTexture
                            feed = true
                        }
                    }
                }
                if !feed {
                    guard let pixOutTexture = pixOut.texture else {
                        throw RenderError.texture("IO Texture not found for: \(pixOut)")
                    }
                    inputTexture = pixOutTexture // CHECK copy?
                    if pix is PIXInMerger {
                        let pixOutB = pixIn.pixInList[1]
                        guard let pixOutTextureB = pixOutB.texture else {
                            throw RenderError.texture("IO Texture B not found for: \(pixOutB)")
                        }
                        secondInputTexture = pixOutTextureB // CHECK copy?
                    }
                }
            }
        }
        
        guard generator || inputTexture != nil else {
            throw RenderError.texture("Input Texture missing.")
        }
        
        // MARK: Custom Render
        
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                throw RenderError.custom("PixelsCustomRenderDelegate not implemented.")
            }
            guard let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) else {
                throw RenderError.custom("Custom Render faild.")
            }
            inputTexture = customRenderedTexture
        }
        
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
//            sharedCaptureManager.defaultCaptureScope?.end()
//        }
        
    }
    
}
