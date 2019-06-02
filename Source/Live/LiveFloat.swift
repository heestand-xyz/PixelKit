//
//  LiveFloat.swift
//  PixelKit
//
//  Created by Hexagons on 2018-11-23.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import simd

extension CGFloat {
    init(_ liveFloat: LiveFloat) {
        self = liveFloat.value
    }
}
extension Float {
    init(_ liveFloat: LiveFloat) {
        self = Float(liveFloat.value)
    }
}
extension Double {
    init(_ liveFloat: LiveFloat) {
        self = Double(liveFloat.value)
    }
}
//extension Int {
//    init(_ liveFloat: LiveFloat) {
//        self = Int(liveFloat.value)
//    }
//}

public class MetalUniform {
    public var name: String
    public var value: LiveFloat
    public init(name: String, value: LiveFloat = 0.0) {
        self.name = name
        self.value = value
    }
}

public class LiveFloat: LiveValue, /*Equatable, Comparable,*/ ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible/*, BinaryFloatingPoint */ {
    
    public var name: String?
    
    public var description: String {
        let _value: CGFloat = round(CGFloat(self) * 1_000) / 1_000
        return "live\(name != nil ? "[\(name!)]" : "")(\("\(_value)".zfill(3)))"
    }
    
    var liveValue: () -> (CGFloat)
    var value: CGFloat {
        guard limit else { return liveValue() }
        return Swift.max(Swift.min(liveValue(), max), min)
    }
    
    var limit: Bool = false
    var min: CGFloat = 0.0
    var max: CGFloat = 1.0
    
    public var cg: CGFloat {
        return value
    }
    public var double: Double {
        return Double(value)
    }
    
    public var uniform: CGFloat {
        get {
            uniformCache = CGFloat(self)
            return CGFloat(self)
        }
    }
    public var uniformIsNew: Bool {
        return uniformCache != CGFloat(self)
    }
    var uniformCache: CGFloat? = nil
    
    public static var pi: LiveFloat { return LiveFloat(CGFloat.pi) }
    
    //    public var year: LiveFloat!
    //    public var month: LiveFloat!
    //    public var day: LiveFloat!
    //    public var hour: LiveFloat!
    //    public var minute: LiveFloat!
    //    public var second: LiveFloat!
    public static var seconds: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelKit.main.seconds
        })
    }
    public static var secondsSince1970: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return CGFloat(Date().timeIntervalSince1970)
        })
    }
    
    var isFrozen: Bool = false
    public static var live: LiveFloat {
        var value: CGFloat = 0.0
        var lastFrame: Int = -1
        return LiveFloat({ () -> (CGFloat) in
            guard lastFrame != PixelKit.main.frame else {
                lastFrame = PixelKit.main.frame
                return value
            }
            if !self.live.isFrozen {
                value += 1.0 / CGFloat(PixelKit.main.fps)
            }
            lastFrame = PixelKit.main.frame
            return value
        })
    }
    public static var liveFinal: LiveFloat {
        var value: CGFloat = 0.0
        var lastFrame: Int = -1
        return LiveFloat({ () -> (CGFloat) in
            guard lastFrame != PixelKit.main.finalFrame else {
                lastFrame = PixelKit.main.finalFrame
                return value
            }
            if !self.live.isFrozen {
                value += 1.0 / CGFloat(PixelKit.main.finalFps ?? PixelKit.main.fpsMax)
            }
            lastFrame = PixelKit.main.finalFrame
            return value
        })
    }
    
    #if os(iOS)
    public static var motionGyroX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.gyroX
        })
    }
    public static var motionGyroY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.gyroY
        })
    }
    public static var motionGyroZ: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.gyroZ
        })
    }
    public static var motionAccelerationX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.accelerationX
        })
    }
    public static var motionAccelerationY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.accelerationY
        })
    }
    public static var motionAccelerationZ: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.accelerationZ
        })
    }
    public static var motionMagneticFieldX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.magneticFieldX
        })
    }
    public static var motionMagneticFieldY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.magneticFieldY
        })
    }
    public static var motionMagneticFieldZ: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.magneticFieldZ
        })
    }
    public static var motionDeviceAttitudeX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceAttitudeX
        })
    }
    public static var motionDeviceAttitudeY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceAttitudeY
        })
    }
    public static var motionDeviceAttitudeZ: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceAttitudeZ
        })
    }
    public static var motionDeviceGravityX: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceGravityX
        })
    }
    public static var motionDeviceGravityY: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceGravityY
        })
    }
    public static var motionDeviceGravityZ: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceGravityZ
        })
    }
    public static var motionDeviceHeading: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return PixelMotion.main.deviceHeading
        })
    }
    #endif
    
    #if os(iOS)
    
    public static var touch: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return Bool(LiveBool.touch) ? 1.0 : 0.0
        })
    }
    
    public static var touchX: LiveFloat {
        return LivePoint.touchXY.x
    }
    
    public static var touchY: LiveFloat {
        return LivePoint.touchXY.y
    }
    
    public static var touchForce: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            for pix in PixelKit.main.linkedPixs {
                guard pix.view.superview != nil else { continue }
                return pix.view.liveTouchView.force
            }
            return 0.0
        })
    }
    
    #elseif os(macOS)

    public static var mouseLeft: LiveFloat {
        return LiveBool.mouseLeft <?> 1.0 <=> 0.0
    }
    public static var mouseRight: LiveFloat {
        return LiveBool.mouseRight <?> 1.0 <=> 0.0
    }
    public static var mouseInView: LiveFloat {
        return LiveBool.mouseInView <?> 1.0 <=> 0.0
    }
    public static var mouseX: LiveFloat {
        return LivePoint.mouseXY.x
    }
    public static var mouseY: LiveFloat {
        return LivePoint.mouseXY.y
    }
    
    #endif
    
    public static var midiAny: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return MIDI.main.firstAny ?? 0.0
        })
    }
    
    public static var oscAny: LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            return OSC.main.firstAny ?? 0.0
        })
    }
    
    public init(_ liveValue: @escaping () -> (CGFloat)) {
        self.liveValue = liveValue
    }
    
    public init(_ liveInt: LiveInt) {
        liveValue = { return CGFloat(Int(liveInt)) }
    }
    
    public init(_ value: CGFloat, min: CGFloat? = nil, max: CGFloat? = nil) {
        liveValue = { return value }
        limit = min != nil || max != nil
        self.min = min ?? 0.0
        self.max = max ?? 1.0
    }
    public init(_ value: Float) {
        liveValue = { return CGFloat(value) }
    }
    public init(_ value: Double) {
        liveValue = { return CGFloat(value) }
    }
    required public init(floatLiteral value: FloatLiteralType) {
        liveValue = { return CGFloat(value) }
    }
    
    public init(_ value: Int) {
        liveValue = { return CGFloat(value) }
    }
    required public init(integerLiteral value: IntegerLiteralType) {
        liveValue = { return CGFloat(value) }
    }
    
