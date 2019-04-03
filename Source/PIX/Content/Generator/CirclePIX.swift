//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

public class CirclePIX: PIXGenerator, Layoutable, PIXAuto {
    
    override open var shader: String { return "contentGeneratorCirclePIX" }
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var radius: LiveFloat = sqrt(0.75) / 4
    public var edgeRadius: LiveFloat = 0.0
    public var color: LiveColor = .white
    public var edgeColor: LiveColor = .gray
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, position, edgeRadius, color, edgeColor, bgColor]
    }

    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position, size: LiveSize(scale: radius * 2 + edgeRadius))
        }
        set {
            reFrame(to: frame, update: false)
        }
    }
    
    public func reFrame(to frame: LiveRect, update: Bool = true) {
        position = frame.center
        radius = frame.w / 2
        if update { self.frame = frame }
    }
    public func reFrame(to layoutable: Layoutable) {
        reFrame(to: layoutable.frame)
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
