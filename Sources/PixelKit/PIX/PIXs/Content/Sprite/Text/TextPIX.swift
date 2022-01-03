//
//  TextPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-28.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import CoreGraphics
import SpriteKit
import PixelColor

final public class TextPIX: PIXSprite, PIXViewable {
    
    // MARK: - Private Properties
    
    let label: SKLabelNode = .init()
    
    // MARK: - Public Properties
    
    public var text: String = "Lorem Ipsum" { didSet { setNeedsText(); render() } }
    public var color: PixelColor = .white { didSet { setNeedsTextColor(); render() } }
    
    #if os(iOS) || os(tvOS)
    typealias _Font = UIFont
    public var font: UIFont = _Font.systemFont(ofSize: 0.25, weight: .regular) { didSet { setNeedsFont(); render() } }
    #elseif os(macOS)
    typealias _Font = NSFont
    public var font: NSFont = _Font.systemFont(ofSize: 0.25, weight: .regular) { didSet { setNeedsFont(); render() } }
    #endif
    
    public var position: CGPoint = .zero { didSet { setNeedsPosition(); render() } }
    
    // MARK: - Life Cycle -
    
    public required init(at resolution: Resolution = .auto) {
        super.init(at: resolution, name: "Text", typeName: "pix-content-sprite-text")
        setup()
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            text: String) {
        self.init(at: resolution)
        setup()
        self.text = text
        setNeedsText()
        render()
    }
    
    // MARK: - Codable
    
//    enum CodingKeys: CodingKey {
//        case text
//        case fontName
//        case fontSize
//    }
//    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        text = try container.decode(String.self, forKey: .text)
//        let fontName = try container.decode(String.self, forKey: .fontName)
//        let fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
//        #if os(iOS)
//        font = UIFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
//        #elseif os(macOS)
//        font = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
//        #endif
//        try super.init(from: decoder)
//        setup()
//    }
//    
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(text, forKey: .text)
//        try container.encode(font.fontName, forKey: .fontName)
//        try container.encode(font.pointSize, forKey: .fontSize)
//        try super.encode(to: encoder)
//    }
    
    // MARK: - Setup
    
    func setup() {
        
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

        scene?.addChild(label)
        
        render()
        
    }
    
    override func reSize() {
        super.reSize()
        
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()
        
        render()
        
    }
    
    // MARK: - Methods
    
    func setNeedsText() {
        label.text = text
    }
    
    func setNeedsTextColor() {
        #if os(macOS)
        label.fontColor = color.nsColor
        #else
        label.fontColor = color.uiColor
        #endif
    }
    
    func setNeedsFont() {
        let size: CGSize = (finalResolution / Resolution.scale).size
        label.fontName = font.fontName
        let x = font.pointSize * size.height
        label.fontSize = x
    }
    
    func setNeedsPosition() {
        let size: CGSize = (finalResolution / Resolution.scale).size
        let pos = CGPoint(x: position.x * size.height,
                          y: position.y * size.height)
        label.position = CGPoint(x: size.width / 2 + pos.x,
                                 y: size.height / 2 + pos.y)
    }
    
}

extension TextPIX {
    
    public static func getFontFamilyNames() -> [String] {
        #if os(macOS)
        return NSFontManager.shared.availableFontFamilies
        #else
        return UIFont.familyNames
        #endif
    }
    
    public static func getFontWeights(fontFamilyName: String) -> [String] {
        #if os(macOS)
        return getDefaultFontWeights()
        #else
        return ["Regular"] + UIFont.fontNames(forFamilyName: fontFamilyName).compactMap { fontName in
            let components: [String] = fontName.components(separatedBy: "-")
            guard components.count == 2 else { return nil }
            return components.last!.pascalCaseToTitleCase
        }
        #endif
    }

    public static func getDefaultFontWeights() -> [String] {
        ["Ultra Light", "Thin", "Light", "Regular", "Medium", "Semibold", "Bold", "Heavy", "Black"]
    }
    
    public static func getFontName(fontFamilyName: String, fontWeightName: String) -> String {
        if fontWeightName == "Regular" {
            return fontFamilyName
        }
        return "\(fontFamilyName)-\(fontWeightName)"
    }

}
