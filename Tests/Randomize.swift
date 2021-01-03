//
//  Randomize.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-17.
//


import PixelKit_macOS

class Randomize {
    
    static let randomCount: Int = 10
    
    static func randomizeGenerator(auto: AutoPIXGenerator, with pix: PIXGenerator, at index: Int) {
        randomzeFloats(auto.autoCGFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoCGPoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoPixelColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    static func randomizeSingleEffect(auto: AutoPIXSingleEffect, with pix: PIXSingleEffect, at index: Int) {
        randomzeFloats(auto.autoCGFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoCGPoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoPixelColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    static func randomizeMergerEffect(auto: AutoPIXMergerEffect, with pix: PIXMergerEffect, at index: Int) {
        randomzeFloats(auto.autoCGFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoCGPoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoPixelColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    static func randomzeFloats(_ values: [AutoCGFloatProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 1_000 + UInt64(index))
        for value in values {
            let random: CGFloat = .random(in: value.value.min...value.value.max, using: &gen)
            value.value = CGFloat(random, min: value.value.min, max: value.value.max)
        }
    }
    
    static func randomzeInts(_ values: [AutoLiveIntProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 2_000 + UInt64(index))
        for value in values {
            let random: Int = .random(in: value.value.min...value.value.max, using: &gen)
            value.value = LiveInt(random, min: value.value.min, max: value.value.max)
        }
    }
    
    static func randomzeBools(_ values: [AutoLiveBoolProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 3_000 + UInt64(index))
        for value in values {
            let random: Bool = .random(using: &gen)
            value.value = LiveBool(random)
        }
    }
    
    static func randomzePoints(_ values: [AutoCGPointProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 4_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 4_100 + UInt64(index))
        for value in values {
            let randomX: CGFloat = .random(in: -0.5...0.5, using: &gen1)
            let randomY: CGFloat = .random(in: -0.5...0.5, using: &gen2)
            value.value = CGPoint(CGPoint(x: randomX, y: randomY))
        }
    }
    
    static func randomzeSizes(_ values: [AutoLiveSizeProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 5_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 5_100 + UInt64(index))
        for value in values {
            let randomW: CGFloat = .random(in: 0.0...1.0, using: &gen1)
            let randomH: CGFloat = .random(in: 0.0...1.0, using: &gen2)
            value.value = LiveSize(CGSize(width: randomW, height: randomH))
        }
    }
    
    static func randomzeRects(_ values: [AutoLiveRectProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 6_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 6_100 + UInt64(index))
        var gen3 = ArbitraryRandomNumberGenerator(seed: 6_200 + UInt64(index))
        var gen4 = ArbitraryRandomNumberGenerator(seed: 6_300 + UInt64(index))
        for value in values {
            let randomX: CGFloat = .random(in: -0.5...0.5, using: &gen1)
            let randomY: CGFloat = .random(in: -0.5...0.5, using: &gen2)
            let randomW: CGFloat = .random(in: 0.0...1.0, using: &gen3)
            let randomH: CGFloat = .random(in: 0.0...1.0, using: &gen4)
            value.value = LiveRect(CGRect(x: randomX, y: randomY, width: randomW, height: randomH))
        }
    }
    
    static func randomzeColors(_ values: [AutoPixelColorProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 7_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 7_100 + UInt64(index))
        var gen3 = ArbitraryRandomNumberGenerator(seed: 7_200 + UInt64(index))
        var gen4 = ArbitraryRandomNumberGenerator(seed: 7_300 + UInt64(index))
        for value in values {
            let randomR: CGFloat = .random(in: 0.0...1.0, using: &gen1)
            let randomG: CGFloat = .random(in: 0.0...1.0, using: &gen2)
            let randomB: CGFloat = .random(in: 0.0...1.0, using: &gen3)
            let randomA: CGFloat = .random(in: 0.0...1.0, using: &gen4)
            value.value = PixelColor(NSColor(deviceRed: randomR, green: randomG, blue: randomB, alpha: randomA))
        }
    }
    
    static func randomzeEnums(_ values: [AutoEnumProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 8_000 + UInt64(index))
        for value in values {
            let random: Int = .random(in: 0..<value.cases.count, using: &gen)
            value.value = value.cases[random]
        }
    }
    
}
