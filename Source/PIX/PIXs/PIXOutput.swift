//
//  PIXOutput.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit
import Combine

open class PIXOutput: PIX, NODEInIO, NODEInSingle {
    
    public var inputList: [NODE & NODEOut] = []
    public var connectedIn: Bool { return !inputList.isEmpty }
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    open override var shaderName: String { return "nilPIX" }

    public var cancellableIns: [AnyCancellable] = []
    
    // MARK: - Public Properties
    
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
        inputList = []
    }
    
//    required public init(from decoder: Decoder) throws {
//        fatalError("NODEOutput Decoder Initializer is not supported.") // CHECK
//    }
    
    public override func destroy() {
        input = nil
        super.destroy()
    }
    
    public func didUpdateInputConnections() {
        cancellableIns = []
        Publishers.MergeMany(inputList.map(\.renderPublisher))
            .sink { [weak self] textures in
                self?.render()
            }
            .store(in: &cancellableIns)
    }
    
}
