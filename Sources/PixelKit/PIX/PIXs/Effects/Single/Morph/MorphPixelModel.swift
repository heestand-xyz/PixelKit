//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct MorphPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Morph"
    public var typeName: String = "pix-effect-single-morph"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var style: MorphPIX.Style = .maximum
    public var width: Int = 1
    public var height: Int = 1
}

extension MorphPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case style
        case width
        case height
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
                    let live: LiveEnum<MorphPIX.Style> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    style = live.wrappedValue
                case .width:
                    guard let live = liveWrap as? LiveInt else { continue }
                    width = live.wrappedValue
                case .height:
                    guard let live = liveWrap as? LiveInt else { continue }
                    height = live.wrappedValue
                }
            }
            return
        }
        
        style = try container.decode(MorphPIX.Style.self, forKey: .style)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
    }
}
