//
//  NODEOutput.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//


open class NODEOutput: PIX, NODEInIO, NODEInSingle {
    
    public var pixInList: [PIX & NODEOut] = []
    public var connectedIn: Bool { return !pixInList.isEmpty }
    
    public var inPix: (PIX & NODEOut)? { didSet { setNeedsConnectSingle(new: inPix, old: oldValue) } }
    
    open override var shaderName: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    override init() {
        super.init()
        pixInList = []
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("NODEOutput Decoder Initializer is not supported.") // CHECK
//    }
    
    public override func destroy() {
        inPix = nil
        super.destroy()
    }
    
}
