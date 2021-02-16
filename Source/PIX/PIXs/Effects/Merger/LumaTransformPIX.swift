//
//  LumaTransformPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-06-02.
//  Open Source - MIT License
//

import Foundation
import RenderKit
import CoreGraphics

final public class LumaTransformPIX: PIXMergerEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectMergerLumaTransformPIX" }
    
    // MARK: - Public Properties
    
    @Live public var position: CGPoint = .zero
    @Live public var rotation: CGFloat = 0.0
    @Live public var scale: CGFloat = 1.0
    @Live public var size: CGSize = CGSize(width: 1.0, height: 1.0)
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_position, _rotation, _scale, _size] + super.liveList
    }
    
    override public var values: [Floatable] {
        [position, rotation, scale, size]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Luma Transform", typeName: "pix-effect-merger-luma-transform")
    }
    
}

public extension NODEOut {
    
    func pixLumaTranform(position: CGPoint = .zero,
                         rotation: CGFloat = 0.0,
                         scale: CGFloat = 1.0,
                         size: CGSize = CGSize(width: 1.0, height: 1.0),
                         pix: () -> (PIX & NODEOut)) -> LumaTransformPIX {
        pixLumaTranform(pix: pix(), position: position, rotation: rotation, scale: scale, size: size)
    }
    func pixLumaTranform(pix: PIX & NODEOut,
                         position: CGPoint = .zero,
                         rotation: CGFloat = 0.0,
                         scale: CGFloat = 1.0,
                         size: CGSize = CGSize(width: 1.0, height: 1.0)) -> LumaTransformPIX {
        let lumaTranformPix = LumaTransformPIX()
        lumaTranformPix.name = ":lumaTranformPix:"
        lumaTranformPix.inputA = self as? PIX & NODEOut
        lumaTranformPix.inputB = pix
        
        return lumaTranformPix
    }
    
}

