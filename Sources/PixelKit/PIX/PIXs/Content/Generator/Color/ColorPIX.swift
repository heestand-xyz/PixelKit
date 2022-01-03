//
//  ColorPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import Resolution
import PixelColor

final public class ColorPIX: PIXGenerator, PIXViewable {
    
    public typealias Model = ColorPixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList.filter { liveWrap in
            liveWrap.typeName != "backgroundColor"
        }
    }
    
    override public var values: [Floatable] {
        [super.color]
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
                            color: PixelColor) {
        self.init(at: resolution)
        super.color = color
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
}
