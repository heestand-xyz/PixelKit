//
//  CropPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-05.
//  Open Source - MIT License
//

import CoreGraphics

public class CropPIX: PIXSingleEffect {
    
    override open var shader: String { return "effectSingleCropPIX" }
    
    // MARK: - Public Properties
    
    var resScale: CGSize { return cropFrame.size }
    
    public var cropFrame: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) { didSet { applyRes { self.setNeedsRender() } } }
    public var cropLeft: CGFloat {
        get { return cropFrame.minX }
        set { cropFrame = CGRect(x: newValue, y: cropFrame.minY, width: cropFrame.width - (newValue - cropFrame.minX), height: cropFrame.height) }
    }
    public var cropRight: CGFloat {
        get { return cropFrame.maxX }
        set { cropFrame = CGRect(x: cropFrame.minX, y: cropFrame.minY, width: newValue, height: cropFrame.height) }
    }
    public var cropBottom: CGFloat {
        get { return cropFrame.minY }
        set { cropFrame = CGRect(x: cropFrame.minX, y: newValue, width: cropFrame.width, height: cropFrame.height - (newValue - cropFrame.minY)) }
    }
    public var cropTop: CGFloat {
        get { return cropFrame.maxY }
        set { cropFrame = CGRect(x: cropFrame.minX, y: cropFrame.minY, width: cropFrame.width, height: newValue) }
    }
    
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
