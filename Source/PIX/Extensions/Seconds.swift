import Foundation
import CoreGraphics

public extension Int {
    
    static var frameIndex: Int {
        PixelKit.main.render.frame
    }
    
    static var seconds: Int {
        Int(-PixelKit.main.startDate.timeIntervalSinceNow)
    }
    static var secondsSince1970: Int {
        Int(Date().timeIntervalSince1970)
    }
    
}

public extension CGFloat {
    
    static var frameIndex: CGFloat {
        CGFloat(Int.frameIndex)
    }
    
    static var seconds: CGFloat {
        CGFloat(-PixelKit.main.startDate.timeIntervalSinceNow)
    }
    static var secondsSince1970: CGFloat {
        CGFloat(Date().timeIntervalSince1970)
    }
    
    /// The **wave** retuns a value in the range of **0.0...1.0**
    static func wave(time: CGFloat) -> CGFloat {
        cos(.pi + time * .pi * 2.0) / 2.0 + 0.5
    }
    
    static func % (lhs: CGFloat, rhs: CGFloat) -> CGFloat {
        lhs.truncatingRemainder(dividingBy: rhs)
    }
    
}
