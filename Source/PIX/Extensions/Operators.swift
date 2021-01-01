//
//  PIXOperators.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-04.
//  Open Source - MIT License
//

import LiveValues
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
        
        func blend(_ pix: PIX, _ color: LiveColor, blendingMode: BlendMode) -> BlendPIX {
            let colorPix = ColorPIX(at: .custom(w: 1, h: 1))
            colorPix.color = color
            if [.addWithAlpha, .subWithAlpha].contains(blendingMode) {
                colorPix.premultiply = false
            }
            let blendPix = blend(pix, colorPix, blendingMode: blendingMode)
            blendPix.extend = .hold
            return blendPix
        }
        
        func blend(_ pix: PIX, _ val: CGFloat, blendingMode: BlendMode) -> BlendPIX {
            let color: LiveColor
            switch blendingMode {
            case .addWithAlpha, .subWithAlpha:
                color = LiveColor(lum: val, a: val)
            default:
                color = LiveColor(lum: val)
            }
            return blend(pix, color, blendingMode: blendingMode)
        }
        
        func blend(_ pix: PIX, _ val: CGPoint, blendingMode: BlendMode) -> BlendPIX {
            return blend(pix, LiveColor(r: val.x, g: val.y, b: 0.0, a: 1.0), blendingMode: blendingMode)
        }
        
        public func operatorName(of blendingMode: BlendMode) -> String {
            switch blendingMode {
            case .over: return "&"
            case .under: return "!&"
            case .add: return "+"
            case .addWithAlpha: return "++"
            case .mult: return "*"
            case .diff: return "%"
            case .sub: return "-"
            case .subWithAlpha: return "--"
            case .max: return "><"
            case .min: return "<>"
            case .gam: return "!**"
            case .pow: return "**"
            case .div: return "/"
            case .avg: return "~"
            case .cos: return "°"
            case .in: return "<->"
            case .out: return ">-<"
            case .xor: return "+-+"
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
    static func +(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    
    static func ++(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    
    static func -(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .sub)
    }
    static func -(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .sub)
    }
    static func -(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .sub)
    }
    static func -(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .sub)
    }
    
    static func --(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subWithAlpha)
    }
    static func --(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subWithAlpha)
    }
    static func --(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subWithAlpha)
    }
    static func --(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subWithAlpha)
    }
    
    static func *(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .mult)
    }
    static func *(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .mult)
    }
    static func *(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .mult)
    }
    static func *(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .mult)
    }
    
    static func **(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .pow)
    }
    static func **(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .pow)
    }
    static func **(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .pow)
    }
    static func **(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .pow)
    }
    
    static func !**(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gam)
    }
    static func !**(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gam)
    }
    static func !**(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gam)
    }
    static func !**(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gam)
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
    static func &(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LiveColor) -> BlendPIX {
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
    static func !&(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    
    static func %(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .diff)
    }
    static func %(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .diff)
    }
    static func %(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .diff)
    }
    static func %(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .diff)
    }
    
    static func <>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .min)
    }
    static func <>(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .min)
    }
    static func <>(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .min)
    }
    static func <>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .min)
    }
    
    static func ><(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .max)
    }
    static func ><(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .max)
    }
    static func ><(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .max)
    }
    static func ><(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .max)
    }
    
    static func /(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .div)
    }
    static func /(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .div)
    }
    static func /(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .div)
    }
    static func /(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .div)
    }
    
    static func ~(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .avg)
    }
    static func ~(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .avg)
    }
    static func ~(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .avg)
    }
    static func ~(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .avg)
    }
    
    static func °(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cos)
    }
    static func °(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cos)
    }
    static func °(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cos)
    }
    static func °(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cos)
    }
    
    static func <->(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .in)
    }
    static func <->(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .in)
    }
    static func <->(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .in)
    }
    static func <->(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .in)
    }
    
//    static func <+>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: CGFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
    
    static func >-<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .out)
    }
    static func >-<(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .out)
    }
    static func >-<(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .out)
    }
    static func >-<(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .out)
    }
    
//    static func >+<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: CGFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: LiveColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
    
    static func +-+(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .xor)
    }
    static func +-+(lhs: CGFloat, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: CGFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .xor)
    }
    static func +-+(lhs: CGPoint, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: CGPoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .xor)
    }
    static func +-+(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .xor)
    }
    
    prefix static func ! (operand: PIX) -> PIX & NODEOut {
        guard let pix = operand as? NODEOut else {
            let black = ColorPIX(at: ._128)
            black.bgColor = .black
            return black
        }
        return pix._invert()
    }
    
    prefix static func ° (operand: PIX) -> PIX & NODEOut {
        return operand ° 1.0
    }
    
}
