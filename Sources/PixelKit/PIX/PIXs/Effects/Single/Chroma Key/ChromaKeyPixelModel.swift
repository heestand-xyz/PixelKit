//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ChromaKeyPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Chroma Key"
    public var typeName: String = "pix-effect-single-chroma-key"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var keyColor: PixelColor = .green
    public var range: CGFloat = 0.1
    public var softness: CGFloat = 0.1
    public var edgeDesaturation: CGFloat = 0.5
    public var alphaCrop: CGFloat = 0.5
    public var premultiply: Bool = true
    
}

extension ChromaKeyPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case keyColor
        case range
        case softness
        case edgeDesaturation
        case alphaCrop
        case premultiply
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .keyColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    keyColor = live.wrappedValue
                case .range:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    range = live.wrappedValue
                case .softness:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    softness = live.wrappedValue
                case .edgeDesaturation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    edgeDesaturation = live.wrappedValue
                case .alphaCrop:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    alphaCrop = live.wrappedValue
                case .premultiply:
                    guard let live = liveWrap as? LiveBool else { continue }
                    premultiply = live.wrappedValue
                }
            }
            return
        }
        
        keyColor = try container.decode(PixelColor.self, forKey: .keyColor)
        range = try container.decode(CGFloat.self, forKey: .range)
        softness = try container.decode(CGFloat.self, forKey: .softness)
        edgeDesaturation = try container.decode(CGFloat.self, forKey: .edgeDesaturation)
        alphaCrop = try container.decode(CGFloat.self, forKey: .alphaCrop)
        premultiply = try container.decode(Bool.self, forKey: .premultiply)
    }
}

extension ChromaKeyPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard keyColor == pixelModel.keyColor else { return false }
        guard range == pixelModel.range else { return false }
        guard softness == pixelModel.softness else { return false }
        guard edgeDesaturation == pixelModel.edgeDesaturation else { return false }
        guard alphaCrop == pixelModel.alphaCrop else { return false }
        guard premultiply == pixelModel.premultiply else { return false }
        return true
    }
}
