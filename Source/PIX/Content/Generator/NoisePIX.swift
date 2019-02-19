//
//  NoisePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-14.
//  Open Source - MIT License
//
import CoreGraphics//x

public class NoisePIX: PIXGenerator {
    
    override open var shader: String { return "contentGeneratorNoisePIX" }
    
    // MARK: - Public Properties
    
    public var seed: LiveInt = LiveInt.random(in: 0..<100)
    public var octaves: LiveInt = 10
    public var position: LivePoint = .zero
    public var zPosition: LiveFloat = 0.0
    public var zoom: LiveFloat = 1.0
    public var colored: LiveBool = false
    public var random: LiveBool = false
    
    // MARK: - Property Helpers
    
    override var liveValues: [LiveValue] {
        return [seed, octaves, position, zPosition, zoom, colored, random]
    }
    
//    // MARK: - Life Cycle
//
//    public init(res: Res, seed: Int = Int.random(in: 0...1000), octaves: Int = 7, colored: Bool = false, random: Bool = false) {
//        self.seed = seed
//        self.octaves = octaves
//        self.colored = colored
//        self.random = random
//        super.init(res: res)
//    }
    
}
