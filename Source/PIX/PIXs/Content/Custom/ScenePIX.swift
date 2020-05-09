//
//  ScenePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import RenderKit
import SceneKit

public class ScenePIX: PIXCustom {
    
    // MARK: - Private Properties
    
    var renderer: SCNRenderer!
    var sceneHelper: SceneHelper!
    
    // MARK: - Public Properties
    
    public var cameraNode: SCNNode? {
        didSet {
            renderer.pointOfView = cameraNode //sceneView.pointOfView
        }
    }
    public var scene: SCNScene? {
        didSet {
            renderer.scene = scene
        }
    }
    public var sceneView: SCNView? {
        didSet {
            sceneView?.isPlaying = true
            guard !customDelegateRender else { return }
            sceneView?.delegate = sceneHelper
        }
    }
    
    /// if true the scene view delegate will no be highjacked. please call render().
    public var customDelegateRender: Bool = false
    
    // MARK: - Property Helpers
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        
        super.init(at: resolution, name: "Scene", typeName: "pix-content-custom-scene")
        
        renderer = SCNRenderer(device: pixelKit.render.metalDevice, options: nil)
        renderer.autoenablesDefaultLighting = true
//        renderer.isJitteringEnabled = true
        
        sceneHelper = SceneHelper(render: {
            guard !self.customDelegateRender else { return }
            self.setNeedsRender()
        })
        
    }
    
    public func setup(cameraNode: SCNNode, scene: SCNScene, sceneView: SCNView) {
        self.cameraNode = cameraNode
        self.scene = scene
        self.sceneView = sceneView
        setNeedsRender()
    }
    
    public func render() {
        guard customDelegateRender else {
            pixelKit.logger.log(node: self, .warning, nil, "customDelegateRender not enabled.")
            return
        }
        self.setNeedsRender()
    }
    
    public override func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {

        guard let customTexture: MTLTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: pixelKit.render.bits, on: pixelKit.render.metalDevice) else {
            pixelKit.logger.log(node: self, .error, .generator, "Make of empty texture faild.")
            return nil
        }
        
        let viewport = CGRect(x: 0, y: 0, width: resolution.width.cg, height: resolution.height.cg)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = customTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(Double(bgColor.r.cg), Double(bgColor.g.cg), Double(bgColor.b.cg), Double(bgColor.a.cg))
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderer.render(atTime: 0, viewport: viewport, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)
        
        return customTexture
    }
    
}

class SceneHelper: NSObject, SCNSceneRendererDelegate {
    
    let renderCallback: () -> ()
    
    init(render: @escaping () -> ()) {
        renderCallback = render
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        renderCallback()
    }
    
}
