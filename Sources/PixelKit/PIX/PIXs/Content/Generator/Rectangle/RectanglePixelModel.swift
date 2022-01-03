//
//  Created by Anton Heestand on 2021-12-14.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct RectanglePixelModel: PixelGeneratorModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Rectangle"
    public var typeName: String = "pix-content-generator-rectangle"
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
    public var size: CGSize = CGSize(width: 0.5, height: 0.5)
    public var cornerRadius: CGFloat = 0.0
}

extension RectanglePixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case position
        case size
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
                case .size:
                    guard let live = liveWrap as? LiveSize else { continue }
                    size = live.wrappedValue
                case .cornerRadius:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    cornerRadius = live.wrappedValue
                }
            }
            return
        }
        
        position = try container.decode(CGPoint.self, forKey: .position)
        size = try container.decode(CGSize.self, forKey: .size)
        cornerRadius = try container.decode(CGFloat.self, forKey: .cornerRadius)
    }
}

