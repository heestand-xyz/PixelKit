//
//  CropPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-05.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public extension PIXOut {
    
    func crop(_ cropFrame: CGRect) -> CropPIX {
        let cropPix = CropPIX()
        cropPix.inPix = self as? PIX & PIXOut
        cropPix.cropFrame = cropFrame
        return cropPix
    }
    
}

public class CropPIX: PIXSingleEffect, PIXofaKind {
    
    let kind: PIX.Kind = .crop
    
    override open var shader: String { return "effectSingleCropPIX" }
    
    var resScale: Res { return .size(cropFrame.size) }
    
    public var cropFrame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) { didSet { applyRes { self.setNeedsRender() } } }
    enum CodingKeys: String, CodingKey {
        case cropFrame
    }
    override var uniforms: [CGFloat] {
        return [cropFrame.minX, cropFrame.maxX, cropFrame.minY, cropFrame.maxY]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cropFrame = try container.decode(CGRect.self, forKey: .cropFrame)
        setNeedsRender()
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cropFrame, forKey: .cropFrame)
    }
    
}
