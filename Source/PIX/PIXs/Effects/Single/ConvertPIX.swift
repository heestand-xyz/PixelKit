//
//  ConvertPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-25.
//

import Foundation
import RenderKit
import CoreGraphics

final public class ConvertPIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleConvertPIX" }
    
    var resScale: CGSize {
        switch mode {
        case .domeToEqui: return CGSize(width: 2.0, height: 1.0)
        case .equiToDome: return CGSize(width: 0.5, height: 1.0)
        case .cubeToEqui: return CGSize(width: (3.0 / 4.0) * 2.0, height: 1.0)
//        case .equiToCube: return CGSize(width: (4.0 / 3.0) / 2.0, height: 1.0)
        case .squareToCircle: return CGSize(width: 1.0, height: 1.0)
        case .circleToSquare: return CGSize(width: 1.0, height: 1.0)
        }
    }
    
    // MARK: - Public Properties
    
    public enum ConvertMode: String, Enumable {
        case domeToEqui = "Dome to Equi"
        case equiToDome = "Equi to Dome"
        case cubeToEqui = "Cube to Equi"
//        case equiToCube
        case squareToCircle = "Square to Circle"
        case circleToSquare = "Circle to Square"
        public var index: Int {
            switch self {
            case .domeToEqui: return 0
            case .equiToDome: return 1
            case .cubeToEqui: return 2
//            case .equiToCube: return 3
            case .squareToCircle: return 4
            case .circleToSquare: return 5
            }
        }
        public var name: String { rawValue }
    }
    @LiveEnum(name: "Mode") public var mode: ConvertMode = .squareToCircle
    
    @LiveFloat(name: "X Rotation", range: -0.5...0.5) public var xRotation: CGFloat = 0.0
    @LiveFloat(name: "Y Rotation", range: -0.5...0.5) public var yRotation: CGFloat = 0.0
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_mode, _xRotation, _yRotation]
    }
    
    public override var uniforms: [CGFloat] {
        [CGFloat(mode.index), xRotation, yRotation]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Convert", typeName: "pix-effect-single-convert")
    }
    
}
