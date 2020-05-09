//
//  CropPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-05.
//  Open Source - MIT License
//

import RenderKit
import CoreGraphics

public class CropPIX: PIXSingleEffect {
    
    override open var shaderName: String { return "effectSingleCropPIX" }
    
    // MARK: - Public Properties
    
    var resScale: CGSize { return cropFrame.size }
    
    public var cropFrame: CGRect {
        get { CGRect(x: cropLeft, y: cropBottom, width: cropRight - cropLeft, height: cropTop - cropBottom) }
        set {
            cropLeft = newValue.minX
            cropRight = newValue.maxX
            cropBottom = newValue.minY
            cropTop = newValue.maxY
        }
    }
    public var cropLeft: CGFloat = 0.0 { didSet { applyResolution { self.setNeedsRender() } } }
    public var cropRight: CGFloat = 1.0 { didSet { applyResolution { self.setNeedsRender() } } }
    public var cropBottom: CGFloat = 0.0 { didSet { applyResolution { self.setNeedsRender() } } }
    public var cropTop: CGFloat = 1.0 { didSet { applyResolution { self.setNeedsRender() } } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [cropLeft, cropRight, cropBottom, cropTop]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Crop", typeName: "pix-effect-single-crop")
    }
    
}

public extension NODEOut {
    
    func _crop(_ cropFrame: CGRect) -> CropPIX {
        let cropPix = CropPIX()
        cropPix.name = ":crop:"
        cropPix.input = self as? PIX & NODEOut
        cropPix.cropFrame = cropFrame
        return cropPix
    }
    
    func _cropLeft(_ cropFraction: CGFloat) -> CropPIX {
        return _crop(CGRect(x: cropFraction, y: 0.0, width: 1.0 - cropFraction, height: 1.0))
    }
    
    func _cropRight(_ cropFraction: CGFloat) -> CropPIX {
       return _crop(CGRect(x: 0.0, y: 0.0, width: 1.0 - cropFraction, height: 1.0))
    }
    
    func _cropTop(_ cropFraction: CGFloat) -> CropPIX {
       return _crop(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0 - cropFraction))
    }
    
    func _cropBottom(_ cropFraction: CGFloat) -> CropPIX {
        return _crop(CGRect(x: 0.0, y: cropFraction, width: 1.0, height: 1.0 - cropFraction))
    }
    
}
