//
//  PIXOutput.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import Combine

open class PIXOutput: PIX, NODEOutput, NODEInSingle {
        
    public var inputList: [NODE & NODEOut] = []
    public var connectedIn: Bool { return !inputList.isEmpty }
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    open override var shaderName: String { return "nilPIX" }

    public var renderPromisePublisher: PassthroughSubject<RenderRequest, Never> = PassthroughSubject()
    public var renderPublisher: PassthroughSubject<RenderPack, Never> = PassthroughSubject()
    public var cancellableIns: [AnyCancellable] = []
    
    // MARK: - Public Properties
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
        inputList = []
    }
    
    public required init() {
        fatalError("please use init(name:typeName:)")
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
}
