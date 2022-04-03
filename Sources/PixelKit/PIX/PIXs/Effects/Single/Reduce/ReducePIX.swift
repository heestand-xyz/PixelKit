//
//  ReducePIX.swift
//
//
//  Created by Anton Heestand on 2020-07-03.
//


import RenderKit
import Resolution
import MetalPerformanceShaders

@available(tvOS 11.3, *)
@available(iOS 11.3, *)
@available(OSX 10.13.4, *)
final public class ReducePIX: PIXSingleEffect, CustomRenderDelegate, PIXViewable {
    
    public typealias Model = ReducePixelModel
    
    private var model: Model {
        get { singleEffectModel as! Model }
        set { singleEffectModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }

    override var customResolution: Resolution? {
        guard let inputResolution: Resolution = (input as! PIX?)?.derivedResolution else { return nil }
        return getCustomResolution(from: inputResolution)
    }

    // MARK: - Public Properties
    
    public enum CellList: String, Codable {
        case column
        case row
    }
    
    /// the cell list that will be sampled
    ///
    /// one pixel row is *default*
    public var cellList: CellList {
        get { model.cellList }
        set {
            model.cellList = newValue
            applyResolution { [weak self] in
                self?.render()
            }
        }
    }
    
    public enum Method: String, Codable {
        case average
        case minimum
        case maximum
        case sum
    }
    
    public var method: Method {
        get { model.method }
        set {
            model.method = newValue
            render()
        }
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
        customRenderActive = true
        customRenderDelegate = self
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Custom Render
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        let resolution: Resolution = getCustomResolution(from: texture.resolution)
        guard let destinationTexture: MTLTexture = try? Texture.emptyTexture(size: resolution.size,
                                                                             bits: PixelKit.main.render.bits,
                                                                             on: PixelKit.main.render.metalDevice,
                                                                             write: true) else {
            PixelKit.main.logger.log(node: self, .error, .generator, "Make texture failed.")
            return nil
        }
        let reduceKernel: MPSImageReduceUnary = getKernel(with: PixelKit.main.render.metalDevice)
        #if !os(tvOS) && !targetEnvironment(simulator)
        reduceKernel.edgeMode = extend.mps!
        #endif
        reduceKernel.encode(commandBuffer: commandBuffer,
                            sourceTexture: texture,
                            destinationTexture: destinationTexture)
        return destinationTexture
    }
    
    // MARK: - Resolution
    
    func getCustomResolution(from resolution: Resolution) -> Resolution {
        switch cellList {
        case .column:
            return .custom(w: 1, h: resolution.h)
        case .row:
            return .custom(w: resolution.w, h: 1)
        }
    }
    
    // MARK: - Kernel
    
    func getKernel(with device: MTLDevice) -> MPSImageReduceUnary {
        switch cellList {
        case .row:
            switch method {
            case .average:
                return MPSImageReduceColumnMean(device: device)
            case .minimum:
                return MPSImageReduceColumnMin(device: device)
            case .maximum:
                return MPSImageReduceColumnMax(device: device)
            case .sum:
                return MPSImageReduceColumnSum(device: device)
            }
        case .column:
            switch method {
            case .average:
                return MPSImageReduceRowMean(device: device)
            case .minimum:
                return MPSImageReduceRowMin(device: device)
            case .maximum:
                return MPSImageReduceRowMax(device: device)
            case .sum:
                return MPSImageReduceRowSum(device: device)
            }
        }
    }
    
}
