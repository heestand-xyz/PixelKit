//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct StarPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Star"
    public var typeName: String = "pix-content-generator-star"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    public var premultiply: Bool = true
    public var resolution: Resolution = .auto

    public var backgroundColor: PixelColor = .black
    public var color: PixelColor = .white
    
    // MARK: Local
    
    public var position: CGPoint = .zero
    public var leadingRadius: CGFloat = 0.25
    public var trailingRadius: CGFloat = 0.125
    public var rotation: CGFloat = 0.0
    public var count: Int = 5
    public var cornerRadius: CGFloat = 0.0
    
}

extension StarPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case position
        case leadingRadius
        case trailingRadius
        case rotation
        case count
        case cornerRadius
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .leadingRadius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    leadingRadius = live.wrappedValue
                case .trailingRadius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    trailingRadius = live.wrappedValue
                case .rotation:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    rotation = live.wrappedValue
                case .count:
                    guard let live = liveWrap as? LiveInt else { continue }
                    count = live.wrappedValue
                case .cornerRadius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cornerRadius = live.wrappedValue
                }
            }
            return
        }
        
        position = try container.decode(CGPoint.self, forKey: .position)
        leadingRadius = try container.decode(CGFloat.self, forKey: .leadingRadius)
        trailingRadius = try container.decode(CGFloat.self, forKey: .trailingRadius)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        count = try container.decode(Int.self, forKey: .count)
        cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
    }
}

