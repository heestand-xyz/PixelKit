//
//  ScenePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import SceneKit

public class ScenePIX: PIXCustom {
    
    // MARK: - Private Properties
    
    var renderer: SCNRenderer!
    var sceneHelper: SceneHelper!
    
    // MARK: - Public Properties
    
    public var scene: SCNScene?
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
    
    public required init(res: Resolution = .auto) {
        
        super.init(res: res)
        
        renderer = SCNRenderer(device: pixelKit.metalDevice, options: nil)
        
        sceneHelper = SceneHelper(render: {
            self.setNeedsRender()
        })
        
    }
    
    public func render() {
        guard customDelegateRender else {
            pixelKit.logger.log(node: self, .warning, nil, "customDelegateRender not enabled.")
            return
        }
        self.setNeedsRender()
    }
    
    public override func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        guard let scene = scene else {
            pixelKit.logger.log(node: self, .warning, nil, "Scene not found.")
            return nil
        }
        guard let sceneView = sceneView else {
            pixelKit.logger.log(node: self, .warning, nil, "Scene View not found.")
            return  nil
        }
        
        let viewport = CGRect(x: 0, y: 0, width: res.width.cg, height: res.height.cg)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(Double(bgColor.r.cg), Double(bgColor.g.cg), Double(bgColor.b.cg), Double(bgColor.a.cg))
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderer.scene = scene
        renderer.pointOfView = sceneView.pointOfView
        renderer.render(atTime: 0, viewport: viewport, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)

        return texture
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
