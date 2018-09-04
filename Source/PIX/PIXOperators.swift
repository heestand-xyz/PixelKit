//
//  PIXOperators.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-04.
//  Copyright © 2018 Hexagons. All rights reserved.
//

infix operator --
infix operator ><
infix operator <>

public extension PIX {
    
    static func blend(_ pixA: PIX, _ pixB: PIX & PIXOut, blendingMode: PIX.BlendingMode) -> BlendPIX {
        let pixA = (pixA as? PIX & PIXOut) ?? ColorPIX(res: ._128) // CHECK
        let blendPix = BlendPIX()
        blendPix.blendingMode = blendingMode
        blendPix.inPixA = pixA
        blendPix.inPixB = pixB
        return blendPix
    }
    
    public static func +(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .add)
    }
    
    public static func -(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .subtract)
    }
    
    public static func *(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .multiply)
    }
    
    public static func &(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .over)
    }
    
    public static func --(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .difference)
    }
    
    public static func ><(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .minimum)
    }
    
    public static func <>(lhs: PIX, rhs: PIX & PIXOut) -> BlendPIX {
        return PIX.blend(lhs, rhs, blendingMode: .maximum)
    }
    
}
