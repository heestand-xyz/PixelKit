//
//  LinePIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-03-28.
//  Copyright © 2019 Hexagons. All rights reserved.
//

public class LinePIX: PIXGenerator {
    
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
    
}
