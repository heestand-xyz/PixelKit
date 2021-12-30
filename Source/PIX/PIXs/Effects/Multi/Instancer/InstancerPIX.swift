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
        
    public override var shaderName: String { return "instancerPIX" }
    
    /// Defined as `INSTANCE_MAX_COUNT` in shader
    private static let instanceMaxCount: Int = 1000
    public override var uniformArrayMaxLimit: Int? { Self.instanceMaxCount }
        
    public struct Instance {
        
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

    public var instances: [Instance] = [] {
        didSet {
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
    
    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        self.resolution = resolution
        super.init(name: "Instancer", typeName: "pix-effect-multi-instancer")
    }
    
    public required init() {
        super.init(name: "Instancer", typeName: "pix-effect-multi-instancer")
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
}
