//
//  Texture.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import RenderKit

//public static func textures(from node: N, with commandBuffer: MTLCommandBuffer) throws -> (a: MTLTexture?, b: MTLTexture?, custom: MTLTexture?) {
//
//    var generator: Bool = false
//    var custom: Bool = false
//    var inputTexture: MTLTexture? = nil
//    var secondInputTexture: MTLTexture? = nil
//    if let nodeContent = node as? NODEContent {
//        if let nodeResource = nodeContent as? NODEResource {
//            guard let pixelBuffer = nodeResource.pixelBuffer else {
//                throw RenderError.texture("Pixel Buffer is nil.")
//            }
//            let force8bit: Bool
//            #if os(tvOS)
//            force8bit = false
//            #else
//            force8bit = (node as? CameraNODE) != nil
//            #endif
//            inputTexture = try makeTexture(from: pixelBuffer, with: commandBuffer, force8bit: force8bit)
//        } else if nodeContent is NODEGenerator {
//            generator = true
//        } else if let nodeSprite = nodeContent as? NODESprite {
//            guard let spriteTexture = nodeSprite.sceneView.texture(from: nodeSprite.scene) else {
//                throw RenderError.texture("Sprite Texture fail.")
//            }
//            let spriteImage: CGImage = spriteTexture.cgImage()
//            guard let spriteBuffer = buffer(from: spriteImage, at: nodeSprite.res.size.cg) else {
//                throw RenderError.texture("Sprite Buffer fail.")
//            }
//            inputTexture = try makeTexture(from: spriteBuffer, with: commandBuffer)
//        } else if nodeContent is NODECustom {
//            custom = true
//        }
//    } else if let nodeIn = node as? NODE & NODEInIO {
//        if let nodeInMulti = nodeIn as? NODEInMulti {
//            var inTextures: [MTLTexture] = []
//            for (i, nodeOut) in nodeInMulti.inNodes.enumerated() {
//                guard let nodeOutTexture = nodeOut.texture else {
//                    throw RenderError.texture("IO Texture \(i) not found for: \(nodeOut)")
//                }
//                try mipmap(texture: nodeOutTexture, with: commandBuffer)
//                inTextures.append(nodeOutTexture)
//            }
//            inputTexture = try makeMultiTexture(from: inTextures, with: commandBuffer)
//        } else {
//            guard let nodeOut = nodeIn.nodeInList.first else {
//                throw RenderError.texture("inNode not connected.")
//            }
//            var feed = false
//            if let feedbackNode = nodeIn as? FeedbackNODE {
//                if feedbackNode.readyToFeed && feedbackNode.feedActive {
//                    guard let feedTexture = feedbackNode.feedTexture else {
//                        throw RenderError.texture("Feed Texture not avalible.")
//                    }
//                    inputTexture = feedTexture
//                    feed = true
//                }
//            }
//            if !feed {
//                guard let nodeOutTexture = nodeOut.texture else {
//                    throw RenderError.texture("IO Texture not found for: \(nodeOut)")
//                }
//                inputTexture = nodeOutTexture // CHECK copy?
//                if node is NODEInMerger {
//                    let nodeOutB = nodeIn.nodeInList[1]
//                    guard let nodeOutTextureB = nodeOutB.texture else {
//                        throw RenderError.texture("IO Texture B not found for: \(nodeOutB)")
//                    }
//                    secondInputTexture = nodeOutTextureB // CHECK copy?
//                }
//            }
//        }
//    }
//
//    guard generator || custom || inputTexture != nil else {
//        throw RenderError.texture("Input Texture missing.")
//    }
//
//    if custom {
//        return (nil, nil, nil)
//    }
//
//    // Mipmap
//
//    if inputTexture != nil {
//        try mipmap(texture: inputTexture!, with: commandBuffer)
//    }
//    if secondInputTexture != nil {
//        try mipmap(texture: secondInputTexture!, with: commandBuffer)
//    }
//
//    // MARK: Custom Render
//
//    var customTexture: MTLTexture?
//    if !generator && node.customRenderActive {
//        guard let customRenderDelegate = node.customRenderDelegate else {
//            throw RenderError.custom("PixelCustomRenderDelegate not implemented.")
//        }
//        if let customRenderedTexture = customRenderDelegate.customRender(inputTexture!, with: commandBuffer) {
//            inputTexture = nil
//            customTexture = customRenderedTexture
//        }
//    }
//
//    if node is NODEInMerger {
//        if !generator && node.customMergerRenderActive {
//            guard let customMergerRenderDelegate = node.customMergerRenderDelegate else {
//                throw RenderError.custom("PixelCustomMergerRenderDelegate not implemented.")
//            }
//            let customRenderedTextures = customMergerRenderDelegate.customRender(a: inputTexture!, b: secondInputTexture!, with: commandBuffer)
//            if let customRenderedTexture = customRenderedTextures {
//                inputTexture = nil
//                secondInputTexture = nil
//                customTexture = customRenderedTexture
//            }
//        }
//    }
//
//    if let timeMachineNode = node as? TimeMachineNODE {
//        let textures = timeMachineNode.customRender(inputTexture!, with: commandBuffer)
//        inputTexture = try makeMultiTexture(from: textures, with: commandBuffer, in3D: true)
//    }
//
//    return (inputTexture, secondInputTexture, customTexture)
//
//}
