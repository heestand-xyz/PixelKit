//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct PolygonPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Polygon"
    public var typeName: String = "pix-content-generator-polygon"
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
    
    public var radius: CGFloat = 0.25
    public var position: CGPoint = .zero
    public var rotation: CGFloat = 0.0
    public var count: Int = 3
    public var cornerRadius: CGFloat = 0.0
}

extension PolygonPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case radius
        case position
        case rotation
        case count
        case cornerRadius
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .radius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    radius = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
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
        
        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        rotation = try container.decode(CGFloat.self, forKey: .rotation)
        count = try container.decode(Int.self, forKey: .count)
        cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
    }
}

extension PolygonPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelGeneratorEqual(to: pixelModel) else { return false }
        guard radius == pixelModel.radius else { return false }
        guard position == pixelModel.position else { return false }
        guard rotation == pixelModel.rotation else { return false }
        guard count == pixelModel.count else { return false }
        guard cornerRadius == pixelModel.cornerRadius else { return false }
        return true
    }
}
