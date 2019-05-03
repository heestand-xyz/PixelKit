//
//  PIXSprite.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//
import CoreGraphics//x
import SpriteKit

open class PIXSprite: PIXContent {
    
    override open var shader: String { return "spritePIX" }
    
    // MARK: - Public Properties
    
    public var res: Res { didSet { setup(); applyRes { self.setNeedsRender() } } }
    
    public var bgColor: LiveColor = .black {
        didSet {
            scene.backgroundColor = bgColor._color
            setNeedsRender()
        }
    }
    
    var scene: SKScene!
    var sceneView: SKView!
    
    init(res: Res) {
        self.res = res
        super.init()
        setup()
        applyRes { self.setNeedsRender() }
    }
    
    func setup() {
        scene = SKScene(size: res.size.cg)
        scene.backgroundColor = bgColor._color
        sceneView = SKView(frame: CGRect(x: 0, y: 0, width: res.width.cg, height: res.height.cg))
        sceneView.allowsTransparency = true
        sceneView.presentScene(scene)
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
    
}
