//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ColorShiftPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Color Shift"
    public var typeName: String = "pix-effect-single-color-shift"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var hue: CGFloat = 0.0
    public var saturation: CGFloat = 1.0
    public var tintColor: PixelColor = .white
}

extension ColorShiftPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case hue
        case saturation
        case tintColor
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .hue:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    hue = live.wrappedValue
                case .saturation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    saturation = live.wrappedValue
                case .tintColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    tintColor = live.wrappedValue
                }
            }
            return
        }
        
        hue = try container.decode(CGFloat.self, forKey: .hue)
        saturation = try container.decode(CGFloat.self, forKey: .saturation)
        tintColor = try container.decode(PixelColor.self, forKey: .tintColor)
    }
}
