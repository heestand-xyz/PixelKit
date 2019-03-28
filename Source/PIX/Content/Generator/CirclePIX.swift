//
//  CirclePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

public class CirclePIX: PIXGenerator {
    
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
    
}
