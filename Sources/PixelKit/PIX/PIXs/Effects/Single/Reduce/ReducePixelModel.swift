//
//  Created by Anton Heestand on 2022-01-04.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct ReducePixelModel: PixelSingleEffectModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Reduce"
    public var typeName: String = "pix-effect-single-reduce"
    public var bypass: Bool = false
    
    public var inputNodeReferences: [NodeReference] = []
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var cellList: ReducePIX.CellList = .row
    public var method: ReducePIX.Method = .average
}

extension ReducePixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case cellList
        case method
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelSingleEffectModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        cellList = try container.decode(ReducePIX.CellList.self, forKey: .cellList)
        method = try container.decode(ReducePIX.Method.self, forKey: .method)
    }
}

extension ReducePixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelSingleEffectEqual(to: pixelModel) else { return false }
        guard cellList == pixelModel.cellList else { return false }
        guard method == pixelModel.method else { return false }
        return true
    }
}
