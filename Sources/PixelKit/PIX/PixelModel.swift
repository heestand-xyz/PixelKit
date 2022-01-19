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

public struct PixelModelDecoder {
    
    enum CodingKeys: CodingKey {
        case viewInterpolation
        case interpolation
        case extend
    }
    
    static func decode(from decoder: Decoder, model: PixelModel) throws -> PixelModel {
        
        var model: PixelModel = try NodeModelDecoder.decode(from: decoder, model: model) as! PixelModel

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        model.viewInterpolation = try container.decode(ViewInterpolation.self, forKey: .viewInterpolation)
        model.interpolation = try container.decode(PixelInterpolation.self, forKey: .interpolation)
        model.extend = try container.decode(ExtendMode.self, forKey: .extend)
        
        return model
    }
    
}

extension PixelModelDecoder {
    
    enum LiveCodingKeys: CodingKey {
        case liveList
    }
    
    enum TypeCodingKey: CodingKey {
        case type
    }
    
    public static func isLiveListCodable(decoder: Decoder) throws -> Bool {
        
        let container = try decoder.container(keyedBy: LiveCodingKeys.self)
        
        return container.contains(.liveList)
    }
    
    public static func liveListDecode(from decoder: Decoder) throws -> [LiveWrap] {
        
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
            let liveWrap: LiveWrap = .skeleton(liveCodable: liveCodable)
            liveList.append(liveWrap)
        }
        
        return liveList
    }
    
    enum LiveEnumDecodeError: Error {
        case notAnEnum
        case notFound
    }
    
    public static func liveEnumDecode<E: Enumable>(typeName: String, from decoder: Decoder) throws -> LiveEnum<E> {
        
        let container = try decoder.container(keyedBy: LiveCodingKeys.self)
        
        var liveCodableEnum: LiveCodableEnum!
        var liveListContainer = try container.nestedUnkeyedContainer(forKey: .liveList)
        var liveListContainerMain = liveListContainer
        while !liveListContainer.isAtEnd {
            let liveTypeContainer = try liveListContainer.nestedContainer(keyedBy: TypeCodingKey.self)
            let liveType: LiveType = try liveTypeContainer.decode(LiveType.self, forKey: .type)
            let liveCodable: LiveCodable = try liveListContainerMain.decode(liveType.liveCodableType)
            guard liveCodable.typeName == typeName else { continue }
            if let currentLiveCodableEnum = liveCodable as? LiveCodableEnum {
                liveCodableEnum = currentLiveCodableEnum
                break
            } else {
                throw LiveEnumDecodeError.notAnEnum
            }
        }
        guard liveCodableEnum != nil else {
            throw LiveEnumDecodeError.notFound
        }
        
        let liveEnum = LiveEnum(wrappedValue: E.allCases.first!, typeName)
        liveEnum.setLiveCodable(liveCodableEnum)
        
        return liveEnum
    }
}
