//
//  AveragePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to downsample depth images.
final public class AveragePIX: PIXSingleEffect, PIXViewable {

    override public var shaderName: String { return "effectSingleAveragePIX" }

    // MARK: - Public Properties

    public enum Axis: Floatable {
        case x
        case y
        case z
        var index: Int {
            switch self {
            case .x: return 0
            case .y: return 1
            case .z: return 2
            }
        }
        public var floats: [CGFloat] { [CGFloat(index)] }
        public init(floats: [CGFloat]) {
            let index: Int = Int(floats.first ?? 0.0)
            switch index {
            case 0:
                self = .x
            case 1:
                self = .y
            case 2:
                self = .z
            default:
                self = .x
            }
        }
    }
    @Live public var axis: Axis = .z

    // MARK: - Property Helpers

    public override var liveList: [LiveWrap] {
        [_axis]
    }

    public override var values: [Floatable] {
        [axis]
    }

    public required init() {
        super.init(name: "Average", typeName: "")
    }

}
