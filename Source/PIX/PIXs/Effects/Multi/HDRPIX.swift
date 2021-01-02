//
//  HDRPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-20.
//  Open Source - MIT License
//



/// The HDR PIX is currently optimized for 3 exposures.
///
/// `.inputs = [lowPix, midPix, highPix]`
public class HDRPIX: PIXMultiEffect {
    
    override open var shaderName: String { return "effectMultiHDRPIX" }
    
    // MARK: - Public Properties
    
    /// A negative exposure value (ev), relative to the mid exposure.
    ///
    /// Example: "low" shutter speed of `1/8000` relative to a "mid" shutter speed of `1/4000` results in an ev of `-1.0`
    /// *default* value is `-1.0`
    public var lowEV: CGFloat = -1.0
    /// A positive exposure value (ev), relative to the mid exposure.
    ///
    /// Example: "high" shutter speed of `1/1000` relative to a "mid" shutter speed of `1/4000` results in an ev of `2.0`
    /// *default* value is `1.0`
    public var highEV: CGFloat = 1.0
    
    // MARK: - Property Helpers
    
    public override var liveValues: [LiveValue] {
        [
            lowEV,
            highEV,
        ]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "HDR", typeName: "pix-effect-multi-hdr")
    }
    
}
