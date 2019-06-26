//
//  TextPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//

import CoreGraphics
import SpriteKit

public class TextPIX: PIXSprite {
    
    // MARK: - Private Properties
    
    let label: SKLabelNode
    
    // MARK: - Public Properties
    
    public var text: String = "Lorem Ipsum" { didSet { setNeedsText(); setNeedsRender() } }
    public var color: _Color = .white { didSet { setNeedsTextColor(); setNeedsRender() } }
    
    #if os(iOS)
    typealias _Font = UIFont
    public var font: UIFont = _Font.systemFont(ofSize: 100, weight: .regular) { didSet { setNeedsFont(); setNeedsRender() } }
    #elseif os(macOS)
    typealias _Font = NSFont
    public var font: NSFont = _Font.systemFont(ofSize: 100, weight: .regular) { didSet { setNeedsFont(); setNeedsRender() } }
    #endif
    
    public var position: CGPoint = .zero { didSet { setNeedsPosition(); setNeedsRender() } }
//    public var fontWeight: CGFloat = 1.0 { didSet { setNeedsFont(); setNeedsRender() } }
//    public var fontSize: CGFloat = 100.0 { didSet { setNeedsFont(); setNeedsRender() } }
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case text; case textColor; case font; case position
//    }
//    enum FontCodingKeys: String, CodingKey {
//        case name; case size
//    }
    
    // MARK: - Life Cycle
    
    public required init(res: Res) {
        
        label = SKLabelNode()
        
        super.init(res: res)
        
        label.verticalAlignmentMode = .center
        if #available(iOS 11, *) {
            if #available(OSX 10.13, *) {
                label.numberOfLines = 0
            }
        }
        
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()

        scene.addChild(label)
        
        setNeedsRender()
        
    }
    
    override func reSize() {
        super.reSize()
        
        
    }
    
//    // MARK: - Render
//
//    override public func setNeedsRender() {
//        setNeedsText()
//        setNeedsTextColor()
//        setNeedsFont()
//        setNeedsPosition()
//        super.setNeedsRender()
//    }
    
    // MARK: - Methods
    
    func setNeedsText() {
        label.text = text
    }
    
    func setNeedsTextColor() {
        label.fontColor = color//._color
    }
    
    func setNeedsFont() {
        
        label.fontName = font.fontName // CHECK family
        
//        #if os(iOS)
//        let fontSize = font.pointSize * UIScreen.main.nativeScale // CHECK weight
//        #elseif os(macOS)
//        let fontSize = font.pointSize
//        #endif
        label.fontSize = font.pointSize
        
        // setPosition...
        
    }
    
    func setNeedsPosition() {
        let pos = CGPoint(x: position.x * scene.size.height,
                          y: position.y * scene.size.height)
        label.position = CGPoint(x: scene.size.width / 2 + pos.x,
                                 y: scene.size.height / 2 + pos.y)
    }
    
}
