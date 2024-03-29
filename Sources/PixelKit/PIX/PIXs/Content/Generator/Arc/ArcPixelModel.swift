//
//  Created by Anton Heestand on 2021-12-12.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ArcPixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Arc"
    public var typeName: String = "pix-content-generator-arc"
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
    public var angleFrom: CGFloat = -0.125
    public var angleTo: CGFloat = 0.125
    public var angleOffset: CGFloat = 0.0
    public var edgeRadius: CGFloat = 0.0
    public var edgeColor: PixelColor = .gray
}

extension ArcPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case radius
        case position
        case angleFrom
        case angleTo
        case angleOffset
        case edgeRadius
        case edgeColor
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
                case .angleFrom:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    angleFrom = live.wrappedValue
                case .angleTo:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    angleTo = live.wrappedValue
                case .angleOffset:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    angleOffset = live.wrappedValue
                case .edgeRadius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    edgeRadius = live.wrappedValue
                case .edgeColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    edgeColor = live.wrappedValue
                }
            }
            return
        }
        
        radius = try container.decode(CGFloat.self, forKey: .radius)
        position = try container.decode(CGPoint.self, forKey: .position)
        angleFrom = try container.decode(CGFloat.self, forKey: .angleFrom)
        angleTo = try container.decode(CGFloat.self, forKey: .angleTo)
        angleOffset = try container.decode(CGFloat.self, forKey: .angleOffset)
        edgeRadius = try container.decode(CGFloat.self, forKey: .edgeRadius)
        edgeColor = try container.decode(PixelColor.self, forKey: .edgeColor)
    }
}

extension ArcPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelGeneratorEqual(to: pixelModel) else { return false }
        guard radius == pixelModel.radius else { return false }
        guard position == pixelModel.position else { return false }
        guard angleFrom == pixelModel.angleFrom else { return false }
        guard angleTo == pixelModel.angleTo else { return false }
        guard angleOffset == pixelModel.angleOffset else { return false }
        guard edgeRadius == pixelModel.edgeRadius else { return false }
        guard edgeColor == pixelModel.edgeColor else { return false }
        return true
    }
}
