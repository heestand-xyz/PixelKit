//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct PixelatePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Pixelate"
    public var typeName: String = "pix-effect-single-pixelate"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var style: PixelatePIX.Style = .pixel
    public var position: CGPoint = .zero
    public var radius: CGFloat = 0.5
}

extension PixelatePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case style
        case position
        case radius
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .style:
                    let live: LiveEnum<PixelatePIX.Style> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    style = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .radius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    radius = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(PixelatePIX.Style.self, forKey: .style)
        position = try container.decode(CGPoint.self, forKey: .position)
        radius = try container.decode(CGFloat.self, forKey: .radius)
    }
}

extension PixelatePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard style == pixelModel.style else { return false }
        guard position == pixelModel.position else { return false }
        guard radius == pixelModel.radius else { return false }
        return true
    }
}
