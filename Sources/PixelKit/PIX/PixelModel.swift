//
//  Created by Anton Heestand on 2021-02-04.
//

import Foundation
import RenderKit

public protocol PixelModel: NodeModel {
    var viewInterpolation: ViewInterpolation { get set }
    var interpolation: PixelInterpolation { get set }
    var extend: ExtendMode { get set }
}

struct PixelModelDecoder {
    
    enum CodingKeys: CodingKey {
        case viewInterpolation
        case interpolation
        case extend
    }
    
    static func decode(from decoder: Decoder, model: PixelModel) throws -> PixelModel {
        
        var model: PixelModel = model
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        model.viewInterpolation = try container.decode(ViewInterpolation.self, forKey: .viewInterpolation)
        model.interpolation = try container.decode(PixelInterpolation.self, forKey: .interpolation)
        model.extend = try container.decode(ExtendMode.self, forKey: .extend)
        
        return model
    }
    
    enum LiveCodingKeys: CodingKey {
        case liveList
    }
    
    enum TypeCodingKey: CodingKey {
        case type
    }
    
    static func isLiveListCodable(decoder: Decoder) throws -> Bool {
        
        let container = try decoder.container(keyedBy: LiveCodingKeys.self)
        
        return container.contains(.liveList)
    }
    
    static func liveListDecode(from decoder: Decoder) throws -> [LiveWrap] {
        
        let container = try decoder.container(keyedBy: LiveCodingKeys.self)
        
        var liveCodables: [LiveCodable] = []
        var liveListContainer = try container.nestedUnkeyedContainer(forKey: .liveList)
        var liveListContainerMain = liveListContainer
        while !liveListContainer.isAtEnd {
            let liveTypeContainer = try liveListContainer.nestedContainer(keyedBy: TypeCodingKey.self)
            let liveType: LiveType = try liveTypeContainer.decode(LiveType.self, forKey: .type)
            let liveCodable: LiveCodable = try liveListContainerMain.decode(liveType.liveCodableType)
            liveCodables.append(liveCodable)
        }
        
        var liveList: [LiveWrap] = []
        for liveCodable in liveCodables {
            guard let liveWrap: LiveWrap = liveList.first(where: { $0.typeName == liveCodable.typeName }) else { continue }
            liveWrap.setLiveCodable(liveCodable)
            liveList.append(liveWrap)
        }
        
        return liveList
    }
}

@available(*, deprecated)
struct TempPixelModel: PixelModel {
    
    /// Global
    
    var id: UUID = UUID()
    var name: String
    let typeName: String
    var bypass: Bool = false
    
    var viewInterpolation: ViewInterpolation = .linear
    var interpolation: PixelInterpolation = .linear
    var extend: ExtendMode = .zero
    
}
