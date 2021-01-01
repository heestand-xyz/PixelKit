//
//  LinePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import LiveValues
import RenderKit

public class LinePIX: PIXGenerator, Layoutable, PIXAuto {
    
    override open var shaderName: String { return "contentGeneratorLinePIX" }
    
    // MARK: - Public Properties
    
    public var positionFrom: CGPoint = CGPoint(x: -0.25, y: -0.25)
    public var positionTo: CGPoint = CGPoint(x: 0.25, y: 0.25)
    public var scale: CGFloat = CGFloat(0.01, max: 0.1)
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [positionFrom, positionTo, scale, super.color, super.bgColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Line", typeName: "pix-content-generator-line")
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            let minPoint = CGPoint(x: min(positionFrom.x, positionTo.x), y: min(positionFrom.y, positionTo.y))
            let maxPoint = CGPoint(x: max(positionFrom.x, positionTo.x), y: max(positionFrom.y, positionTo.y))
            return LiveRect(origin: minPoint, size: (maxPoint - minPoint).size)
        }
        set {
            reFrame(to: newValue)
        }
    }
    public var frameRotation: CGFloat {
        get { return 0 }
        set {}
    }
    
    public func reFrame(to frame: LiveRect) {}
    
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: CGFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: CGFloat = 0.0) {
        anchorX(targetXAnchor, to: layoutable.frame, sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: CGFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: CGFloat = 0.0) {
        anchorY(targetYAnchor, to: layoutable.frame, sourceYAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: CGFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, toBoundAnchor: sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: CGFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, toBoundAnchor: sourceYAnchor, constant: constant)
    }
    
}
