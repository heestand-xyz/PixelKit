//
//  PixelKit.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-20.
//  Open Source - MIT License
//

import MetalKit
import RenderKit
import Resolution
import SpriteKit
import TextureMap

/// overrides the default metal lib
public var pixelKitMetalLibURL: URL?

/// PixelKit
///
/// Access via singleton ``main``.
public class PixelKit: EngineDelegate, LoggerDelegate {
    
    /// Singleton of PixelKit
    public static let main = PixelKit()
    
    // MARK: - Resolution
    
    public var tileResolution: Resolution = .square(32)
    public var fallbackResolution: Resolution
    
    // MARK: - Renderer
    
    /// Render
    public let render: Render
    public let logger: Logger
    
    // MARK: - Date
    
    let startDate: Date = .init()
    
    // MARK: - Life Cycle -
    
    init() {
        
        render = Render()
        logger = Logger(name: "PixelKit")
        
        fallbackResolution = .auto(render: render)
        
        render.engine.deleagte = self
        logger.delegate = self
        
//        logger.log(.info, .pixelKit, "PixelKit Ready to Render")
        
    }
    
    // MARK: - Logger
    
    public func loggerFrameIndex() -> Int {
        render.frameIndex
    }
    
    public func loggerLinkIndex(of node: NODE) -> Int? {
        render.linkIndex(of: node)
    }
    
    public func logAll(padding: Bool = false) {
        logger.logAll(padding: padding)
        render.logger.logAll(padding: padding)
        render.engine.logger.logAll(padding: padding)
    }
    
    public func logDebug(padding: Bool = false) {
        logger.logDebug(padding: padding)
        render.logger.logDebug(padding: padding)
        render.engine.logger.logDebug(padding: padding)
    }
    
    public func disableLogging() {
        logger.active = false
        render.logger.active = false
        render.engine.logger.active = false
    }
    
//    public func logLess() {
//        logger.logLess()
//        render.logger.logLess()
//        render.engine.logger.logLess()
//    }
    
    // MARK: - Texture
    
