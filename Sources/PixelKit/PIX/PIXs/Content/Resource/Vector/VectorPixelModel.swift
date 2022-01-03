//
//  Created by Anton Heestand on 2022-01-03.
//

#if !os(tvOS)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct VectorPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Vector"
    public var typeName: String = "pix-content-resource-vector"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
    public var scale: CGFloat = 1.0
    public var position: CGPoint = .zero
    public var backgroundColor: PixelColor = .black
}

extension VectorPixelModel {
        
    enum CodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case scale
        case position
        case backgroundColor
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    resolution = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        scale = try container.decode(CGFloat.self, forKey: .scale)
        position = try container.decode(CGPoint.self, forKey: .position)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)

    }
    
}

#endif
