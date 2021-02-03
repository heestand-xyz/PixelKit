//
//  LinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import CoreGraphics
import RenderKit

// TODO: Square Caps

final public class LinePIX: PIXGenerator, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorLinePIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var positionFrom: CGPoint = CGPoint(x: -0.25, y: 0.0)
    @Live public var positionTo: CGPoint = CGPoint(x: 0.25, y: 0.0)
    @Live public var scale: CGFloat = 0.01
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_positionFrom, _positionTo, _scale]
    }
    
    override public var values: [Floatable] {
        [positionFrom, positionTo, scale, super.color, super.backgroundColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Line", typeName: "pix-content-generator-line")
    }
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            positionFrom: CGPoint = CGPoint(x: -0.25, y: -0.25),
                            positionTo: CGPoint = CGPoint(x: 0.25, y: 0.25),
                            scale: CGFloat = 0.01) {
        self.init(at: resolution)
        self.positionFrom = positionFrom
        self.positionTo = positionTo
        self.scale = scale
    }
    
}
