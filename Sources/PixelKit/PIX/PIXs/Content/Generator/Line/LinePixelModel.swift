//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct LinePixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Line"
    public var typeName: String = "pix-content-generator-line"
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
    
    public var positionFrom: CGPoint = CGPoint(x: -0.5, y: 0.0)
    public var positionTo: CGPoint = CGPoint(x: 0.5, y: 0.0)
    public var lineWidth: CGFloat = 0.01
}

extension LinePixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case positionFrom
        case positionTo
        case lineWidth
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelGeneratorModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .positionFrom:
                    guard let live = liveWrap as? LivePoint else { continue }
                    positionFrom = live.wrappedValue
                case .positionTo:
                    guard let live = liveWrap as? LivePoint else { continue }
                    positionTo = live.wrappedValue
                case .lineWidth:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    lineWidth = live.wrappedValue
                }
            }
            return
        }
        
        positionFrom = try container.decode(CGPoint.self, forKey: .positionFrom)
        positionTo = try container.decode(CGPoint.self, forKey: .positionTo)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
    }
}

