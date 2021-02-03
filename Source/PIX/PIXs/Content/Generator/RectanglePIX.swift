//
//  RectanglePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

final public class RectanglePIX: PIXGenerator, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorRectanglePIX" }
    
    var bodyView: UINSView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var position: CGPoint = .zero
    @Live public var size: CGSize = CGSize(width: 0.5, height: 0.5)
    @Live public var cornerRadius: CGFloat = 0.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _size, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [size, position, cornerRadius, super.color, super.backgroundColor]
    }
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Rectangle", typeName: "pix-content-generator-rectangle")
    }
    
}
