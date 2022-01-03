//
//  GradientPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-09.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics
import PixelColor

final public class GradientPIX: PIXGenerator, PIXViewable {
    
    public typealias Model = GradientPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorGradientPIX" }
    
    // MARK: - Public Types
    
    public enum Direction: String, Enumable {
        case horizontal
        case vertical
        case radial
        case angle
        public var index: Int {
            switch self {
            case .horizontal: return 0
            case .vertical: return 1
            case .radial: return 2
            case .angle: return 3
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            case .radial: return "Radial"
            case .angle: return "Angle"
            }
        }
    }
    
    // MARK: - Public Properties
    
    @LiveEnum("direction") public var direction: Direction = .vertical
    @LiveFloat("scale") public var scale: CGFloat = 1.0
    @LiveFloat("offset", range: -0.5...0.5) public var offset: CGFloat = 0.0
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("gamma", range: 0.0...2.0, increment: 0.5) public var gamma: CGFloat = 1.0
    @LiveEnum("extendMode") public var extendMode: ExtendMode = .hold
    
    @available(*, deprecated, renamed: "colorStops")
    public var colorSteps: [ColorStop] {
        get { colorStops }
        set { colorStops = newValue }
    }
    public var colorStops: [ColorStop] {
        get { model.colorStops }
        set { model.colorStops = newValue }
    }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList.filter({ liveWrap in
            !["backgroundColor", "color"].contains(liveWrap.typeName)
        }) + [_direction, _scale, _offset, _position, _gamma, _extendMode]
    }
    
    override public var values: [Floatable] {
        return [direction, scale, offset, position, position, gamma, extendMode]
    }

    override public var uniformArray: [[CGFloat]] {
        colorStops.map(\.floats)
    }
    
    public override var uniforms: [CGFloat] {
        return [CGFloat(direction.index), scale, offset, position.x, position.y, gamma, CGFloat(extendMode.index)]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            direction: Direction = .vertical,
                            colorStops: [ColorStop] = [ColorStop(0.0, .black), ColorStop(1.0, .white)]) {
        self.init(at: resolution)
        self.direction = direction
        self.colorStops = colorStops
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        direction = model.direction
        scale = model.scale
        offset = model.offset
        position = model.position
        gamma = model.gamma
        extendMode = model.extendMode
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.direction = direction
        model.scale = scale
        model.offset = offset
        model.position = position
        model.gamma = gamma
        model.extendMode = extendMode
        
        super.liveUpdateModelDone()
    }
    
    // MARK: - Property Funcs
    
    public func pixGradientScale(_ value: CGFloat) -> GradientPIX {
        scale = value
        return self
    }
    
    public func pixGradientOffset(_ value: CGFloat) -> GradientPIX {
        offset = value
        return self
    }
    
    public func pixGradientPosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> GradientPIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
    public func pixGradientExtendRamp(_ value: ExtendMode) -> GradientPIX {
        extendMode = value
        return self
    }
    
}

public extension NODEOut {
    
    func pixGradientMap(from firstColor: PixelColor, to lastColor: PixelColor) -> LookupPIX {
        let lookupPix = LookupPIX()
        lookupPix.name = "gradientMap:lookup"
        lookupPix.inputA = self as? PIX & NODEOut
        let resolution: Resolution = PixelKit.main.render.bits == ._8 ? ._256 : ._8192
        let gradientPix = GradientPIX(at: .custom(w: resolution.w, h: 1))
        gradientPix.name = "gradientMap:gradient"
        gradientPix.colorStops = [ColorStop(0.0, firstColor), ColorStop(1.0, lastColor)]
        lookupPix.inputB = gradientPix
        return lookupPix
    }
    
}
