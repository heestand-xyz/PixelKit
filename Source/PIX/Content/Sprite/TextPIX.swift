//
//  TextPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-28.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import SpriteKit

public class TextPIX: PIXSprite, PIXofaKind {
    
    var kind: PIX.Kind = .text
    
    public var text: String = "Pixels" { didSet { setNeedsText(); setNeedsRender() } }
    public var textColor: UIColor = .white { didSet { setNeedsTextColor(); setNeedsRender() } }
    public var font: UIFont = UIFont.systemFont(ofSize: 100) { didSet { setNeedsFont(); setNeedsRender() } }
    public var position: CGPoint = .zero { didSet { setNeedsPosition(); setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case text; case textColor; case font; case position
    }
    enum FontCodingKeys: String, CodingKey {
        case name; case size
    }
    
    let label: SKLabelNode
    
    public override init(res: Res) {
        
        label = SKLabelNode()
        
        super.init(res: res)
        
        label.verticalAlignmentMode = .center
        if #available(iOS 11, *) {
            label.numberOfLines = 0
        }
        
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()

        scene.addChild(label)
        
    }
    
    // MARK: File IO
    
    required convenience init(from decoder: Decoder) throws {
        self.init(res: ._128) // CHECK
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        textColor = try container.decode(Color.self, forKey: .textColor).ui
        let fontContainer = try container.nestedContainer(keyedBy: FontCodingKeys.self, forKey: .font)
        let fontName = try fontContainer.decode(String.self, forKey: .name)
        let fontSize = try fontContainer.decode(CGFloat.self, forKey: .size)
        if let fontFont = UIFont(name: fontName, size: fontSize) {
            pixels.log(pix: self, .error, nil, "Font \"\(fontName)\" from Pixels File is not valid.")
            font = fontFont
        } else {
            font = UIFont.systemFont(ofSize: 100)
        }
        position = try container.decode(CGPoint.self, forKey: .position)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(Color(textColor), forKey: .textColor)
        var fontContainer = container.nestedContainer(keyedBy: FontCodingKeys.self, forKey: .font)
        try fontContainer.encode(font.fontName, forKey: .name)
        try fontContainer.encode(font.pointSize, forKey: .size)
        try container.encode(position, forKey: .position)
    }
    
    // MARK: Render
    
    override public func setNeedsRender() {
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()
        super.setNeedsRender()
    }
    
    // MARK: Methods
    
    func setNeedsText() {
        label.text = text
    }
    
    func setNeedsTextColor() {
        label.fontColor = textColor
    }
    
    func setNeedsFont() {
        label.fontName = font.fontName // CHECK family
        label.fontSize = font.pointSize * UIScreen.main.nativeScale // CHECK weight
        // setPosition...
    }
    
    func setNeedsPosition() {
        label.position = CGPoint(x: scene.size.width / 2 + position.x * scene.size.height, y: scene.size.height / 2 + position.y * scene.size.height)
    }
    
}
