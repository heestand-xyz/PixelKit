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
        loop: for pix in pixList {
            if pix.needsRender {
                if let pixIn = pix as? PIX & PIXInIO {
                    let pixOuts = pixIn.pixInList
                    //                        log(pix: pixIn, .warning, .render, "Can't Render: PIX In's inPix is nil.", loop: true)
                    //                        continue
                    //                    }
                    for (i, pixOut) in pixOuts.enumerated() {
                        if pixOut.texture == nil {
                            //                        // CHECK upstream, if connected & rendered
                            //                        log(pix: pix, .info, .render, "Requesting upstream forced render.", loop: true)
                            //                        renderPIX(pixOut, force: true, completed: {
                            //                            self.renderPIX(pix)
                            //                        })
                            log(pix: pix, .warning, .render, "In texture #\(i) not ready.")
                            pix.needsRender = false // CHECK
                            continue loop
                        }
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
    
    func renderPIX(_ pix: PIX, force: Bool = false, completed: (() -> ())? = nil) {
        guard let pixOfAKind = pix as? PIX & PIXofaKind else {
            log(pix: pix, .error, .render, "PIX is not of a Kind.", loop: true)
            return
        }
        guard !pix.rendering else {
            log(pix: pix, .warning, .render, "Render in progress...", loop: true)
            return
        }
        pix.needsRender = false
        if self.render(pixOfAKind, force: force, completed: { texture in
            self.log(pix: pix, .info, .render, "Render successful!\(force ? " Forced." : "")", loop: true)
            pix.rendering = false
            pix.didRender(texture: texture, force: force)
            completed?()
        }, failed: {
            self.log(pix: pix, .error, .render, "Render runtime fail.\(force ? " Forced." : "")", loop: true)
            pix.rendering = false
        }) {
            log(pix: pix, .info, .render, "Starting render.\(force ? " Forced." : "")", loop: true)
            pix.rendering = true
        } else {
            log(pix: pix, .error, .render, "Render setup fail.\(force ? " Forced." : "")", loop: true)
            pix.rendering = false
        }
    }
    
    func render(_ pix: PIX & PIXofaKind, force: Bool, completed: @escaping (MTLTexture) -> (), failed: @escaping () -> ()) -> Bool {
        
        //        if #available(iOS 11.0, *) {
        //            let sharedCaptureManager = MTLCaptureManager.shared()
        //            let myCaptureScope = sharedCaptureManager.makeCaptureScope(device: metalDevice!)
        //            myCaptureScope.label = "Pixels GPU Capture Scope"
        //            sharedCaptureManager.defaultCaptureScope = myCaptureScope
        //            myCaptureScope.begin()
        //        }
        
        guard aLive else {
            log(pix: pix, .error, .metalRender, "Not aLive...")
            return false
        }
        
        //        if self.pixelBuffer == nil && self.uses_source_texture {
        //            AnalyticsAssistant.shared.logERROR("Render canceled: Source Texture is specified & Pixel Buffer is nil.")
        //            return false
        //        }
        
        // MARK: Command Buffer
        
        guard let commandBuffer = commandQueue!.makeCommandBuffer() else {
            log(pix: pix, .error, .metalRender, "Command Buffer: Make faild.")
            return false
        }
        
        // MARK: Input Texture
        
        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let pixContent = pix as? PIXContent {
            if let pixResource = pixContent as? PIXResource {
                guard let pixelBuffer = pixResource.pixelBuffer else {
                    log(pix: pix, .error, .metalRender, "Texture Creation: Pixel Buffer is empty.")
                    return false
                }
                guard let sourceTexture = makeTexture(from: pixelBuffer) else {
                    log(pix: pix, .error, .metalRender, "Texture Creation: Make faild.")
                    return false
                }
                inputTexture = sourceTexture
            } else if pixContent is PIXGenerator {
                generator = true
            }
        } else if let pixIn = pix as? PIX & PIXInIO {
            if let pixInMulti = pixIn as? PIXInMulti {
                var inTextures: [MTLTexture] = []
                for (i, pixOut) in pixInMulti.inPixs.enumerated() {
                    guard let pixOutTexture = pixOut.texture else {
                        log(pix: pix, .error, .metalRender, "IO Texture \(i) not found for: \(pixOut)")
                        return false
                    }
                    inTextures.append(pixOutTexture)
                }
                guard let multiTexture = makeMultiTexture(from: inTextures, with: commandBuffer) else {
                    log(pix: pix, .error, .metalRender, "Multi Texture creation failed.")
                    return false
                }
                inputTexture = multiTexture
            } else {
                guard let pixOut = pixIn.pixInList.first else {
                    log(pix: pix, .error, .metalRender, "inPix not connected.")
                    return false
                }
                var feed = false
                if let feedbackPix = pixIn as? FeedbackPIX {
                    if feedbackPix.readyToFeed && feedbackPix.feedActive {
                        if let feedPix = feedbackPix.feedPix {
                            guard let feedTexture = feedPix.texture else {
                                log(pix: pix, .error, .metalRender, "Feed Texture not found for: \(feedPix)")
                                return false
                            }
                            inputTexture = feedTexture
                            feed = true
                        }
                    }
                }
                if !feed {
                    guard let pixOutTexture = pixOut.texture else {
                        log(pix: pix, .error, .metalRender, "IO Texture not found for: \(pixOut)")
                        return false
                    }
                    inputTexture = pixOutTexture // CHECK copy?
                    if pix is PIXInMerger {
                        let pixOutB = pixIn.pixInList[1]
                        guard let pixOutTextureB = pixOutB.texture else {
                            log(pix: pix, .error, .metalRender, "IO Texture B not found for: \(pixOutB)")
                            return false
                        }
                        secondInputTexture = pixOutTextureB // CHECK copy?
                    }
                }
            }
        }
        
        // MARK: Custom Render
        
        if !generator && pix.customRenderActive {
            guard let customRenderDelegate = pix.customRenderDelegate else {
                log(pix: pix, .error, .metalRender, "CustomRenderDelegate not implemented.")
                return false
            }
            guard let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) else {
                log(pix: pix, .error, .metalRender, "Custom Render faild.")
                return false
            }
            inputTexture = customRenderedTexture
        }
        
        guard generator || inputTexture != nil else {
            log(pix: pix, .error, .metalRender, "Input Texture missing.")
            return false
        }
        
        // MARK: Drawable Texture
        
        var viewDrawable: CAMetalDrawable? = nil
        let drawableTexture: MTLTexture
        if pix.view.superview != nil {
            guard let currentDrawable: CAMetalDrawable = pix.view.metalView.currentDrawable else {
                log(pix: pix, .error, .metalRender, "Current Drawable: Not found.")
                return false
            }
            viewDrawable = currentDrawable
            drawableTexture = currentDrawable.texture
        } else {
            guard let res = pix.resolution else {
                log(pix: pix, .error, .metalRender, "Drawable Textue: Resolution not set.")
                return false
            }
            guard let emptyTexture = emptyTexture(size: res.size) else {
                log(pix: pix, .error, .metalRender, "Drawable Textue: Empty Texture Creation Failed.")
                return false
            }
            drawableTexture = emptyTexture
        }
        
        //        let drawableRes = PIX.Res(texture: drawableTexture)
        //        if (drawableRes > PIX.Res.customRes(w: 16384, h: 16384)) != false {
        //            log(pix: pix, .warning, .metalRender, "Epic res: \(drawableRes)")
        //        } else if (drawableRes > PIX.Res.customRes(w: 8192, h: 8192)) != false {
        //            log(pix: pix, .warning, .metalRender, "Extreme res: \(drawableRes)")
        //        } else if (drawableRes > PIX.Res._4096) != false {
        //            log(pix: pix, .warning, .metalRender, "High res: \(drawableRes)")
        //        }
        
        // MARK: Command Encoder
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawableTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            log(pix: pix, .error, .metalRender, "Command Encoder: Make faild.")
            return false
        }
        commandEncoder.setRenderPipelineState(pix.pipeline!)
        
        // Wireframe Mode
        //        commandEncoder.setTriangleFillMode(.lines)
        
        // MARK: Uniforms
        
        var unifroms: [Float] = pix.uniforms.map { uniform -> Float in return Float(uniform) }
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
                self.log(pix: pix, .error, .metalRender, "Failed.", e: error)
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
        
        return true
        
    }
    
}
