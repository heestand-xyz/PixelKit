//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct NoisePixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Noise"
    public var typeName: String = "pix-content-generator-noise"
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
    
    public var seed: Int = 1
    public var octaves: Int = 1
    public var position: CGPoint = .zero
    public var motion: CGFloat = 0.0
    public var zoom: CGFloat = 1.0
    public var colored: Bool = false
    public var random: Bool = false
    public var includeAlpha: Bool = false
}

extension NoisePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case seed
        case octaves
        case position
        case motion
        case zoom
        case colored
        case random
        case includeAlpha
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .seed:
                    guard let live = liveWrap as? LiveInt else { continue }
                    seed = live.wrappedValue
                case .octaves:
                    guard let live = liveWrap as? LiveInt else { continue }
                    octaves = live.wrappedValue
                case .position:
                    guard let live = liveWrap as? LivePoint else { continue }
                    position = live.wrappedValue
                case .motion:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    motion = live.wrappedValue
                case .zoom:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    zoom = live.wrappedValue
                case .colored:
                    guard let live = liveWrap as? LiveBool else { continue }
                    colored = live.wrappedValue
                case .random:
                    guard let live = liveWrap as? LiveBool else { continue }
                    random = live.wrappedValue
                case .includeAlpha:
                    guard let live = liveWrap as? LiveBool else { continue }
                    includeAlpha = live.wrappedValue
                }
            }
            return
        }
        
        seed = try container.decode(Int.self, forKey: .seed)
        octaves = try container.decode(Int.self, forKey: .octaves)
        position = try container.decode(CGPoint.self, forKey: .position)
        motion = try container.decode(CGFloat.self, forKey: .motion)
        zoom = try container.decode(CGFloat.self, forKey: .zoom)
        colored = try container.decode(Bool.self, forKey: .colored)
        random = try container.decode(Bool.self, forKey: .random)
        includeAlpha = try container.decode(Bool.self, forKey: .includeAlpha)
        
    }
}

extension NoisePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelGeneratorEqual(to: pixelModel) else { return false }
        guard seed == pixelModel.seed else { return false }
        guard octaves == pixelModel.octaves else { return false }
        guard position == pixelModel.position else { return false }
        guard motion == pixelModel.motion else { return false }
        guard zoom == pixelModel.zoom else { return false }
        guard colored == pixelModel.colored else { return false }
        guard random == pixelModel.random else { return false }
        guard includeAlpha == pixelModel.includeAlpha else { return false }
        return true
    }
}
