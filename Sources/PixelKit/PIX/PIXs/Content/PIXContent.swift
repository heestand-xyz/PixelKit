//
//  PIXContent.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit
import Resolution
import SwiftUI
import Combine

open class PIXContent: PIX, NODEContent, NODEOutIO {
    
    var contentModel: PixelContentModel {
        get { pixelModel as! PixelContentModel }
        set { pixelModel = newValue }
    }
    
    public var outputPathList: [NODEOutPath] = []
    public var connectedOut: Bool { !outputPathList.isEmpty }
    
    public var renderPromisePublisher: PassthroughSubject<RenderRequest, Never> = PassthroughSubject()
    public var renderPublisher: PassthroughSubject<RenderPack, Never> = PassthroughSubject()
    
    // MARK: - Life Cycle -
    
    init(model: PixelContentModel) {
        super.init(model: model)
    }
    
    @available(*, deprecated)
    override init(name: String, typeName: String) {
        
        super.init(name: name, typeName: typeName)
    }
}
