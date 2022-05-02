//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct InstancerPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Instancer"
    public var typeName: String = "pix-effect-multi-instancer"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
    public var blendMode: BlendMode = .add
    public var backgroundColor: PixelColor = .black
    public var instances: [InstancerPIX.Instance] = []
}

extension InstancerPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case blendMode
        case backgroundColor
        case instances
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelMultiEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    resolution = live.wrappedValue
                case .blendMode:
                    let live: LiveEnum<BlendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    blendMode = live.wrappedValue
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    backgroundColor = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        blendMode = try container.decode(BlendMode.self, forKey: .blendMode)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
        instances = try container.decode([InstancerPIX.Instance].self, forKey: .instances)
    }
}

extension InstancerPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMultiEffectEqual(to: pixelModel) else { return false }
        guard resolution == pixelModel.resolution else { return false }
        guard blendMode == pixelModel.blendMode else { return false }
        guard backgroundColor == pixelModel.backgroundColor else { return false }
        guard instances == pixelModel.instances else { return false }
        return true
    }
}
