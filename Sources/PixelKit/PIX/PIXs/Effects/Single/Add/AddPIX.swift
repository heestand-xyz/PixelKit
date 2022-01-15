//
//  AddPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

/// Useful with **VoxelKit** to downsample depth images.
final public class AddPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = AddPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "addPix" }

    // MARK: - Public Properties

    public enum Axis: String, Enumable {
        case x
        case y
        case z
        public var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .x: return "X"
            case .y: return "Y"
            case .z: return "Z"
            }
        }
    }
    @LiveEnum("axis") public var axis: Axis = .z

    // MARK: - Property Helpers

    public override var liveList: [LiveWrap] {
        [_axis]
    }

    public override var values: [Floatable] {
        [axis]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        axis = model.axis
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.axis = axis
        
        super.liveUpdateModelDone()
    }

}
