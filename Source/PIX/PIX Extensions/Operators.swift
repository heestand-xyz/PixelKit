//
//  PIXOperators.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-04.
//  Open Source - MIT License
//

import LiveValues

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
        
        public var globalPlacement: Placement = .aspectFit
        
        func blend(_ pixA: PIX, _ pixB: PIX & NODEOut, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let pixA = (pixA as? PIX & NODEOut) ?? ColorPIX(res: ._128) // CHECK
            let blendPix = BlendPIX()
            blendPix.name = operatorName(of: blendingMode)
            blendPix.blendMode = blendingMode
            blendPix.bypassTransform = true
            blendPix.placement = globalPlacement
            blendPix.inPixA = pixA
            blendPix.inPixB = pixB
            return blendPix
        }
        
        func blend(_ pix: PIX, _ color: LiveColor, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let colorPix = ColorPIX(res: .custom(w: 1, h: 1))
            colorPix.color = color
            if [.addWithAlpha, .subtractWithAlpha].contains(blendingMode) {
                colorPix.premultiply = false
            }
            let blendPix = blend(pix, colorPix, blendingMode: blendingMode)
            blendPix.extend = .hold
            return blendPix
        }
        
        func blend(_ pix: PIX, _ val: LiveFloat, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let color: LiveColor
            switch blendingMode {
            case .addWithAlpha, .subtractWithAlpha:
                color = LiveColor(lum: val, a: val)
            default:
                color = LiveColor(lum: val)
            }
            return blend(pix, color, blendingMode: blendingMode)
        }
        
        func blend(_ pix: PIX, _ val: LivePoint, blendingMode: PIX.BlendingMode) -> BlendPIX {
            return blend(pix, LiveColor(r: val.x, g: val.y, b: 0.0, a: 1.0), blendingMode: blendingMode)
        }
        
        func operatorName(of blendingMode: PIX.BlendingMode) -> String {
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
    static func +(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    
    static func ++(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    static func ++(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ++ lhs }
    static func ++(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .addWithAlpha)
    }
    
    static func -(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    
    static func --(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    
    static func *(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    
    static func **(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    
    static func !**(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    
    static func &(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    
    static func !&(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    
    static func %(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    
    static func <>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    
    static func ><(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    
    static func /(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    
    static func ~(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    static func ~(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ~ lhs }
    static func ~(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .average)
    }
    
    static func °(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    static func °(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs ° lhs }
    static func °(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .cosine)
    }
    
    static func <->(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    static func <->(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <-> lhs }
    static func <->(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .inside)
    }
    
//    static func <+>(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
//    static func <+>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <+> lhs }
//    static func <+>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .insideDestination)
//    }
    
    static func >-<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    static func >-<(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >-< lhs }
    static func >-<(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .outside)
    }
    
//    static func >+<(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
//    static func >+<(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >+< lhs }
//    static func >+<(lhs: PIX, rhs: LiveColor) -> BlendPIX {
//        return blendOperators.blend(lhs, rhs, blendingMode: .outsideDestination)
//    }
    
    static func +-+(lhs: PIX, rhs: PIX & NODEOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: LivePoint, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: LivePoint) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    static func +-+(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs +-+ lhs }
    static func +-+(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .exclusiveOr)
    }
    
    prefix static func ! (operand: PIX) -> PIX & NODEOut {
        guard let pix = operand as? NODEOut else {
            let black = ColorPIX(res: ._128)
            black.bgColor = .black
            return black
        }
        return pix._invert()
    }
    
    prefix static func ° (operand: PIX) -> PIX & NODEOut {
        return operand ° 1.0
    }
    
}
