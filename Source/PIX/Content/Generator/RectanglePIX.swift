//
//  RectanglePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class RectanglePIX: PIXGenerator, Layoutable {
    
    override open var shader: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var size: LiveSize = LiveSize(w: sqrt(0.75) / 2, h: sqrt(0.75) / 2)
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [size, position, color, bgColor]
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position, size: size)
        }
        set {
            reFrame(to: frame)
        }
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center
        size = frame.size
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
