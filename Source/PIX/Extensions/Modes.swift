//
//  PIXModes.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

#if !os(tvOS) || !targetEnvironment(simulator)
import MetalPerformanceShaders
#endif

extension PIX {
    
    public enum SampleQualityMode: Int, Codable, CaseIterable {
        case low = 4
        case mid = 8
        case high = 16
        case extreme = 32
        case insane = 64
        case epic = 128
    }
    
}
