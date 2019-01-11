//
//  RemapPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//
import CoreGraphics//x

public class RemapPIX: PIXMergerEffect {
    
    override open var shader: String { return "effectMergerRemapPIX" }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        setNeedsRender()
//    }
//
//    public override func encode(to encoder: Encoder) throws {}
    
    
}

public extension PIXOut {
    
    func _remap(with pix: PIX & PIXOut) -> RemapPIX {
        let remapPix = RemapPIX()
        remapPix.name = ":remap:"
        remapPix.inPixA = self as? PIX & PIXOut
        remapPix.inPixB = pix
        return remapPix
    }
    
}
