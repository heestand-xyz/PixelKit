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
import CoreGraphicsExtensions

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
    
    public enum FontWeight: String, Enumable {
        
        case thin
        case ultraLight
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
            case .thin:
                return "Thin"
            case .ultraLight:
                return "Ultra Light"
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
            case .thin:
                return .thin
            case .ultraLight:
                return .ultraLight
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
        
        var scale: Int {
            switch self {
            case .thin:
                return 100
            case .ultraLight:
                return 200
            case .light:
                return 300
            case .regular:
                return 400
            case .medium:
                return 500
            case .semibold:
                return 600
            case .bold:
                return 700
            case .heavy:
                return 800
            case .black:
                return 900
            }
        }
    }
    
    public enum HorizontalAlignment: String, Enumable {
        
        case left
        case center
        case right
        
        public var index: Int {
            switch self {
            case .left:
                return -1
            case .center:
                return 0
            case .right:
                return 1
            }
        }
        
        public var name: String {
            switch self {
            case .left:
                return "Left"
            case .center:
                return "Center"
            case .right:
                return "Right"
            }
        }
        
        public var typeName: String {
            rawValue
        }
    }
    
    public enum VerticalAlignment: String, Enumable {
        
        case top
        case center
//        case baseline
        case bottom
        
        public var index: Int {
            switch self {
            case .top:
                return 1
            case .center:
                return 0
//            case .baseline:
//                return -2
            case .bottom:
                return -1
            }
        }
        
        public var name: String {
            switch self {
            case .top:
                return "Top"
            case .center:
                return "Center"
//            case .baseline:
//                return "Baseline"
            case .bottom:
                return "Bottom"
            }
        }
        
        public var typeName: String {
            rawValue
        }
    }
    
    public var customFont: _Font?
    public var font: _Font {
        if let customFont: _Font = customFont{
            return customFont
        }
        if let fontName = fontName {
            #if os(macOS)
            if let font: _Font = NSFontManager().font(withFamily: fontName, traits: [], weight: fontWeight.scale / 100, size: fontSize) {
                return font
            }
            #else
            if fontWeight == .regular {
                if let font = _Font(name: fontName, size: fontSize) {
                    return font
                }
            } else {
                if let fullFontName =
                    UIFont.fontNames(forFamilyName: fontName).first(where: { fullFontName in
                        fullFontName.lowercased()
                            .contains(fontWeight.name.lowercased())
                    }) {
                    if let font = _Font(name: fullFontName, size: fontSize) {
                        return font
                    }
                }
            }
            #endif
        }
        return .systemFont(ofSize: fontSize, weight: fontWeight.weight)
    }
    
    public var fontName: String? {
        get { model.fontName }
        set {
            model.fontName = newValue
            setNeedsFont()
            render()
        }
    }
    
    @LiveColor("color") public var color: PixelColor = .white
    
    @LiveEnum("fontWeight") public var fontWeight: FontWeight = .regular
    @LiveFloat("fontSize") public var fontSize: CGFloat = 0.15

    @LivePoint("position") public var position: CGPoint = .zero
    
    @LiveEnum("horizontalAlignment") public var horizontalAlignment: HorizontalAlignment = .center
    @LiveEnum("verticalAlignment") public var verticalAlignment: VerticalAlignment = .center
    
    public override var liveList: [LiveWrap] {
        [
            _color,
            _fontWeight,
            _fontSize,
            _position,
            _horizontalAlignment,
            _verticalAlignment,
        ]
    }
    
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
        
        _horizontalAlignment.didSetValue = { [weak self] in
            self?.setNeedsAlignment()
            self?.render()
        }
        
        _verticalAlignment.didSetValue = { [weak self] in
            self?.setNeedsAlignment()
            self?.render()
        }
        
        label.verticalAlignmentMode = .center
        if #available(iOS 11, macOS 10.13, *) {
            label.numberOfLines = 0
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
        let fontSize = fontSize <= 0 ? 0 : font.pointSize * size.height
        label.fontSize = min(max(fontSize, 1), 1000)
    }
    
    func setNeedsPosition() {
        let size: CGSize = (finalResolution / Resolution.scale).size
        let pos = CGPoint(x: position.x * size.height,
                          y: position.y * size.height)
        label.position = CGPoint(x: size.width / 2 + pos.x,
                                 y: size.height / 2 + pos.y)
    }
    
    func setNeedsAlignment() {
        
        label.horizontalAlignmentMode = {
            switch horizontalAlignment {
            case .left:
                return .left
            case .center:
                return .center
            case .right:
                return .right
            }
        }()
        
        label.verticalAlignmentMode = {
            switch verticalAlignment {
            case .top:
                return .top
            case .center:
                return .center
//            case .baseline:
//                return .baseline
            case .bottom:
                return .bottom
            }
        }()
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
