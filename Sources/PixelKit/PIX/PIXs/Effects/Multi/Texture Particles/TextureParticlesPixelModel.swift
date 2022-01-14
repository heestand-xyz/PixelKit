//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct TextureParticlesPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Texture Particles"
    public var typeName: String = "pix-effect-multi-texture-particles"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = ._128
    public var backgroundColor: PixelColor = .black
    public var blendMode: BlendMode = .add
    public var lifeTime: CGFloat = 1.0
    public var emitCount: Int = 1
    public var emitFrameInterval: Int = 10
    public var emitPosition: CGPoint = .zero
    public var emitSize: CGSize = .zero
    public var direction: CGPoint = .zero
    public var randomDirection: CGFloat = 1.0
    public var velocity: CGFloat = 0.005
    public var randomVelocity: CGFloat = 0.0
    public var particleScale: CGFloat = 0.1
}

extension TextureParticlesPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case backgroundColor
        case blendMode
        case lifeTime
        case emitCount
        case emitFrameInterval
        case emitPosition
        case emitSize
        case direction
        case randomDirection
        case velocity
        case randomVelocity
        case particleScale
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
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    backgroundColor = live.wrappedValue
                case .blendMode:
                    let live: LiveEnum<BlendMode> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    blendMode = live.wrappedValue
                case .lifeTime:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    lifeTime = live.wrappedValue
                case .emitCount:
                    guard let live = liveWrap as? LiveInt else { continue }
                    emitCount = live.wrappedValue
                case .emitFrameInterval:
                    guard let live = liveWrap as? LiveInt else { continue }
                    emitFrameInterval = live.wrappedValue
                case .emitPosition:
                    guard let live = liveWrap as? LivePoint else { continue }
                    emitPosition = live.wrappedValue
                case .emitSize:
                    guard let live = liveWrap as? LiveSize else { continue }
                    emitSize = live.wrappedValue
                case .direction:
                    guard let live = liveWrap as? LivePoint else { continue }
                    direction = live.wrappedValue
                case .randomDirection:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    randomDirection = live.wrappedValue
                case .velocity:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    velocity = live.wrappedValue
                case .randomVelocity:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    randomVelocity = live.wrappedValue
                case .particleScale:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    particleScale = live.wrappedValue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
        blendMode = try container.decode(BlendMode.self, forKey: .blendMode)
        lifeTime = try container.decode(CGFloat.self, forKey: .lifeTime)
        emitCount = try container.decode(Int.self, forKey: .emitCount)
        emitFrameInterval = try container.decode(Int.self, forKey: .emitFrameInterval)
        emitPosition = try container.decode(CGPoint.self, forKey: .emitPosition)
        emitSize = try container.decode(CGSize.self, forKey: .emitSize)
        direction = try container.decode(CGPoint.self, forKey: .direction)
        randomDirection = try container.decode(CGFloat.self, forKey: .randomDirection)
        velocity = try container.decode(CGFloat.self, forKey: .velocity)
        randomVelocity = try container.decode(CGFloat.self, forKey: .randomVelocity)
        particleScale = try container.decode(CGFloat.self, forKey: .particleScale)
    }
}
