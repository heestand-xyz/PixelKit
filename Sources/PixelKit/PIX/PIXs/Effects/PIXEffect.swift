//
//  PIXEffect.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import MetalKit
import RenderKit
import Resolution
import Combine

open class PIXEffect: PIX, NODEEffect {
    
    var effectModel: PixelEffectModel {
        get { pixelModel as! PixelEffectModel }
        set { pixelModel = newValue }
    }
    
    public var inputList: [NODE & NODEOut] = [] {
        didSet { effectModel.inputNodeReferences = inputList.map({ NodeReference(node: $0, connection: .single) }) }
    }
    public var outputPathList: [NODEOutPath] = [] {
        didSet { effectModel.outputNodeReferences = outputPathList.map(NodeReference.init) }
    }
    public var connectedIn: Bool { !inputList.isEmpty }
    public var connectedOut: Bool { !outputPathList.isEmpty }

    public var tileResolution: Resolution { pixelKit.tileResolution }
    public var tileTextures: [[MTLTexture]]?
    
    public var renderPromisePublisher: PassthroughSubject<RenderRequest, Never> = PassthroughSubject()
    public var renderPublisher: PassthroughSubject<RenderPack, Never> = PassthroughSubject()
    public var cancellableIns: [AnyCancellable] = []
    
    // MARK: - Life Cycle -
    
    init(model: PixelEffectModel) {
        super.init(model: model)
    }
    
    @available(*, deprecated)
    public override init(name: String, typeName: String) {
        super.init(name: name, typeName: typeName)
    }
    
}
