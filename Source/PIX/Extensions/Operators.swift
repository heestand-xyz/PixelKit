//
//  PIXOperators.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-04.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

infix operator ++
infix operator --
infix operator **
infix operator !**
infix operator !&
infix operator <>
infix operator ><
infix operator ~
infix operator °
infix operator <->
//infix operator <+>
infix operator >-<
//infix operator >+<
infix operator +-+
prefix operator °

public extension PIX {
    
    static let blendOperators = BlendOperators()
    
    class BlendOperators {
        
        public var globalPlacement: Placement = .fit
        
        func blend(_ pixA: PIX, _ pixB: PIX & NODEOut, blendingMode: BlendMode) -> BlendPIX {
            let pixA = (pixA as? PIX & NODEOut) ?? ColorPIX(at: ._128) // CHECK
            let blendPix = BlendPIX()
            blendPix.name = operatorName(of: blendingMode)
            blendPix.blendMode = blendingMode
            blendPix.bypassTransform = true
            blendPix.placement = globalPlacement
            blendPix.inputA = pixA
            blendPix.inputB = pixB
            return blendPix
        }
        
        func blend(_ pix: PIX, _ color: PixelColor, blendingMode: BlendMode) -> BlendPIX {
            let colorPix = ColorPIX(at: .custom(w: 1, h: 1))
            colorPix.color = color
            if [.addWithAlpha, .subtractWithAlpha].contains(blendingMode) {
                colorPix.premultiply = false
            }
            let blendPix = blend(pix, colorPix, blendingMode: blendingMode)
            blendPix.extend = .hold
            return blendPix
        }
        
        func blend(_ pix: PIX, _ val: CGFloat, blendingMode: BlendMode) -> BlendPIX {
            let color: PixelColor
            switch blendingMode {
            case .addWithAlpha, .subtractWithAlpha:
                color = PixelColor(white: val, alpha: val)
            default:
                color = PixelColor(white: val)
            }
            return blend(pix, color, blendingMode: blendingMode)
        }
        
        func blend(_ pix: PIX, _ val: CGPoint, blendingMode: BlendMode) -> BlendPIX {
            return blend(pix, PixelColor(red: val.x, green: val.y, blue: 0.0, alpha: 1.0), blendingMode: blendingMode)
        }
        
        public func operatorName(of blendingMode: BlendMode) -> String {
            switch blendingMode {
            case .over: return "&"
            case .under: return "!&"
            case .add: return "+"
            case .addWithAlpha: return "++"
            case .multiply: return "*"
            case .difference: return "%"
            case .subtract: return "-"
            case .subtractWithAlpha: return "--"
            case .maximum: return "><"
            case .minimum: return "<>"
            case .gamma: return "!**"
            case .power: return "**"
            case .divide: return "/"
            case .average: return "~"
            case .cosine: return "°"
            case .inside: return "<->"
            case .outside: return ">-<"
            case .exclusiveOr: return "+-+"
            }
        }
        
    }
    
    static func +(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    
    static func ++(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    
    static func -(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    
    static func --(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    
    static func *(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    
    static func **(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    
    static func !**(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    
    static func &(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    
    static func !&(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    
    static func %(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    
    static func <>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    
    static func ><(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    
    static func /(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    
    static func ~(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    
    static func °(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    
    static func <->(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    
//    static func <+>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: CGFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: PixelColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
    
    static func >-<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    
//    static func >+<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: CGFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: PixelColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
    
    static func +-+(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: PixelColor, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: PixelColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    
    prefix static func ! (operand: PIX) -> PIX & NODEOut {
        guard let pix = operand as? NODEOut else {
            let black = ColorPIX(at: ._128)
            black.backgroundColor = .black
            return black
        }
        return pix.invert()
    }
    
    prefix static func ° (operand: PIX) -> PIX & NODEOut {
        return operand ° 1.0
    }
    
}
