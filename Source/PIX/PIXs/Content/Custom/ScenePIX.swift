//
//  ScenePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
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
    
    public var clearRender: Bool = true { didSet { setNeedsRender() } }
    
    public var wireframe: Bool = false {
        didSet {
            renderer.debugOptions = wireframe ? [.renderAsWireframe] : []
            renderer.autoenablesDefaultLighting = !wireframe
            setNeedsRender()
        }
    }

    // MARK: - Property Helpers
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        
        super.init(at: resolution, name: "Scene", typeName: "pix-content-custom-scene")
        
        renderer = SCNRenderer(device: pixelKit.render.metalDevice, options: nil)
        renderer.autoenablesDefaultLighting = true
//        renderer.delegate = sceneHelper
//        renderer.isJitteringEnabled = true
//        if #available(iOS 13.0, *) {
//            renderer.isTemporalAntialiasingEnabled = true
//        }
        
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
        
        pixelKit.logger.log(node: self, .info, .generator, "Custom Render. [cameraNode:\(cameraNode != nil), scene:\(scene != nil), sceneView:\(sceneView != nil)]")

        guard let customTexture: MTLTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: pixelKit.render.bits, on: pixelKit.render.metalDevice) else {
            pixelKit.logger.log(node: self, .error, .generator, "Make of empty texture faild.")
            return nil
        }
        
        if !clearRender {
            
            let viewport = CGRect(x: 0, y: 0, width: resolution.width, height: resolution.height)
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = customTexture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(Double(bgColor.r), Double(bgColor.g), Double(bgColor.b), Double(bgColor.a))
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            renderer.render(atTime: 0, viewport: viewport, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)
            
        }
        
        return customTexture
    }
    
}

class SceneHelper: NSObject, SCNSceneRendererDelegate {
    
    let renderCallback: () -> ()
    
    init(render: @escaping () -> ()) {
        renderCallback = render
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        PixelKit.main.logger.log(.info, nil, "willRenderScene atTime \(time)")
        renderCallback()
    }
    
}
