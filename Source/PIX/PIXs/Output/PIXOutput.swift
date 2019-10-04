//
//  NODEOutput.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit

open class NODEOutput: PIX, NODEInIO, NODEInSingle {
    
    public var inputList: [NODE & NODEOut] = []
    public var connectedIn: Bool { return !inputList.isEmpty }
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    open override var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    override init() {
        super.init()
        inputList = []
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("NODEOutput Decoder Initializer is not supported.") // CHECK
//    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
}
