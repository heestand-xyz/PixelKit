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
    
    public static let blendOperators = BlendOperators()
    
    class BlendOperators {
        
        public var globalFillMode: FillMode = .aspectFit
        
        func blend(_ pixA: PIX, _ pixB: PIX & PIXOut, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let pixA = (pixA as? PIX & PIXOut) ?? ColorPIX(res: ._128) // CHECK
            let blendPix = BlendPIX()
            blendPix.name = operatorName(of: blendingMode)
            blendPix.blendingMode = blendingMode
            blendPix.bypassTransform = true
            blendPix.fillMode = globalFillMode
            blendPix.inPixA = pixA
            blendPix.inPixB = pixB
            return blendPix
        }
        
        func blend(_ pix: PIX, _ color: LiveColor, blendingMode: PIX.BlendingMode) -> BlendPIX {
            let colorPix = ColorPIX(res: .custom(w: 1, h: 1))
            colorPix.color = color
            let blend = blendOperators.blend(pix, colorPix, blendingMode: blendingMode)
            blend.extend = .hold
            return blend
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
    
    public static func +(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    public static func +(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs + lhs }
    public static func +(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    public static func +(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs + lhs }
    public static func +(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .add)
    }
    
    public static func -(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    public static func -(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    public static func -(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtract)
    }
    
    public static func --(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    public static func --(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .subtractWithAlpha)
    }
    
    public static func *(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    public static func *(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs * lhs }
    public static func *(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    public static func *(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs * lhs }
    public static func *(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .multiply)
    }
    
    public static func **(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    public static func **(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    public static func **(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .power)
    }
    
    public static func !**(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    public static func !**(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    public static func !**(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .gamma)
    }
    
    public static func &(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    public static func &(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    public static func &(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    public static func &(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs !& lhs }
    public static func &(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .over)
    }
    
    public static func !&(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    public static func !&(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs & lhs }
    public static func !&(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    public static func !&(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs & lhs }
    public static func !&(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .under)
    }
    
    public static func %(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    public static func %(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs % lhs }
    public static func %(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    public static func %(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs % lhs }
    public static func %(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .difference)
    }
    
    public static func <>(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    public static func <>(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    public static func <>(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    public static func <>(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs <> lhs }
    public static func <>(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .minimum)
    }
    
    public static func ><(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    public static func ><(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    public static func ><(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    public static func ><(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs >< lhs }
    public static func ><(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .maximum)
    }
    
    public static func /(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    public static func /(lhs: LiveFloat, rhs: PIX) -> BlendPIX { return rhs / lhs }
    public static func /(lhs: PIX, rhs: LiveFloat) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    public static func /(lhs: LiveColor, rhs: PIX) -> BlendPIX { return rhs / lhs }
    public static func /(lhs: PIX, rhs: LiveColor) -> BlendPIX {
        return blendOperators.blend(lhs, rhs, blendingMode: .divide)
    }
    
    public prefix static func ! (operand: PIX) -> PIX {
        guard let pix = operand as? PIXOut else {
            let black = ColorPIX(res: ._128)
            black.color = .black
            return black
        }
        return pix._invert()
    }
    
}
