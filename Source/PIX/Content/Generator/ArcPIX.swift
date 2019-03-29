//
//  ArcPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class ArcPIX: PIXGenerator, Layoutable {
    
    override open var shader: String { return "contentGeneratorArcPIX" }
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var radius: LiveFloat = sqrt(0.75) / 4
    public var angleFrom: LiveFloat = -0.125
    public var angleTo: LiveFloat = 0.125
    public var angleOffset: LiveFloat = 0.0
    public var edgeRadius: LiveFloat = 0.05
    public var fillColor: LiveColor = .black
    public var edgeColor: LiveColor = .white
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, angleFrom, angleTo, angleOffset, position, edgeRadius, fillColor, edgeColor, bgColor]
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
    
    public func reFrame(to frame: LiveRect) {}
    public func reFrame(to layoutable: Layoutable) {
        frame = layoutable.frame
    }
    
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor) {
        Layout.anchorX(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor) {
        anchorX(targetXAnchor, to: layoutable.frame, sourceXAnchor)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor) {
        Layout.anchorY(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor) {
        anchorY(targetYAnchor, to: layoutable.frame, sourceYAnchor)
    }
    
}
