//
//  ColorPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//
import CoreGraphics//x

public class ColorPIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorColorPIX" }
    
    // MARK: - Public Properties
    
    public var color: LiveColor = .white { didSet { setNeedsRender() } }
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [color]
    }
    
}
