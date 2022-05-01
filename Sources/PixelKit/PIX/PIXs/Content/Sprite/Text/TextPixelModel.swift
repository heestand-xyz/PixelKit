//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct TextPixelModel: PixelSpriteModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Text"
    public var typeName: String = "pix-content-sprite-text"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var resolution: Resolution = .auto
    public var backgroundColor: PixelColor = .black
    
    // MARK: Local
    
    public var text: String = "Lorem Ipsum"
    public var fontName: String?
    public var fontWeight: TextPIX.FontWeight = .regular
    public var fontSize: CGFloat = 0.25
    public var color: PixelColor = .white
    public var position: CGPoint = .zero
}

extension TextPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case text
        case fontName
        case fontWeight
        case fontSize
        case color
        case position
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSpriteModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        fontName = try container.decodeIfPresent(String?.self, forKey: .fontName) ?? nil
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)

        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        fontWeight = try container.decode(TextPIX.FontWeight.self, forKey: .fontWeight)
        color = try container.decode(PixelColor.self, forKey: .color)
        position = try container.decode(CGPoint.self, forKey: .position)
    }
}

extension TextPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSpriteEqual(to: pixelModel) else { return false }
        guard text == pixelModel.text else { return false }
        guard fontName == pixelModel.fontName else { return false }
        guard fontWeight == pixelModel.fontWeight else { return false }
        guard fontSize == pixelModel.fontSize else { return false }
        guard color == pixelModel.color else { return false }
        guard position == pixelModel.position else { return false }
        return true
    }
}
