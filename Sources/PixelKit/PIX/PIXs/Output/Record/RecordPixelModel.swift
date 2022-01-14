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
    
    public var outputNodeReferences: [NodeReference] = []

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
