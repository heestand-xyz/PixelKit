//
//  CirclePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

import LiveValues
import RenderKit

public class CirclePIX: PIXGenerator, Layoutable, PIXAuto {
    
    override open var shaderName: String { return "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    public var radius: LiveFloat = LiveFloat(0.25, max: 0.5)
    public var position: LivePoint = .zero
    public var edgeRadius: LiveFloat = LiveFloat(0.0, max: 0.25)
    public var edgeColor: LiveColor = .gray
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, position, edgeRadius, super.color, edgeColor, super.bgColor]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Circle", typeName: "pix-content-generator-circle")
    }

    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position, size: LiveSize(scale: radius * 2 + edgeRadius))
        }
        set {
            reFrame(to: newValue)
        }
    }
    public var frameRotation: LiveFloat {
        get { return 0 }
        set {}
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center
        radius = frame.h / 2
    }
    
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        anchorX(targetXAnchor, to: layoutable.frame, sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        anchorY(targetYAnchor, to: layoutable.frame, sourceYAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, toBoundAnchor: sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, toBoundAnchor: sourceYAnchor, constant: constant)
    }
    
    
}
