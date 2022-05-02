//
//  Created by Anton Heestand on 2022-01-08.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct StackPixelModel: PixelMultiEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Stack"
    public var typeName: String = "pix-effect-multi-stack"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = ._128
    public var axis: StackPIX.Axis = .vertical
    public var alignment: StackPIX.Alignment = .center
    public var spacing: CGFloat = 0.0
    public var padding: CGFloat = 0.0
    public var backgroundColor: PixelColor = .clear
}

extension StackPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case axis
        case alignment
        case spacing
        case padding
        case backgroundColor
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
                case .axis:
                    let live: LiveEnum<StackPIX.Axis> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    axis = live.wrappedValue
                case .alignment:
                    let live: LiveEnum<StackPIX.Alignment> = try PixelModelDecoder.liveEnumDecode(typeName: liveWrap.typeName, from: decoder)
                    alignment = live.wrappedValue
                case .spacing:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    spacing = live.wrappedValue
                case .padding:
                    guard let live = liveWrap as? LiveFloat else { continue }
                    padding = live.wrappedValue
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    backgroundColor = live.wrappedValue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        axis = try container.decode(StackPIX.Axis.self, forKey: .axis)
        alignment = try container.decode(StackPIX.Alignment.self, forKey: .alignment)
        spacing = try container.decode(CGFloat.self, forKey: .spacing)
        padding = try container.decode(CGFloat.self, forKey: .padding)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
    }
}

extension StackPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelMultiEffectEqual(to: pixelModel) else { return false }
        guard resolution == pixelModel.resolution else { return false }
        guard axis == pixelModel.axis else { return false }
        guard alignment == pixelModel.alignment else { return false }
        guard spacing == pixelModel.spacing else { return false }
        guard padding == pixelModel.padding else { return false }
        guard backgroundColor == pixelModel.backgroundColor else { return false }
        return true
    }
}
