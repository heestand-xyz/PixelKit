//
//  PIXSprite.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import SpriteKit

open class PIXSprite: PIXContent {
    
    override open var shader: String { return "nilFlipPIX" }
    
    public var res: Res { didSet { setup(); applyRes { self.setNeedsRender() } } }
    
    public var bgColor: UIColor = .black {
        didSet {
            scene.backgroundColor = bgColor
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
        scene = SKScene(size: res.size)
        scene.backgroundColor = bgColor
        sceneView = SKView(frame: CGRect(x: 0, y: 0, width: res.width, height: res.height))
        sceneView.allowsTransparency = true
        sceneView.presentScene(scene)
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
