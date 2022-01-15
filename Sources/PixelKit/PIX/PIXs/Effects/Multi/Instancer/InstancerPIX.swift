//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-12-29.
//

import CoreGraphics
import CoreGraphicsExtensions
import RenderKit
import Resolution
import PixelColor

final public class InstancerPIX: PIXMultiEffect, NODEResolution {
    
    public typealias Model = InstancerPixelModel
    
    private var model: Model {
        get { multiEffectModel as! Model }
        set { multiEffectModel = newValue }
    }
    
    public override var shaderName: String { return "instancerPIX" }
    
    /// Defined as `INSTANCE_MAX_COUNT` in shader
    private static let instanceMaxCount: Int = 1000
    public override var uniformArrayMaxLimit: Int? { Self.instanceMaxCount }
        
    public struct Instance: Codable {
        
        public var position: CGPoint
        public var scale: CGFloat
        public var opacity: CGFloat
        public var textureIndex: Int
        
        public init(position: CGPoint,
                    scale: CGFloat,
                    opacity: CGFloat,
                    textureIndex: Int) {
            self.position = position
            self.scale = scale
            self.opacity = opacity
            self.textureIndex = textureIndex
        }
    }

    public var instances: [Instance] {
        get { model.instances }
        set {
            model.instances = newValue
            render()
        }
    }
    
    // MARK: Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    @LiveColor("backgroundColor") public var backgroundColor: PixelColor = .black
    @LiveEnum("blendMode") public var blendMode: BlendMode = .add

    // MARK: Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _backgroundColor, _blendMode]
    }
    
    public override var values: [Floatable] {
        [backgroundColor, blendMode, resolution.aspect]
    }
    
    public override var uniformArray: [[CGFloat]] {
        instances.map({ [$0.position.x, $0.position.y, $0.scale, $0.opacity, CGFloat($0.textureIndex)] })
    }

    public override var uniformArrayLength: Int? { 5 }

    // MARK: - Life Cycle
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    public init(at resolution: Resolution) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        blendMode = model.blendMode
        backgroundColor = model.backgroundColor

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        model.blendMode = blendMode
        model.backgroundColor = backgroundColor

        super.liveUpdateModelDone()
    }
        
}
