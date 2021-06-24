//
//  StarPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-18.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit
import Resolution
import SwiftUI

final public class StarPIX: PIXGenerator, PIXViewable {
    
    override public var shaderName: String { return "contentGeneratorStarPIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("innerRadius", range: 0.0...0.5, increment: 0.125) public var innerRadius: CGFloat = 0.125
    @LiveFloat("outerRadius", range: 0.0...0.5, increment: 0.125) public var outerRadius: CGFloat = 0.25
    @LiveFloat("rotation", range: -0.5...0.5) public var rotation: CGFloat = 0.0
    @LiveInt("count", range: 3...12) public var count: Int = 5
    @LiveFloat("cornerRadius", range: 0.0...0.1, increment: 0.025) public var cornerRadius: CGFloat = 0.0
   
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_position, _innerRadius, _outerRadius, _rotation, _count, _cornerRadius]
    }
    
    override public var values: [Floatable] {
        [innerRadius, outerRadius, position, rotation, count, super.color, super.backgroundColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Star", typeName: "pix-content-generator-star")
    }
    
    public convenience init(at resolution: Resolution = .auto(render: PixelKit.main.render),
                            innerRadius: CGFloat = 0.125,
                            outerRadius: CGFloat = 0.25,
                            count: Int = 5,
                            cornerRadius: CGFloat = 0.0) {
        self.init(at: resolution)
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.count = count
        self.cornerRadius = cornerRadius
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
