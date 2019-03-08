//
//  PIXOperators.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-04.
//  Open Source - MIT License
//

infix operator --
infix operator **
infix operator !**
infix operator !&
infix operator <>
infix operator ><

public extension PIX {
    
    static let blendOperators = BlendOperators()
    
    class BlendOperators {
        
        public var globalPlacement: Placement = .aspectFit
        
        func blend(_ pixA: PIX, _ pixB: PIX & PIXOut, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let pixA = (pixA as? PIX & PIXOut) ?? ColorPIX(res: ._128) // CHECK
            let blendPix = BlendPIX()
            blendPix.name = operatorName(of: blendingMode)
            blendPix.blendingMode = blendingMode
            blendPix.bypassTransform = true
            blendPix.placement = globalPlacement
            blendPix.inPixA = pixA
            blendPix.inPixB = pixB
            return blendPix
        }
        
        func blend(_ pix: PIX, _ color: LiveColor, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let colorPix = ColorPIX(res: .custom(w: 1, h: 1))
            colorPix.color = color
            let blendPix = blend(pix, colorPix, blendingMode: blendingMode)
            blendPix.extend = .hold
            return blendPix
        }
        
        func blend(_ pix: PIX, _ val: LiveFloat, blendingMode: PIX.BlendingMode) -> BlendPIX {
            return blend(pix, LiveColor(lum: val), blendingMode: blendingMode)
        }
        
        func operatorName(of blendingMode: PIX.BlendingMode) -> String {
            switch blendingMode {
            case .over: return "&"
            case .under: return "!&"
            case .add: return "+"
            case .multiply: return "*"
            case .difference: return "%"
            case .subtractWithAlpha: return "--"
            case .subtract: return "-"
            case .maximum: return "><"
            case .minimum: return "<>"
            case .gamma: return "!**"
            case .power: return "**"
            case .divide: return "/"
            }
        }
        
    }
    
    static func +(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    static func +(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs + lhs }
    static func +(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    
    static func -(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    static func -(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    
    static func --(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    static func --(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    
    static func *(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    static func *(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs * lhs }
    static func *(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    
    static func **(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    static func **(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    
    static func !**(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    static func !**(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    
    static func &(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    static func &(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    static func &(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    
    static func !&(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    static func !&(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs & lhs }
    static func !&(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    
    static func %(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    static func %(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs % lhs }
    static func %(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    
    static func <>(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    static func <>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    static func <>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    
    static func ><(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    static func ><(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    static func ><(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    
    static func /(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    static func /(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs / lhs }
    static func /(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    
    prefix static func ! (operand: PIX) -> PIX & PIXOut {
        guard let pix = operand as? PIXOut else {
            let black = ColorPIX(res: ._128)
            black.color = .black
            return black
        }
        return pix._invert()
    }
    
}
