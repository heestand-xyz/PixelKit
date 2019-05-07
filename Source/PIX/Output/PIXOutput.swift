//
//  PIXOutput.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//


open class PIXOutput: PIX, PIXInIO, PIXInSingle {
    
    var pixInList: [PIX & PIXOut] = []
    var connectedIn: Bool { return !pixInList.isEmpty }
    
    public var inPix: (PIX & PIXOut)? { didSet { setNeedsConnectSingle(new: inPix, old: oldValue) } }
    
    open override var shader: String { return "nilPIX" }
    
    // MARK: - Public Properties
    
    override init() {
        super.init()
        pixInList = []
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("PIXOutput Decoder Initializer is not supported.") // CHECK
//    }
    
    public override func destroy() {
        inPix = nil
        super.destroy()
    }
    
}
