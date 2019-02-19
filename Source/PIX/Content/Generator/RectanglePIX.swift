//
//  RectanglePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class RectanglePIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorRectanglePIX" }
    
    // MARK: - Public Properties
    
    public var size: LiveSize = LiveSize(w: sqrt(0.75) / 2, h: sqrt(0.75) / 2)
    public var position: LivePoint = .zero
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [size, position, color, bgColor]
    }
    
}
