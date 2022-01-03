//
//  Created by Anton Heestand on 2022-01-03.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct PaintPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Paint"
    public var typeName: String = "pix-content-resource-paint"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var resolution: Resolution = .auto
    public var manualToolUpdate: Bool = false
    public var toolType: PaintPIX.ToolType = .inking
    public var inkType: PaintPIX.InkType = .pen
    public var color: PixelColor = .white
    public var width: CGFloat = 10
    public var eraserType: PaintPIX.EraserType = .bitmap
    public var allowsFingerDrawing: Bool = true
    public var backgroundColor: PixelColor = .black
}

extension PaintPixelModel {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case resolution
        case manualToolUpdate
        case toolType
        case inkType
        case color
        case width
        case eraserType
        case allowsFingerDrawing
        case backgroundColor
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            let liveList: [LiveWrap] = try PixelModelDecoder.liveListDecode(from: decoder)
            for codingKey in CodingKeys.allCases {
                guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == codingKey.rawValue }) else { continue }
                
                switch codingKey {
                case .resolution:
                    guard let live = liveWrap as? LiveResolution else { continue }
                    resolution = live.wrappedValue
                case .backgroundColor:
                    guard let live = liveWrap as? LiveColor else { continue }
                    backgroundColor = live.wrappedValue
                default:
                    continue
                }
            }
            return
        }
        
        resolution = try container.decode(Resolution.self, forKey: .resolution)
        manualToolUpdate = try container.decode(Bool.self, forKey: .manualToolUpdate)
        toolType = try container.decode(PaintPIX.ToolType.self, forKey: .toolType)
        inkType = try container.decode(PaintPIX.InkType.self, forKey: .inkType)
        color = try container.decode(PixelColor.self, forKey: .color)
        width = try container.decode(CGFloat.self, forKey: .width)
        eraserType = try container.decode(PaintPIX.EraserType.self, forKey: .eraserType)
        allowsFingerDrawing = try container.decode(Bool.self, forKey: .allowsFingerDrawing)
        backgroundColor = try container.decode(PixelColor.self, forKey: .backgroundColor)
    }
}
