//
//  MorphPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-08-10.
//

import RenderKit
import Resolution
import CoreGraphics
import MetalKit
#if !os(tvOS) && !targetEnvironment(simulator)
// MPS does not support the iOS simulator.
import MetalPerformanceShaders
#endif
import SwiftUI

final public class MorphPIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable/*, NODEResolution*/ {
    
    public typealias Model = MorphPixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }

//    public var resolution: Resolution = .square(256)
    
    // MARK: - Public Properties

    public enum Style: String, Enumable {
        case minimum
        case maximum
//        case dilate
//        case erode
        public var index: Int {
            switch self {
            case .minimum: return 0
            case .maximum: return 1
//            case .dilate: return 3
//            case .erode: return 2
            }
        }
        public var typeName: String { rawValue }
        public var name: String {
            switch self {
            case .minimum: return "Minimum"
            case .maximum: return "Maximum"
//            case .dilate: return "Dilate"
//            case .erode: return "Erode"
            }
        }
    }
    
    @LiveEnum("style") public var style: Style = .maximum
    
    @LiveInt("width", range: 1...10) public var width: Int = 1
    @LiveInt("height", range: 1...10) public var height: Int = 1

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _width, _height]
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
    
    // MARK: - Setup
    
    private func setup() {
        customRenderDelegate = self
        customRenderActive = true
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        style = model.style
        width = model.width
        height = model.height

        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.style = style
        model.width = width
        model.height = height

        super.liveUpdateModelDone()
    }
    
    // MARK: Histogram
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        #if !os(tvOS) && !targetEnvironment(simulator)
        return morph(texture, with: commandBuffer)
        #else
        return nil
        #endif
    }
    
    #if !os(tvOS) && !targetEnvironment(simulator)
    func morph(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
//        var values: [Float] = [
//            1.0, 1.0, 1.0,
//            1.0, 0.0, 1.0,
//            1.0, 0.0, 1.0
//        ]
        
        let kernel: MPSUnaryImageKernel
        switch style {
//        case .erode:
//            kernel = MPSImageErode(device: PixelKit.main.render.metalDevice,
//                                   kernelWidth: 3,
//                                   kernelHeight: 3,
//                                   values: &values)
//        case .dilate:
//            kernel = MPSImageDilate(device: PixelKit.main.render.metalDevice,
//                                    kernelWidth: 3,
//                                    kernelHeight: 3,
//                                    values: &values)
        case .minimum:
            kernel = MPSImageAreaMin(device: PixelKit.main.render.metalDevice,
                                     kernelWidth: 1 + width * 2,
                                     kernelHeight: 1 + height * 2)
        case .maximum:
            kernel = MPSImageAreaMax(device: PixelKit.main.render.metalDevice,
                                     kernelWidth: 1 + width * 2,
                                     kernelHeight: 1 + height * 2)
        }
        
        guard let morphTexture = try? Texture.emptyTexture(size: CGSize(width: texture.width,
                                                                        height: texture.height),
                                                           bits: PixelKit.main.render.bits,
                                                           on: PixelKit.main.render.metalDevice,
                                                           write: true) else {
            PixelKit.main.logger.log(node: self, .error, .generator, "Guassian Blur: Make texture faild.")
            return nil
        }
        
        kernel.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: morphTexture)
        
        return morphTexture
        
    }
    #endif
    
}

public extension NODEOut {
    
    func pixMorph(style: MorphPIX.Style = .maximum) -> MorphPIX {
        let morphPix = MorphPIX()
        morphPix.name = ":morph:"
        morphPix.input = self as? PIX & NODEOut
        return morphPix
    }
    
}
