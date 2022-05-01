//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct EarthPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Earth"
    public var typeName: String = "pix-content-resource-maps"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
    public var mapType: EarthPIX.MapType = .standard
    public var coordinate: CGPoint = .zero
    public var span: CGFloat = 90
    public var showsBuildings: Bool = false
    public var showsPointsOfInterest: Bool = false
    public var darkMode: Bool = false
}

extension EarthPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case mapType
        case coordinate
        case span
        case showsBuildings
        case showsPointsOfInterest
        case darkMode
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    resolution = live.wrappedValue
                case .mapType:
                    let live: LiveEnum<EarthPIX.MapType> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    mapType = live.wrappedValue
                case .coordinate:
                    guard let live = liveWrap as? LivePoint else { continue }
                    coordinate = live.wrappedValue
                case .span:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    span = live.wrappedValue
                case .showsBuildings:
                    guard let live = liveWrap as? LiveBool else { continue }
                    showsBuildings = live.wrappedValue
                case .showsPointsOfInterest:
                    guard let live = liveWrap as? LiveBool else { continue }
                    showsPointsOfInterest = live.wrappedValue
                case .darkMode:
                    guard let live = liveWrap as? LiveBool else { continue }
                    darkMode = live.wrappedValue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        mapType = try container.decode(EarthPIX.MapType.self, forKey: .mapType)
        coordinate = try container.decode(CGPoint.self, forKey: .coordinate)
        span = try container.decode(CGFloat.self, forKey: .span)
        showsBuildings = try container.decode(Bool.self, forKey: .showsBuildings)
        showsPointsOfInterest = try container.decode(Bool.self, forKey: .showsPointsOfInterest)
        darkMode = try container.decode(Bool.self, forKey: .darkMode)
        
    }
}

extension EarthPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        guard resolution == pixelModel.resolution else { return false }
        guard mapType == pixelModel.mapType else { return false }
        guard coordinate == pixelModel.coordinate else { return false }
        guard span == pixelModel.span else { return false }
        guard showsBuildings == pixelModel.showsBuildings else { return false }
        guard showsPointsOfInterest == pixelModel.showsPointsOfInterest else { return false }
        guard darkMode == pixelModel.darkMode else { return false }
        return true
    }
}
