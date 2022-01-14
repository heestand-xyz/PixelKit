//
//  FilterPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-10-05.
//

import Foundation
import RenderKit
import Resolution
import MetalKit

final public class FilterPIX: PIXSingleEffect, PIXViewable {
    
    public typealias Model = FilterPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    public enum Filter: String, Enumable {
        
        case noir
        case chrome
        case fade
        case instant
        case mono
        case process
        case tonal
        case transfer
        
        public var index: Int {
            switch self {
            case .noir:
                return 0
            case .chrome:
                return 1
            case .fade:
                return 2
            case .instant:
                return 3
            case .mono:
                return 4
            case .process:
                return 5
            case .tonal:
                return 6
            case .transfer:
                return 7
            }
        }
        
        public var name: String {
            switch self {
            case .noir:
                return "Noir"
            case .chrome:
                return "Chrome"
            case .fade:
                return "Fade"
            case .instant:
                return "Instant"
            case .mono:
                return "Mono"
            case .process:
                return "Process"
            case .tonal:
                return "Tonal"
            case .transfer:
                return "Transfer"
            }
        }
        
        public var typeName: String {
            rawValue
        }
        
        var ciFilterName: String {
            switch self {
            case .noir:
                return "CIPhotoEffectNoir"
            case .chrome:
                return "CIPhotoEffectChrome"
            case .fade:
                return "CIPhotoEffectFade"
            case .instant:
                return "CIPhotoEffectInstant"
            case .mono:
                return "CIPhotoEffectMono"
            case .process:
                return "CIPhotoEffectProcess"
            case .tonal:
                return "CIPhotoEffectTonal"
            case .transfer:
                return "CIPhotoEffectTransfer"
            }
        }
        
    }
    
    @LiveEnum("filter") public var filter: Filter = .noir
    
    // MARK: Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_filter]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        filter = model.filter
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.filter = filter
        
        super.liveUpdateModelDone()
    }
}

extension FilterPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        let parameters: [String : Any]? = [
            kCIInputImageKey : ciImage
        ]
            
        guard let filter: CIFilter = CIFilter(name: filter.ciFilterName, parameters: parameters) else { return nil }
        guard let finalImage: CIImage = filter.outputImage else { return nil }
        
        do {
            let finalTexture: MTLTexture = try Texture.makeTexture(from: finalImage,
                                                                   at: texture.resolution.size,
                                                                   colorSpace: PixelKit.main.render.colorSpace,
                                                                   bits: PixelKit.main.render.bits,
                                                                   with: commandBuffer,
                                                                   on: PixelKit.main.render.metalDevice)
            return finalTexture
        } catch {
            PixelKit.main.logger.log(node: self, .error, .resource, "CI Filter Failed", e: error)
            return nil
        }
        
    }
    
}