//    public init(name: String, value: CGFloat, min: CGFloat, max: CGFloat) {
//        self.name = name
//        self.min = min
//        self.max = max
//        liveValue = { return value }
//    }
    
    // MARK: Assign
    
//    public static func = (lhs: inout LiveFloat, rhs: Double) {
//        lhs = LiveFloat(rhs)
//    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) == CGFloat(rhs) })
    }
    public static func != (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return !(lhs == rhs)
    }
//    public static func == (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return lhs.value == rhs
//    }
//    public static func == (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return lhs == rhs.value
//    }
    
    // MARK: Comparable
    
    public static func < (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) < CGFloat(rhs) })
    }
    public static func <= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) <= CGFloat(rhs) })
    }
    public static func > (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) > CGFloat(rhs) })
    }
    public static func >= (lhs: LiveFloat, rhs: LiveFloat) -> LiveBool {
        return LiveBool({ return CGFloat(lhs) >= CGFloat(rhs) })
    }
//    public s1tatic func < (lhs: LiveFloat, rhs: CGFloat) -> LiveBool {
//        return LiveFloat({ return lhs.value < rhs })
//    }
//    public static func < (lhs: CGFloat, rhs: LiveFloat) -> LiveBool {
//        return LiveFloat({ return lhs < rhs.value })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) + CGFloat(rhs) })
    }
    public static func += (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) + CGFloat(rhs) })
    }
    
    public static func - (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) - CGFloat(rhs) })
    }
    public static func -= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) - CGFloat(rhs) })
    }
    
    public static func * (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) * CGFloat(rhs) })
    }
    public static func *= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) * CGFloat(rhs) })
    }
    
    public static func / (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs) / CGFloat(rhs) })
    }
    public static func /= (lhs: inout LiveFloat, rhs: LiveFloat) {
        let _lhs = lhs; lhs = LiveFloat({ return CGFloat(_lhs) / CGFloat(rhs) })
    }
    
    
    public static func ** (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    public static func ^ (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return pow(CGFloat(lhs), 1.0 / CGFloat(rhs)) })
    }
    
    public static func % (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(lhs).truncatingRemainder(dividingBy: CGFloat(rhs)) })
    }
    
    
    public static func <> (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
        return LiveFloat({ return Swift.min(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    public static func >< (lhs: LiveFloat, rhs: LiveFloat) -> LiveFloat {
       return LiveFloat({ return Swift.max(CGFloat(lhs), CGFloat(rhs)) })
    }
    
    
    public prefix static func - (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return -CGFloat(operand) })
    }
    
    public prefix static func ! (operand: LiveFloat) -> LiveFloat {
        return LiveFloat({ return 1.0 - CGFloat(operand) })
    }
    
    
    public static func <=> (lhs: LiveFloat, rhs: LiveFloat) -> (LiveFloat, LiveFloat) {
        return (lhs, rhs)
    }
    
    // MARK: Flow Funcs
    
    public func delay(frames: LiveInt) -> LiveFloat {
        var cache: [CGFloat] = []
        return LiveFloat({ () -> (CGFloat) in
            cache.append(CGFloat(self))
            if cache.count > Int(frames) {
                return cache.remove(at: 0)
            }
            return cache.first!
        })
    }
    
    public func delay(seconds: LiveFloat) -> LiveFloat {
        var cache: [(date: Date, value: CGFloat)] = []
        return LiveFloat({ () -> (CGFloat) in
            let delaySeconds = max(Double(seconds), 0)
            guard delaySeconds > 0 else {
                return CGFloat(self)
            }
            cache.append((date: Date(), value: CGFloat(self)))
            for _ in cache {
                if -cache.first!.date.timeIntervalSinceNow > delaySeconds {
                    cache.remove(at: 0)
                    continue
                }
                break
            }
            return cache.first!.value
        })
    }
    
    /// filter over frames.
    public func filter(frames: LiveInt, bypassLower: Bool = false, bypassHigher: Bool = false) -> LiveFloat {
        var cache: [CGFloat] = []
        PixelKit.main.listenToFrames(callback: {
            cache.append(CGFloat(self))
            while cache.count > Int(frames) {
                cache.remove(at: 0)
            }
        })
        return LiveFloat({ () -> (CGFloat) in
            var filteredValue: CGFloat = 0.0
            for value in cache {
                filteredValue += value
            }
            filteredValue /= CGFloat(cache.count)
            if bypassLower {
                return min(CGFloat(self), filteredValue)
            } else if bypassHigher {
                return max(CGFloat(self), filteredValue)
            }
            return filteredValue
        })
    }
    
    /// filter over seconds. smooth off is linear. smooth on is cosine smoothness (default)
    public func filter(seconds: LiveFloat, smooth: Bool = true, bypassLower: Bool = false, bypassHigher: Bool = false) -> LiveFloat {
        var cache: [(date: Date, value: CGFloat)] = []
        return LiveFloat({ () -> (CGFloat) in
            let delaySeconds = max(Double(seconds), 0)
            guard delaySeconds > 0 else {
                return CGFloat(self)
            }
            let value = CGFloat(self)
            let dateValue = (date: Date(), value: value)
            cache.append(dateValue)
            for _ in cache {
                if -cache.first!.date.timeIntervalSinceNow > delaySeconds {
                    cache.remove(at: 0)
                    continue
                }
                break
            }
            guard cache.count > 1 else {
                return cache[0].value
            }
            guard cache.count > 2 else {
                return (cache[0].value + cache[1].value) / 2
            }
            var filteredValue: CGFloat = 0.0
            var weight: CGFloat = smooth ? 0.0 : CGFloat(cache.count)
            for (i, dateValue) in cache.enumerated() {
                let fraction = CGFloat(i) / CGFloat(cache.count - 1)
                let smoothWeight: CGFloat = 1.0 - (cos(fraction * .pi * 2) / 2 + 0.5)
                filteredValue += dateValue.value * (smooth ? smoothWeight : 1.0)
                weight += smoothWeight
            }
            filteredValue /= weight
            if bypassLower && value < filteredValue {
                cache = [dateValue]
                return value
            }
            if bypassHigher && value > filteredValue {
                cache = [dateValue]
                return value
            }
            return filteredValue
        })
    }
    
    /// noise is a combo of liveRandom and smooth filter
    ///
    /// deafults - liveRandom range: 0.0...1.0 - filter seconds: 1.0
    public static func noise(range: ClosedRange<CGFloat> = 0...1.0, seconds: LiveFloat = 1.0) -> LiveFloat {
        return LiveFloat.liveRandom(in: range).filter(seconds: seconds, smooth: true)
    }
    
    public static func wave(range: ClosedRange<CGFloat> = 0...1.0, seconds: LiveFloat = 1.0) -> LiveFloat {
        return (cos((self.seconds / seconds) * .pi * 2) / -2 + 0.5).lerp(from: LiveFloat(range.lowerBound), to: LiveFloat(range.upperBound))
    }

//    public static func range(from rangeA: ClosedRange<CGFloat> = 0...1.0, to rangeB: ClosedRange<CGFloat> = 0...1.0) -> LiveFloat {
//        return self...
//    }

    func lerp(from: LiveFloat, to: LiveFloat) -> LiveFloat {
        return from * (1.0 - self) + to * self
    }
    
    // MARK: Local Funcs
    
    public func truncatingRemainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(self).truncatingRemainder(dividingBy: CGFloat(other)) })
    }

    public func remainder(dividingBy other: LiveFloat) -> LiveFloat {
        return LiveFloat({ return CGFloat(self).remainder(dividingBy: CGFloat(other)) })
    }
    
    public static func random(in range: Range<CGFloat>) -> LiveFloat {
        return LiveFloat(CGFloat.random(in: range))
    }
    public static func random(in range: ClosedRange<CGFloat>) -> LiveFloat {
        return LiveFloat(CGFloat.random(in: range))
    }
    
    public static func liveRandom(in range: Range<CGFloat>) -> LiveFloat {
        return LiveFloat({ return CGFloat.random(in: range) })
    }
    public static func liveRandom(in range: ClosedRange<CGFloat>) -> LiveFloat {
        return LiveFloat({ return CGFloat.random(in: range) })
    }
    
    /// find addresses with `MIDI.main.log = true`
    public static func midi(_ address: String) -> LiveFloat {
        return LiveFloat({ return MIDI.main.list[address] ?? 0.0 })
    }
    
    /// find addresses with `OSC.main.log = true`
    public static func osc(_ address: String) -> LiveFloat {
        return LiveFloat({ return OSC.main.list[address] ?? 0.0 })
    }
    
    public func log(_ message: String? = nil) -> LiveFloat {
        return LiveFloat({ () -> (CGFloat) in
            print("Live Log - \(message != nil ? "\"" + message! + "\" - " : "")\(self.description)")
            return self.cg
        })
    }

}


