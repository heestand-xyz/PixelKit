//
//  RectanglePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution

final public class RectanglePIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveSize("size") public var size: CGSize = CGSize(width: 0.5, height: 0.5)
    @LiveFloat("cornerRadius", range: 0.0...0.1) public var cornerRadius: CGFloat = 0.0
    
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
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            size: CGSize = CGSize(width: 0.5, height: 0.5),
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Property Funcs
    
    public func pixRectanglePosition(x: CGFloat = 0.0, y: CGFloat = 0.0) -> RectanglePIX {
        position = CGPoint(x: x, y: y)
        return self
    }
    
}
