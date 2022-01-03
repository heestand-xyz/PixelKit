//
//  ScenePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-08-30.
//

import RenderKit
import Resolution
import SceneKit

final public class ScenePIX: PIXCustom, PIXViewable {
    
    public typealias Model = ScenePixelModel
    
    private var model: Model {
        get { customModel as! Model }
        set { customModel = newValue }
    }
    
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
    
    public var clearRender: Bool = true { didSet { render() } }
    
    public var wireframe: Bool = false {
        didSet {
            renderer.debugOptions = wireframe ? [.renderAsWireframe] : []
            renderer.autoenablesDefaultLighting = !wireframe
            render()
        }
    }

    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
        setup()
    }

    // MARK: - Setup

    func setup() {
        
        renderer = SCNRenderer(device: PixelKit.main.render.metalDevice, options: nil)
        renderer.autoenablesDefaultLighting = true
        
        sceneHelper = SceneHelper(render: { [weak self] in
            guard self?.customDelegateRender == false else { return }
            self?.render()
        })
        
    }
    
    public func setup(cameraNode: SCNNode, scene: SCNScene, sceneView: SCNView) {
        self.cameraNode = cameraNode
        self.scene = scene
        self.sceneView = sceneView
        render()
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Render
    
    public func renderScene() {
        guard customDelegateRender else {
            PixelKit.main.logger.log(node: self, .warning, nil, "customDelegateRender not enabled.")
            return
        }
        self.render()
    }
    
    public override func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        PixelKit.main.logger.log(node: self, .info, .generator, "Custom Render. [cameraNode:\(cameraNode != nil), scene:\(scene != nil), sceneView:\(sceneView != nil)]")

        guard let customTexture: MTLTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width, height: texture.height), bits: PixelKit.main.render.bits, on: PixelKit.main.render.metalDevice) else {
            PixelKit.main.logger.log(node: self, .error, .generator, "Make of empty texture faild.")
            return nil
        }
        
        if !clearRender {
            
            let viewport = CGRect(x: 0, y: 0, width: resolution.width, height: resolution.height)
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = customTexture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(Double(backgroundColor.red), Double(backgroundColor.green), Double(backgroundColor.blue), Double(backgroundColor.alpha))
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            renderer.render(atTime: 0, viewport: viewport, commandBuffer: commandBuffer, passDescriptor: renderPassDescriptor)
            
        }
        
        return customTexture
    }
    
}