// MARK: Global Funcs

public func relative(_ live: LiveFloat) -> LiveFloat {
    var value: CGFloat = 0.0
    return LiveFloat({
        value += CGFloat(live)
        return value
    })
}

public func min(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return min(CGFloat(live1), CGFloat(live2)) })
}
public func max(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return max(CGFloat(live1), CGFloat(live2)) })
}

public func round(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return round(CGFloat(live)) })
}
public func floor(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return floor(CGFloat(live)) })
}
public func ceil(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return ceil(CGFloat(live)) })
}

public func sqrt(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return sqrt(CGFloat(live)) })
}
public func pow(_ live: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return pow(CGFloat(live), CGFloat(live2)) })
}
public func abs(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return abs(CGFloat(live)) })
}
public func sign(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return CGFloat(sign(Double(live))) })
}

public func cos(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return cos(CGFloat(live)) })
}
public func sin(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return sin(CGFloat(live)) })
}
public func atan(_ live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan(CGFloat(live)) })
}
public func atan2(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return atan2(CGFloat(live1), CGFloat(live2)) })
}
public func angle(of point: LivePoint) -> LiveFloat {
    return atan(of: point) / (.pi * 2)
}

public func maximum(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return Swift.max(CGFloat(live1), CGFloat(live2)) })
}
public func minimum(_ live1: LiveFloat, _ live2: LiveFloat) -> LiveFloat {
    return LiveFloat({ return Swift.min(CGFloat(live1), CGFloat(live2)) })
}

// MARK: New Global Funcs

public func deg(rad live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (CGFloat(live) / .pi / 2.0) * 360.0 })
}
public func rad(deg live: LiveFloat) -> LiveFloat {
    return LiveFloat({ return (CGFloat(live) / 360.0) * .pi * 2.0 })
}

public func freeze(_ live: LiveFloat, _ frozen: LiveBool) -> LiveFloat {
    var frozenLive: CGFloat? = nil
    return LiveFloat({
        live.isFrozen = frozen.value
        if !live.isFrozen {
            frozenLive = live.value
        }
        return live.isFrozen ? frozenLive ?? 0.0 : live.value
    })
}
