//
//  DistancePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-09-16.
//

import Foundation
import RenderKit
import Resolution
import CoreGraphics

final public class DistancePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "distancePIX" }
    
//    public enum Style: String, Enumable {
//        case linear
//        case subdivided
//        public var index: Int {
//            switch self {
//            case .linear:
//                return 0
//            case .subdivided:
//                return 1
//            }
//        }
//        public var name: String {
//            switch self {
//            case .linear:
//                return "Linear"
//            case .subdivided:
//                return "Subdivided"
//            }
//        }
//        public var typeName: String {
//            rawValue
//        }
//    }
    
    // MARK: Live Values
    
//    @LiveEnum("style") public var style: Style = .linear
    @LiveInt("count", range: 2...100) public var count: Int = 32
    @LiveFloat("distance", range: 0.01...0.1, increment: 0.01) public var distance: CGFloat = 0.02
    @LiveFloat("threshold") public var threshold: CGFloat = 0.0
    @LiveFloat("brightness") public var brightness: CGFloat = 0.5

    public override var liveList: [LiveWrap] {
        [_count, _distance, _threshold, _brightness]
    }
    
    public override var values: [Floatable] {
        [0, count, distance, threshold, brightness]
    }
    
    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Distance", typeName: "pix-effect-single-distance")
    }
    
}
