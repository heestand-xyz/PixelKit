//
//  PIXSprite.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//
import LiveValues
import SpriteKit

open class PIXSprite: PIXContent, PIXRes {
    
    override open var shaderName: String { return "spritePIX" }
    
    // MARK: - Public Properties
    
    public var res: Resolution { didSet { reSize(); applyResolution { self.setNeedsRender() } } }
    
    public var bgColor: LiveColor = .black {
        didSet {
            scene.backgroundColor = bgColor._color
            setNeedsRender()
        }
    }
    
    var scene: SKScene!
    var sceneView: SKView!
    
    required public init(res: Resolution = .auto) {
        self.res = res
        super.init()
        setup()
        applyResolution { self.setNeedsRender() }
    }
    
    func setup() {
        let size = (res / Resolution.scale).size.cg
        scene = SKScene(size: size)
        scene.backgroundColor = bgColor._color
        sceneView = SKView(frame: CGRect(origin: .zero, size: size))
        sceneView.allowsTransparency = true
        sceneView.presentScene(scene)
    }
    
    func reSize() {
        let size = (res / Resolution.scale).size.cg
        scene.size = size
        sceneView.frame = CGRect(origin: .zero, size: size)
    }
    
}
