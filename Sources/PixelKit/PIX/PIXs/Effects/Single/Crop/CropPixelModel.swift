//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct CropPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Crop"
    public var typeName: String = "pix-effect-single-crop"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var cropLeft: CGFloat = 0.0
    public var cropRight: CGFloat = 1.0
    public var cropBottom: CGFloat = 0.0
    public var cropTop: CGFloat = 1.0
}

extension CropPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case cropLeft
        case cropRight
        case cropBottom
        case cropTop
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .cropLeft:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cropLeft = live.wrappedValue
                case .cropRight:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cropRight = live.wrappedValue
                case .cropBottom:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cropBottom = live.wrappedValue
                case .cropTop:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cropTop = live.wrappedValue
                }
            }
            return
        }
        
        cropLeft = try container.decode(CGFloat.self, forKey: .cropLeft)
        cropRight = try container.decode(CGFloat.self, forKey: .cropRight)
        cropBottom = try container.decode(CGFloat.self, forKey: .cropBottom)
        cropTop = try container.decode(CGFloat.self, forKey: .cropTop)
    }
}
