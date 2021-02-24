//
//  SlicePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import Foundation
import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to sample depth images.
final public class SlicePIX: PIXSingleEffect, PIXViewable, ObservableObject {
    
    override public var shaderName: String { return "effectSingleSlicePIX" }
    
    // MARK: - Public Properties
    
    @LiveFloat(name: "Fraction") public var fraction: CGFloat = 0.5
    public enum Axis: String, Enumable {
        case x = "X"
        case y = "Y"
        case z = "Z"
        public var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
        public var name: String { rawValue }
    }
    @LiveEnum(name: "Axis") public var axis: Axis = .z
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_fraction, _axis]
    }
    
    override public var values: [Floatable] {
        [fraction, axis]
    }
    
    public required init() {
        super.init(name: "Slice", typeName: "pix-effect-single-slice")
    }
}
