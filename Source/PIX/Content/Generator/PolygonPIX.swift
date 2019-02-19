//
//  PolygonPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//
import CoreGraphics//x

public class PolygonPIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var radius: LiveFloat = 0.25
    public var position: LivePoint = .zero
    public var rotation: LiveFloat = 0.0
    public var vertexCount: LiveInt = 6
    public var color: LiveColor = .white
    public var bgColor: LiveColor = .black
   
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [radius, position, rotation, vertexCount, color, bgColor]
    }
    
}
