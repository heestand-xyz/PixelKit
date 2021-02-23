//
//  AveragePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-05.
//

import Foundation
import CoreGraphics
import RenderKit

/// Useful with **VoxelKit** to downsample depth images.
final public class AveragePIX: PIXSingleEffect, PIXViewable, ObservableObject {

    override public var shaderName: String { return "effectSingleAveragePIX" }

    // MARK: - Public Properties

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
        public var names: [String] {
            Self.allCases.map(\.rawValue)
        }
    }
    @LiveEnum(name: "Axis") public var axis: Axis = .z

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
