//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-12-14.
//

import CoreGraphics
import RenderKit
import PixelColor

@available(*, deprecated, renamed: "ColorStop")
public typealias ColorStep = ColorStop

public struct ColorStop: Floatable, Codable, Equatable {
    public var stop: CGFloat
    public var color: PixelColor
    public init(_ stop: CGFloat, _ color: PixelColor) {
        self.stop = stop
        self.color = color
    }
    public var floats: [CGFloat] {
        [stop, color.red, color.green, color.blue, color.alpha]
    }
    public init(floats: [CGFloat]) {
        guard floats.count == 5 else { self = ColorStop(0.0, .clear); return }
        self = ColorStop(floats[0], PixelColor(red: floats[1], green: floats[2], blue: floats[3], alpha: floats[4]))
    }
}

extension Array: Floatable where Element == ColorStop {
    public var floats: [CGFloat] { flatMap(\.floats) }
    public init(floats: [CGFloat]) {
        guard floats.count % 5 == 0 else { self = []; return }
        let count: Int = floats.count / 5
        var colorStops: [ColorStop] = []
        for i in 0..<count {
            let subFloats: [CGFloat] = Array<CGFloat>(floats[(i * 5)..<((i + 1) * 5)])
            let colorStop: ColorStop = ColorStop(floats: subFloats)
            colorStops.append(colorStop)
        }
        self = colorStops
    }
}