    public func textures(from node: NODE, with commandBuffer: MTLCommandBuffer) throws -> (a: MTLTexture?, b: MTLTexture?, custom: MTLTexture?) {

        var generator: Bool = false
        var custom: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let nodeContent = node as? NODEContent {
            if let nodeResource = nodeContent as? NODEResource {
                inputTexture = try nodeResource.getResourceTexture(commandBuffer: commandBuffer)
            } else if nodeContent is NODEGenerator {
                generator = true
            } else if let nodeSprite = nodeContent as? PIXSprite {
                guard let scene = nodeSprite.scene,
                      let sceneView = nodeSprite.sceneView
                else { throw Engine.RenderError.texture("Sprite Scene Not Setup.") }
                guard let spriteTexture: SKTexture = sceneView.texture(from: scene) else {
                    throw Engine.RenderError.texture("Sprite Texture fail.")
                }
                let spriteImage: CGImage = spriteTexture.cgImage()
                inputTexture = try TextureMap.texture(cgImage: spriteImage)
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
                    throw Engine.RenderError.texture("Input not connected.")
                }
                var feed = false
                if let feedbackNode = nodeIn as? FeedbackPIX {
                    if feedbackNode.readyToFeed {
                        if feedbackNode.feedActive {
                            guard let feedTexture = feedbackNode.feedTexture else {
                                throw Engine.RenderError.texture("Feed Texture not available.")
                            }
                            inputTexture = feedTexture
                            feed = true
                        }
//                        else if feedbackNode.clearingFeed {
//                            feedbackNode.willClearFeed()
//                        }
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
    
    public func tileTextures(from node: NODE & NODETileable, at tileIndex: TileIndex, with commandBuffer: MTLCommandBuffer) throws -> (a: MTLTexture?, b: MTLTexture?, custom: MTLTexture?) {

        guard node is NODE & NODETileable2D else {
             throw Engine.RenderError.nodeNotTileable
        }
        
        var generator: Bool = false
        var inputTexture: MTLTexture? = nil
        var secondInputTexture: MTLTexture? = nil
        if let nodeContent = node as? NODEContent {
            if nodeContent is NODEGenerator {
                generator = true
            }
        } else if let nodeIn = node as? NODE & NODEInIO {
            if let nodeInMulti = nodeIn as? NODEInMulti {
                var inTextures: [MTLTexture] = []
                for (i, nodeOut) in nodeInMulti.inputs.enumerated() {
                    guard let nodeOutTileable2d = nodeOut as? NODE & NODETileable2D else {
                         throw Engine.RenderError.nodeNotTileable
                    }
                    guard let nodeOutTexture = nodeOutTileable2d.tileTextures?[tileIndex.y][tileIndex.x] else {
                        throw Engine.RenderError.texture("Tile IO Texture \(i) not found for: \(nodeOut)")
                    }
                    try Texture.mipmap(texture: nodeOutTexture, with: commandBuffer)
                    inTextures.append(nodeOutTexture)
                }
                inputTexture = try Texture.makeMultiTexture(from: inTextures, with: commandBuffer, on: render.metalDevice)
            } else {
                guard let nodeOut = nodeIn.inputList.first else {
                    throw Engine.RenderError.texture("Tile Input not connected.")
                }
                guard let nodeOutTileable2d = nodeOut as? NODE & NODETileable2D else {
                     throw Engine.RenderError.nodeNotTileable
                }
                var feed = false
                if let feedbackNode = nodeIn as? FeedbackPIX {
                    if feedbackNode.readyToFeed {
                        if feedbackNode.feedActive {
                            guard let feedTexture = feedbackNode.tileFeedTexture(at: tileIndex) else {
                                throw Engine.RenderError.texture("Tile Feed Texture not available.")
                            }
                            inputTexture = feedTexture
                            feed = true
                        }
//                        else if feedbackNode.clearingFeed {
//                            feedbackNode.willClearFeed()
//                        }
                    }
                }
                if !feed {
                    guard let nodeOutTexture = nodeOutTileable2d.tileTextures?[tileIndex.y][tileIndex.x] else {
                        throw Engine.RenderError.texture("Tile IO Texture not found for: \(nodeOut)")
                    }
                    inputTexture = nodeOutTexture // CHECK copy?
                    if node is NODEInMerger {
                        let nodeOutB = nodeIn.inputList[1]
                        guard let nodeOutBTileable2d = nodeOutB as? NODE & NODETileable2D else {
                             throw Engine.RenderError.nodeNotTileable
                        }
                        guard let nodeOutTextureB = nodeOutBTileable2d.tileTextures?[tileIndex.y][tileIndex.x] else {
                            throw Engine.RenderError.texture("Tile IO Texture B not found for: \(nodeOutB)")
                        }
                        secondInputTexture = nodeOutTextureB // CHECK copy?
                    }
                }
            }
        }

        guard generator || inputTexture != nil else {
            throw Engine.RenderError.texture("Tile Input Texture missing.")
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
                throw Engine.RenderError.custom("Tile CustomRenderDelegate not implemented.")
            }
            if let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) {
                inputTexture = nil
                customTexture = customRenderedTexture
            }
        }

        if node is NODEInMerger {
            if !generator && node.customMergerRenderActive {
                guard let customMergerRenderDelegate = node.customMergerRenderDelegate else {
                    throw Engine.RenderError.custom("Tile PixelCustomMergerRenderDelegate not implemented.")
                }
                let customRenderedTextures = customMergerRenderDelegate.customRender(a: inputTexture!, b: secondInputTexture!, with: commandBuffer)
                if let customRenderedTexture = customRenderedTextures {
                    inputTexture = nil
                    secondInputTexture = nil
                    customTexture = customRenderedTexture
                }
            }
        }

        if let timeMachineNode = node as? NODETimeMachine {
            let textures = timeMachineNode.customRender(inputTexture!, with: commandBuffer)
            inputTexture = try Texture.makeMultiTexture(from: textures, with: commandBuffer, on: render.metalDevice, in3D: true)
        }

        return (inputTexture, secondInputTexture, customTexture)

    }
    
}
