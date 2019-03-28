//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

public class CirclePIX: PIXGenerator, Layoutable {
    
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
            reFrame(to: frame)
        }
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center
        radius = frame.w / 2
    }
    public func reFrame(to layoutable: Layoutable) {
        frame = layoutable.frame
    }
    
    public func anchor(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor) {
        Layout.anchor(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor)
    }
    public func anchor(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor) {
        anchor(targetXAnchor, to: layoutable.frame, sourceXAnchor)
    }
    public func anchor(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor) {
        Layout.anchor(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor)
    }
    public func anchor(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor) {
        anchor(targetYAnchor, to: layoutable.frame, sourceYAnchor)
    }
    
}
