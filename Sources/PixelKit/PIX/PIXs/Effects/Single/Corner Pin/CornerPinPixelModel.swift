//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct CornerPinPixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Corner Pin"
    public var typeName: String = "pix-effect-single-corner-pin"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var topLeft: CGPoint = CGPoint(x: 0, y: 1)
    public var topRight: CGPoint = CGPoint(x: 1, y: 1)
    public var bottomLeft: CGPoint = CGPoint(x: 0, y: 0)
    public var bottomRight: CGPoint = CGPoint(x: 1, y: 0)
    public var perspective: Bool = false
    public var subdivisions: Int = 16
}

extension CornerPinPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case perspective
        case subdivisions
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .topLeft:
                    guard let live = liveWrap as? LivePoint else { continue }
                    topLeft = live.wrappedValue
                case .topRight:
                    guard let live = liveWrap as? LivePoint else { continue }
                    topRight = live.wrappedValue
                case .bottomLeft:
                    guard let live = liveWrap as? LivePoint else { continue }
                    bottomLeft = live.wrappedValue
                case .bottomRight:
                    guard let live = liveWrap as? LivePoint else { continue }
                    bottomRight = live.wrappedValue
                case .perspective:
                    guard let live = liveWrap as? LiveBool else { continue }
                    perspective = live.wrappedValue
                case .subdivisions:
                    guard let live = liveWrap as? LiveInt else { continue }
                    subdivisions = live.wrappedValue
                }
            }
            return
        }
        
        topLeft = try container.decode(CGPoint.self, forKey: .topLeft)
        topRight = try container.decode(CGPoint.self, forKey: .topRight)
        bottomLeft = try container.decode(CGPoint.self, forKey: .bottomLeft)
        bottomRight = try container.decode(CGPoint.self, forKey: .bottomRight)
        perspective = try container.decode(Bool.self, forKey: .perspective)
        subdivisions = try container.decode(Int.self, forKey: .subdivisions)
    }
}
