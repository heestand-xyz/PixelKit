//
//  CirclePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//


import RenderKit

public class CirclePIX: PIXGenerator, Layoutable, PIXAuto {
    
    // MARK: - Public Properties
    
    public var radius: CGFloat = CGFloat(0.25, max: 0.5)
    public var position: CGPoint = .zero
    public var edgeRadius: CGFloat = CGFloat(0.0, max: 0.25)
    public var edgeColor: PXColor = .gray
    
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
    public var frameRotation: CGFloat {
        get { return 0 }
        set {}
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center
        radius = frame.h / 2
    }
    
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
