//
//  ArcPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class ArcPIX: PIXGenerator, Layoutable, PIXAuto {
    
    override open var shader: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var radius: LiveFloat = sqrt(0.75) / 4
    public var angleFrom: LiveFloat = -0.125
    public var angleTo: LiveFloat = 0.125
    public var angleOffset: LiveFloat = 0.0
    public var edgeRadius: LiveFloat = 0.05
    public var fillColor: LiveColor = .clear
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, fillColor, super.color, super.bgColor]
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            let positionFrom = LivePoint(x: position.x + cos(angleFrom) * radius, y: position.y + sin(angleFrom) * radius)
            let positionTo = LivePoint(x: position.x + cos(angleTo) * radius, y: position.y + sin(angleTo) * radius)
            let minPoint = LivePoint(x: min(positionFrom.x, positionTo.x), y: min(positionFrom.y, positionTo.y))
            let maxPoint = LivePoint(x: max(positionFrom.x, positionTo.x), y: max(positionFrom.y, positionTo.y))
            return LiveRect(origin: minPoint, size: (maxPoint - minPoint).size)
        }
        set {
            reFrame(to: frame)
        }
    }
    public var frameRotation: LiveFloat {
        get { return angleOffset }
        set { angleOffset = newValue }
    }
    
    public func reFrame(to frame: LiveRect) {}
    
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
