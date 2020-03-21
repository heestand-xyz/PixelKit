//
//  LUTPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-03-12.
//

import Foundation
import LiveValues
import RenderKit

public class LUTPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "" }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [LiveFloat(0), LiveFloat(0)]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
//        extend = .hold
        name = "LUT"
    }
    
    public static func lutMap() -> MetalPIX {
        let raw: Int = Int(pow(2.0, 8)) // 256
        let iRes: Int = Int(sqrt(Double(raw))) // 16
        let count: Int = Int(pow(Double(raw), 3)) // 16 777 216
        let xyRes: Int = Int(sqrt(Double(count))) // 4 096
        let res: Resolution = .square(xyRes)
        let uniIRes = MetalUniform(name: "ires", value: LiveFloat(iRes))
        return MetalPIX(at: res, uniforms: [uniIRes], code:
            """
            int ires = int(in.ires);
            int res = ires * ires;
            float qu = u * float(ires);
            float _u = qu - floor(qu);
            float qv = v * float(ires);
            float _v = qv - floor(qv);
            int ix = int(u * float(ires));
            int iy = int(v * float(ires));
            int iw = iy * ires + ix;
            float _w = float(iw) / float(res - 1);
            pix = float4(_u, _v, _w, 1.0);
            """
        )
    }
    
}

public extension NODEOut {
    
    func _lut(with pix: PIX & NODEOut) -> LUTPIX {
        let lutPix = LUTPIX()
        lutPix.name = ":LUT:"
        lutPix.inputA = self as? PIX & NODEOut
        lutPix.inputB = pix
        return lutPix
    }
    
}
