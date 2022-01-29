//
//  PIXSprite.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-28.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import SpriteKit
import PixelColor

open class PIXSprite: PIXContent, NODEResolution {
    
    public var spriteModel: PixelSpriteModel {
        get { contentModel as! PixelSpriteModel }
        set { contentModel = newValue }
    }
    
    override open var shaderName: String { "spritePix" }
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128 { didSet { reSize(); applyResolution { [weak self] in self?.render() } } }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    public var backgroundColor: PixelColor {
        get { spriteModel.backgroundColor }
        set {
            spriteModel.backgroundColor = newValue
            #if os(macOS)
            scene?.backgroundColor = newValue.nsColor
            #else
            scene?.backgroundColor = newValue.uiColor
            #endif
            render()
        }
    }
    
    var scene: SKScene?
    var sceneView: SKView?
    
    open override var liveList: [LiveWrap] {
        [_resolution] + super.liveList
    }
    
    // MARK: - Life Cycle -
    
    public init(model: PixelSpriteModel) {
        self.resolution = model.resolution
        super.init(model: model)
        setupSprite()
    }
    
    public required init(at resolution: Resolution) {
        fatalError("please use init(model:)")
    }
    
    // MARK: - Setup
    
    func setupSprite() {
        let size = (resolution / Resolution.scale).size
        scene = SKScene(size: size)
        #if os(macOS)
        scene!.backgroundColor = backgroundColor.nsColor
        #else
        scene!.backgroundColor = backgroundColor.uiColor
        #endif
        sceneView = SKView(frame: CGRect(origin: .zero, size: size))
        sceneView!.allowsTransparency = true
        sceneView!.presentScene(scene!)
        applyResolution { [weak self] in
            self?.render()
        }
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = spriteModel.resolution
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        spriteModel.resolution = resolution
    }
    
    // MARK: - Size
    
    func reSize() {
        let size = (resolution / Resolution.scale).size
        scene?.size = size
        sceneView?.frame = CGRect(origin: .zero, size: size)
    }
    
}
