//
//  ChromaKeyPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

final public class ChromaKeyPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = ChromaKeyPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "effectSingleChromaKeyPIX" }
    
    // MARK: - Public Properties
    
    @LiveColor("keyColor") public var keyColor: PixelColor = .green
    @LiveFloat("range", range: 0.0...0.5) public var range: CGFloat = 0.1
    @LiveFloat("softness", range: 0.0...0.5) public var softness: CGFloat = 0.1
    @LiveFloat("edgeDesaturation") public var edgeDesaturation: CGFloat = 0.5
    @LiveFloat("alphaCrop") public var alphaCrop: CGFloat = 0.5
    @LiveBool("premultiply") public var premultiply: Bool = true
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_keyColor, _range, _softness, _edgeDesaturation, _alphaCrop, _premultiply]
    }
    
    override public var values: [Floatable] {
        [keyColor, range, softness, edgeDesaturation, alphaCrop, premultiply]
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
        
        keyColor = model.keyColor
        range = model.range
        softness = model.softness
        edgeDesaturation = model.edgeDesaturation
        alphaCrop = model.alphaCrop
        premultiply = model.premultiply
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.keyColor = keyColor
        model.range = range
        model.softness = softness
        model.edgeDesaturation = edgeDesaturation
        model.alphaCrop = alphaCrop
        model.premultiply = premultiply
        
        super.liveUpdateModelDone()
    }
}

public extension NODEOut {
    
    func pixChromaKey(_ color: PixelColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.name = ":chromaKey:"
        chromaKeyPix.input = self as? PIX & NODEOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}
