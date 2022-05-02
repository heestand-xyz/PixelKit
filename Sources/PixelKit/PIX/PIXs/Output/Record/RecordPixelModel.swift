//
//  Created by Anton Heestand on 2022-01-09.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct RecordPixelModel: PixelOutputModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Record"
    public var typeName: String = "pix-output-record"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var fps: Int = 30
    public var timeSync: Bool = true
    public var realtime: Bool = true
    public var directMode: Bool = true
    public var quality: RecordPIX.Quality = .default
}

extension RecordPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case fps
        case timeSync
        case realtime
        case directMode
        case quality
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelOutputModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        fps = try container.decode(Int.self, forKey: .fps)
        timeSync = try container.decode(Bool.self, forKey: .timeSync)
        realtime = try container.decode(Bool.self, forKey: .realtime)
        directMode = try container.decode(Bool.self, forKey: .directMode)
        quality = try container.decode(RecordPIX.Quality.self, forKey: .quality)
    }
}

extension RecordPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelOutputEqual(to: pixelModel) else { return false }
        guard fps == pixelModel.fps else { return false }
        guard timeSync == pixelModel.timeSync else { return false }
        guard realtime == pixelModel.realtime else { return false }
        guard directMode == pixelModel.directMode else { return false }
        guard quality == pixelModel.quality else { return false }
        return true
    }
}
