//
//  TextPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-28.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import CoreGraphics
import SpriteKit

public class TextPIX: PIXSprite {
    
    // MARK: - Private Properties
    
    let label: SKLabelNode
    
    // MARK: - Public Properties
    
    public var text: String = "Lorem Ipsum" { didSet { setNeedsText(); setNeedsRender() } }
    public var color: _Color = .white { didSet { setNeedsTextColor(); setNeedsRender() } }
    
    #if os(iOS) || os(tvOS)
    typealias _Font = UIFont
    public var font: UIFont = _Font.systemFont(ofSize: 0.25, weight: .regular) { didSet { setNeedsFont(); setNeedsRender() } }
    #elseif os(macOS)
    typealias _Font = NSFont
    public var font: NSFont = _Font.systemFont(ofSize: 0.25, weight: .regular) { didSet { setNeedsFont(); setNeedsRender() } }
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
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        
        label = SKLabelNode()
        
        super.init(at: resolution)
        
        name = "text"
        
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
        
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()
        
        setNeedsRender()
        
    }
    
    // MARK: - Methods
    
    func setNeedsText() {
        label.text = text
    }
    
    func setNeedsTextColor() {
        label.fontColor = color
    }
    
    func setNeedsFont() {
        let size: CGSize = (renderResolution / Resolution.scale).size.cg
        label.fontName = font.fontName
        let x = font.pointSize * size.height
        label.fontSize = x
    }
    
    func setNeedsPosition() {
        let size: CGSize = (renderResolution / Resolution.scale).size.cg
        let pos = CGPoint(x: position.x * size.height,
                          y: position.y * size.height)
        label.position = CGPoint(x: size.width / 2 + pos.x,
                                 y: size.height / 2 + pos.y)
    }
    
}
