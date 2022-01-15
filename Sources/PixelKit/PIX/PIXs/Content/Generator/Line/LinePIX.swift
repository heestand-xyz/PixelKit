//
//  LinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//

import SwiftUI
import Foundation
import CoreGraphics
import RenderKit
import Resolution

// TODO: Square Caps

final public class LinePIX: PIXGenerator, PIXViewable {
    
    public typealias Model = LinePixelModel
    
    private var model: Model {
        get { generatorModel as! Model }
        set { generatorModel = newValue }
    }
    
    override public var shaderName: String { return "contentGeneratorLinePIX" }
    
    // MARK: - Public Properties
    
    @LivePoint("positionFrom") public var positionFrom: CGPoint = CGPoint(x: -0.5, y: 0.0)
    @LivePoint("positionTo") public var positionTo: CGPoint = CGPoint(x: 0.5, y: 0.0)
    @LiveFloat("lineWidth", range: 0.0...0.05, increment: 0.005) public var lineWidth: CGFloat = 0.01
    
    public enum Cap: String, Enumable {
        case square
        case round
        case diamond
        public var index: Int {
            switch self {
            case .square:
                return 0
            case .round:
                return 1
            case .diamond:
                return 2
            }
        }
        public var name: String {
            switch self {
            case .square:
                return "Square"
            case .round:
                return "Round"
            case .diamond:
                return "Diamond"
            }
        }
        public var typeName: String { rawValue }
    }
    @LiveEnum("cap") public var cap: Cap = .square

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_positionFrom, _positionTo, _lineWidth, _cap]
    }
    
    override public var values: [Floatable] {
        [positionFrom, positionTo, lineWidth, cap, super.color, super.backgroundColor]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
    }
    
    public convenience init(at resolution: Resolution = .auto,
                            positionFrom: CGPoint = CGPoint(x: -0.25, y: -0.25),
                            positionTo: CGPoint = CGPoint(x: 0.25, y: 0.25),
                            scale: CGFloat = 0.01) {
        self.init(at: resolution)
        self.positionFrom = positionFrom
        self.positionTo = positionTo
        self.lineWidth = lineWidth
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        positionFrom = model.positionFrom
        positionTo = model.positionTo
        lineWidth = model.lineWidth
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.positionFrom = positionFrom
        model.positionTo = positionTo
        model.lineWidth = lineWidth
        
        super.liveUpdateModelDone()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PixelView(pix: LinePIX())
    }
}
