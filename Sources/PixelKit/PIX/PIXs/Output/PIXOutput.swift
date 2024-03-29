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
    
    public var outputModel: PixelOutputModel {
        get { pixelModel as! PixelOutputModel }
        set { pixelModel = newValue }
    }
    
    public var inputList: [NODE & NODEOut] = []{
        didSet { outputModel.inputNodeReferences = inputList.map({ NodeReference(node: $0, connection: .single) }) }
    }
    public var connectedIn: Bool { return !inputList.isEmpty }
    
    public var input: (NODE & NODEOut)? { didSet { setNeedsConnectSingle(new: input, old: oldValue) } }
    
    open override var shaderName: String { return "nilPIX" }

    public var renderPromisePublisher: PassthroughSubject<RenderRequest, Never> = PassthroughSubject()
    public var renderPublisher: PassthroughSubject<RenderPack, Never> = PassthroughSubject()
    public var cancellableIns: [AnyCancellable] = []
    
    // MARK: - Life Cycle -
    
    public init(model: PixelOutputModel) {
        super.init(model: model)
    }
    
    public required init() {
        fatalError("please use init(model:)")
    }
    
    open override func destroy() {
        input = nil
        super.destroy()
    }
    
}
