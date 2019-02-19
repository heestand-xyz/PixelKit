//
//  CropPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-05.
//  Open Source - MIT License
//
import CoreGraphics//x

public class CropPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleCropPIX" }
    
    // MARK: - Public Properties
    
    var resScale: Res { return .size(cropFrame.size) }
    
    public var cropFrame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) { didSet { applyRes { self.setNeedsRender() } } }
    
    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        return [cropFrame.minX, cropFrame.maxX, cropFrame.minY, cropFrame.maxY]
    }
    
}

public extension PIXOut {
    
    func _crop(_ cropFrame: CGRect) -> CropPIX {
        let cropPix = CropPIX()
        cropPix.name = ":crop:"
        cropPix.inPix = self as? PIX & PIXOut
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
