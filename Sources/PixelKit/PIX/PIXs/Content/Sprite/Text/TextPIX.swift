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

#if os(macOS)
public typealias _Font = NSFont
#else
public typealias _Font = UIFont
#endif

final public class TextPIX: PIXSprite, PIXViewable {
    
    public typealias Model = TextPixelModel
    
    private var model: Model {
        get { spriteModel as! Model }
        set { spriteModel = newValue }
    }
    
    // MARK: - Private Properties
    
    let label: SKLabelNode = .init()
    
    // MARK: - Public Properties
    
    public var text: String {
        get { model.text }
        set {
            model.text = newValue
            setNeedsText()
            render()
        }
    }
    @LiveColor("color") public var color: PixelColor = .white
    
    public enum FontWeight: String, Enumable {
        
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
        
        public var index: Int {
            Self.allCases.firstIndex(of: self) ?? 0
        }
        
        public var typeName: String { rawValue }
        
        public var name: String {
            switch self {
            case .ultraLight:
                return "Ultra Light"
            case .thin:
                return "Thin"
            case .light:
                return "Light"
            case .regular:
                return "Regular"
            case .medium:
                return "Medium"
            case .semibold:
                return "Semibold"
            case .bold:
                return "Bold"
            case .heavy:
                return "Heavy"
            case .black:
                return "Black"
            }
        }
        
        var weight: _Font.Weight {
            switch self {
            case .ultraLight:
                return .ultraLight
            case .thin:
                return .thin
            case .light:
                return .light
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            case .heavy:
                return .heavy
            case.black:
                return .black
            }
        }
    }
    
    public var customFont: _Font?
    public var font: _Font { customFont ?? (fontName != nil ? (_Font(name: "\(fontName!)-\(fontWeight.name)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: fontWeight.weight)) : .systemFont(ofSize: fontSize, weight: fontWeight.weight)) }
    
    public var fontName: String? {
        get { model.fontName }
        set {
            model.fontName = newValue
            setNeedsFont()
            render()
        }
    }
    
    @LiveEnum("fontWeight") public var fontWeight: FontWeight = .regular
    @LiveFloat("fontSize") public var fontSize: CGFloat = 0.25

    @LivePoint("position") public var position: CGPoint = .zero
    
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
    
    public convenience init(at resolution: Resolution = .auto,
                            text: String) {
        self.init(at: resolution)
        self.text = text
        setNeedsText()
        render()
    }
    
    // MARK: - Setup
    
    func setup() {
        
        _color.didSetValue = { [weak self] in
            self?.setNeedsTextColor()
            self?.render()
        }
        
        _fontWeight.didSetValue = { [weak self] in
            self?.setNeedsFont()
            self?.render()
        }
        
        _fontSize.didSetValue = { [weak self] in
            self?.setNeedsFont()
            self?.render()
        }
        
        _position.didSetValue = { [weak self] in
            self?.setNeedsPosition()
            self?.render()
        }
        
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
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        color = model.color
        fontWeight = model.fontWeight
        fontSize = model.fontSize
        position = model.position
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.color = color
        model.fontWeight = fontWeight
        model.fontSize = fontSize
        model.position = position
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Size
    
    override func reSize() {
        super.reSize()
        
        setNeedsText()
        setNeedsTextColor()
        setNeedsFont()
        setNeedsPosition()
        
        render()
        
    }
    
    // MARK: - Set Needs
    
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
