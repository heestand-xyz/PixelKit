//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ColorCorrectPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Color Correct"
    public var typeName: String = "pix-effect-single-color-correct"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var whitePoint: PixelColor = .white
    public var vibrance: CGFloat = 0.0
    public var temperature: CGFloat = 0.0
}

extension ColorCorrectPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case whitePoint
        case vibrance
        case temperature
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .whitePoint:
                    guard let live = liveWrap as? LiveColor else { continue }
                    whitePoint = live.wrappedValue
                case .vibrance:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    vibrance = live.wrappedValue
                case .temperature:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    temperature = live.wrappedValue
                }
            }
            return
        }
        
        whitePoint = try container.decode(PixelColor.self, forKey: .whitePoint)
        vibrance = try container.decode(CGFloat.self, forKey: .vibrance)
        temperature = try container.decode(CGFloat.self, forKey: .temperature)
    }
}

extension ColorCorrectPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard whitePoint == pixelModel.whitePoint else { return false }
        guard vibrance == pixelModel.vibrance else { return false }
        guard temperature == pixelModel.temperature else { return false }
        return true
    }
}
