//
//  BlendPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

import CoreGraphics

public class BlendPIX: PIXMergerEffect, Layoutable, PIXAuto {
    
    override open var shader: String { return "effectMergerBlendPIX" }
    
    // MARK: - Public Properties
    
    public var mode: BlendingMode = .add { didSet { setNeedsRender() } }
    public var bypassTransform: LiveBool = false
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var scale: LiveFloat = 1.0
    public var size: LiveSize = LiveSize(w: 1.0, h: 1.0)
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [bypassTransform, position, rotation, scale, size]
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(mode.index), !bypassTransform.uniform ? 1 : 0, position.x.uniform, position.y.uniform, rotation.uniform, scale.uniform, size.width.uniform, size.height.uniform]
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            guard placement == .custom else { return LiveRect(x: 0, y: 0, w: 0, h: 0) }
            return LiveRect(center: position, size: LiveSize(scale: scale) * size)
        }
        set {
            reFrame(to: frame)
        }
    }
    public var frameRotation: LiveFloat {
        get { return rotation }
        set { rotation = newValue }
    }
    
    public func reFrame(to frame: LiveRect) {
        placement = .custom
        position = frame.center
        scale = 1.0
        size = frame.size
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

