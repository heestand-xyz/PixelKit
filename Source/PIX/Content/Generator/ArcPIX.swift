//
//  ArcPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class ArcPIX: PIXGenerator {
    
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
    
}
