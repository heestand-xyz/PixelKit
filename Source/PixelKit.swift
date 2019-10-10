//
//  PixelKit.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import RenderKit

public class PixelKit: EngineDelegate, LoggerDelegate {
    
    public static let main = PixelKit()
    
    // MARK: Signature
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    let kBundleId = "se.hexagons.pixelkit.macos"
    let kMetalLibName = "PixelKitShaders-macOS"
    #elseif os(iOS)
    let kBundleId = "se.hexagons.pixelkit"
    #if targetEnvironment(simulator)
    let kMetalLibName = "PixelKitShaders-Simulator"
    #else
    let kMetalLibName = "PixelKitShaders"
    #endif
    #elseif os(tvOS)
    let kBundleId = "se.hexagons.pixelkit.tvos"
    #if targetEnvironment(simulator)
    let kMetalLibName = "PixelKitShaders-tvOS-Simulator"
    #else
    let kMetalLibName = "PixelKitShaders-tvOS"
    #endif
    #endif
    
    public let render: Render
    let logger: Logger

    init() {
        
        render = Render(with: kMetalLibName, in: Bundle(for: type(of: self)))
        logger = Logger(name: "PixelKit")
        
        render.engine.deleagte = self
        logger.delegate = self
        
    }
    
    // MARK: - Logger Delegate
    
    public func loggerFrameIndex() -> Int {
        render.frame
    }
    
    public func loggerLinkIndex(of node: NODE) -> Int? {
        render.linkIndex(of: node)
    }
    
    // MARK: - Texture
    
    public func textures(from node: NODE, with commandBuffer: MTLCommandBuffer) throws -> (a: MTLTexture?, b: MTLTexture?, custom: MTLTexture?) {

        var generator: Bool = false
        var custom: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let nodeContent = node as? NODEContent {
            if let nodeResource = nodeContent as? NODEResource {
                guard let pixelBuffer = nodeResource.pixelBuffer else {
                    throw Engine.RenderError.texture("Pixel Buffer is nil.")
                }
                let force8bit: Bool
                #if os(tvOS)
                force8bit = false
                #else
                force8bit = (node as? CameraPIX) != nil
                #endif
                inputTexture = try Texture.makeTexture(from: pixelBuffer, with: commandBuffer, force8bit: force8bit, on: render.metalDevice)
            } else if nodeContent is NODEGenerator {
                generator = true
            } else if let nodeSprite = nodeContent as? PIXSprite {
                guard let spriteTexture = nodeSprite.sceneView.texture(from: nodeSprite.scene) else {
                    throw Engine.RenderError.texture("Sprite Texture fail.")
                }
                let spriteImage: CGImage = spriteTexture.cgImage()
                guard let spriteBuffer = Texture.buffer(from: spriteImage, at: nodeSprite.resolution.size.cg) else {
                    throw Engine.RenderError.texture("Sprite Buffer fail.")
                }
                inputTexture = try Texture.makeTexture(from: spriteBuffer, with: commandBuffer, on: render.metalDevice)
            } else if nodeContent is NODECustom {
                custom = true
            }
        } else if let nodeIn = node as? NODE & NODEInIO {
            if let nodeInMulti = nodeIn as? NODEInMulti {
                var inTextures: [MTLTexture] = []
                for (i, nodeOut) in nodeInMulti.inputs.enumerated() {
                    guard let nodeOutTexture = nodeOut.texture else {
                        throw Engine.RenderError.texture("IO Texture \(i) not found for: \(nodeOut)")
                    }
                    try Texture.mipmap(texture: nodeOutTexture, with: commandBuffer)
                    inTextures.append(nodeOutTexture)
                }
                inputTexture = try Texture.makeMultiTexture(from: inTextures, with: commandBuffer, on: render.metalDevice)
            } else {
                guard let nodeOut = nodeIn.inputList.first else {
                    throw Engine.RenderError.texture("input not connected.")
                }
                var feed = false
                if let feedbackNode = nodeIn as? FeedbackPIX {
                    if feedbackNode.readyToFeed && feedbackNode.feedActive {
                        guard let feedTexture = feedbackNode.feedTexture else {
                            throw Engine.RenderError.texture("Feed Texture not avalible.")
                        }
                        inputTexture = feedTexture
                        feed = true
                    }
                }
                if !feed {
                    guard let nodeOutTexture = nodeOut.texture else {
                        throw Engine.RenderError.texture("IO Texture not found for: \(nodeOut)")
                    }
                    inputTexture = nodeOutTexture // CHECK copy?
                    if node is NODEInMerger {
                        let nodeOutB = nodeIn.inputList[1]
                        guard let nodeOutTextureB = nodeOutB.texture else {
                            throw Engine.RenderError.texture("IO Texture B not found for: \(nodeOutB)")
                        }
                        secondInputTexture = nodeOutTextureB // CHECK copy?
                    }
                }
            }
        }

        guard generator || custom || inputTexture != nil else {
            throw Engine.RenderError.texture("Input Texture missing.")
        }

        if custom {
            return (nil, nil, nil)
        }

        // Mipmap

        if inputTexture != nil {
            try Texture.mipmap(texture: inputTexture!, with: commandBuffer)
        }
        if secondInputTexture != nil {
            try Texture.mipmap(texture: secondInputTexture!, with: commandBuffer)
        }

        // MARK: Custom Render

        var customTexture: MTLTexture?
        if !generator && node.customRenderActive {
            guard let customRenderDelegate = node.customRenderDelegate else {
                throw Engine.RenderError.custom("CustomRenderDelegate not implemented.")
            }
            if let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) {
                inputTexture = nil
                customTexture = customRenderedTexture
            }
        }

        if node is NODEInMerger {
            if !generator && node.customMergerRenderActive {
                guard let customMergerRenderDelegate = node.customMergerRenderDelegate else {
                    throw Engine.RenderError.custom("PixelCustomMergerRenderDelegate not implemented.")
                }
                let customRenderedTextures = customMergerRenderDelegate.customRender(a: inputTexture!, b: secondInputTexture!, with: commandBuffer)
                if let customRenderedTexture = customRenderedTextures {
                    inputTexture = nil
                    secondInputTexture = nil
                    customTexture = customRenderedTexture
                }
            }
        }

        if let timeMachineNode = node as? TimeMachinePIX {
            let textures = timeMachineNode.customRender(inputTexture!, with: commandBuffer)
            inputTexture = try Texture.makeMultiTexture(from: textures, with: commandBuffer, on: render.metalDevice, in3D: true)
        }

        return (inputTexture, secondInputTexture, customTexture)

    }

}
