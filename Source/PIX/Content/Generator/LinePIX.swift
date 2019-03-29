//
//  LinePIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class LinePIX: PIXGenerator, Layoutable {
    
    override open var shader: String { return "contentGeneratorLinePIX" }
    
    // MARK: - Public Properties
    
    public var positionFrom: LivePoint = LivePoint(x: -0.25, y: -0.25)
    public var positionTo: LivePoint = LivePoint(x: 0.25, y: 0.25)
    public var scale: LiveFloat = 0.01
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [positionFrom, positionTo, scale, color, bgColor]
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
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
