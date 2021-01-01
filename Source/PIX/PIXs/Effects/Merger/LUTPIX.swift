//
//  LUTPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-03-12.
//

import Foundation
import CoreGraphics

import RenderKit

// LUT == Lookup Table

public class LUTPIX: PIXMergerEffect, PIXAuto {
    
    override open var shaderName: String { return "effectMergerLUTPIX" }
    
    // MARK: - Public Properties
    
    public override var uniforms: [CGFloat] { [CGFloat(PixelKit.main.render.bits.rawValue)] }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "LUT", typeName: "pix-effect-merger-lut")
//        extend = .hold
    }
    
    public static func lutMap(bitCount: Int = 8) -> MetalPIX {
        let raw: Int = Int(pow(2.0, Double(bitCount))) // 256
        let iRes: Int = Int(sqrt(Double(raw))) // 16
        let count: Int = Int(pow(Double(raw), 3)) // 16_777_216
        let xyRes: Int = Int(sqrt(Double(count))) // 4_096
        let res: Resolution = .square(xyRes)
        let uniIRes = MetalUniform(name: "ires", value: CGFloat(iRes))
        return MetalPIX(at: res, uniforms: [uniIRes], code:
            """
            int ires = int(in.ires);
            int raw = ires * ires;
            int xyres = raw * ires;
            int x = int(u * float(xyres));
            int y = int(v * float(xyres));
            float _u = float(x % raw) / float(raw - 1);
            float _v = float(y % raw) / float(raw - 1);
            int ix = int(u * float(ires));
            int iy = int(v * float(ires));
            int iw = iy * ires + ix;
            float _w = float(iw) / float(raw - 1);
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
