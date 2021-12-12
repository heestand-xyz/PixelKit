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
    
    override open var shaderName: String { return "spritePIX" }
    
    // MARK: - Public Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128 { didSet { reSize(); applyResolution { [weak self] in self?.render() } } }
    
    @available(*, deprecated, renamed: "backgroundColor")
    public var bgColor: PixelColor {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    public var backgroundColor: PixelColor = .black {
        didSet {
            #if os(macOS)
            scene?.backgroundColor = backgroundColor.nsColor
            #else
            scene?.backgroundColor = backgroundColor.uiColor
            #endif
            render()
        }
    }
    
    var scene: SKScene?
    var sceneView: SKView?
    
    open override var liveList: [LiveWrap] {
        [_resolution] + super.liveList
    }
    
    required public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        fatalError("Please use PIXSprite Sub Classes.")
    }
        
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render), name: String, typeName: String) {
        self.resolution = resolution
        super.init(name: name, typeName: typeName)
        setupSprite()
    }
    
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
    
    func reSize() {
        let size = (resolution / Resolution.scale).size
        scene?.size = size
        sceneView?.frame = CGRect(origin: .zero, size: size)
    }
    
}
