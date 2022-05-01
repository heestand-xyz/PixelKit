//
//  Created by Anton Heestand on 2022-01-03.
//

#if os(macOS) && !targetEnvironment(macCatalyst)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ScreenCapturePixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Screen Capture"
    public var typeName: String = "pix-content-resource-screen-capture"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var screenIndex: Int = 0
}

extension ScreenCapturePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case screenIndex
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in LocalCodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .screenIndex:
                    guard let live = liveWrap as? LiveInt else { continue }
                    screenIndex = live.wrappedValue
                }
            }
            return
        }
        
        screenIndex = try container.decode(Int.self, forKey: .screenIndex)
    }
}

extension ScreenCapturePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        guard screenIndex == pixelModel.screenIndex else { return false }
        return true
    }
}

#endif
