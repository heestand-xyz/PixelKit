//
//  DepthCameraPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-12-02.
//

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

#if os(iOS) && !targetEnvironment(macCatalyst)

final public class DepthCameraPIX: PIXResource, PIXViewable {
    
    public typealias Model = DepthCameraPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    private var flipX: Bool {
        cameraPix?.camera == .back
    }
    
    public override var uniforms: [CGFloat] {
        [flipX ? 1.0 : 0.0]
    }
    
    override public var shaderName: String { return "depthCameraPIX" }
    
    // MARK: - Public Properties
    
    public var cameraPix: CameraPIX? {
        willSet {
            if newValue == nil {
                if let cameraPix = cameraPix {
                    cameraPix.depth = false
                    cameraPix.depthCallback = nil
                }
            }
        }
        didSet {
            guard let cameraPix = cameraPix else { return }
            cameraPix.depthCallback = { [weak self] depthPixelBuffer in
                guard let self = self else { return }
                PixelKit.main.logger.log(node: self, .info, .resource, "Depth Camera frame captured.", loop: true)
                self.resourcePixelBuffer = depthPixelBuffer
                if self.view.resolution == nil || self.view.resolution! != self.finalResolution {
                    self.applyResolution { [weak self] in
                        self?.render()
                    }
                } else {
                    self.render()
                }
            }
            cameraPix.depth = true
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
    
    func setup() {
        flop = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.cameraPix == nil {
                PixelKit.main.logger.log(node: self, .warning, .resource, "Please set the .cameraPix property.")
                PixelKit.main.logger.log(node: self, .warning, .resource, "Also enable .depth on the CameraPIX.")
                PixelKit.main.logger.log(node: self, .warning, .resource, "To access values outside of the 0.0 and 1.0 bounds please use PixelKit.main.render.bits = ._16")
                PixelKit.main.logger.log(node: self, .info, .resource, "The depth image will be rotated, use DepthCameraPIX.setupCamera() to fix this or use a FlipFlopPIX.")
                PixelKit.main.logger.log(node: self, .info, .resource, "The depth image will be red, use DepthCameraPIX.setupCamera() to fix this or use a ChannelMixPIX.")
            }
        }
    }
    
    public static func setup(cameraPix: CameraPIX, filter: Bool = true) -> ChannelMixPIX {
        
        cameraPix.filterDepth = filter
        cameraPix.depth = true
        
        let depthCameraPix = DepthCameraPIX()
        depthCameraPix.name = "depthCamera"
        depthCameraPix.cameraPix = cameraPix
        
        let flipFlopPix = FlipFlopPIX()
        flipFlopPix.name = "depthCamera:flipFlop"
        flipFlopPix.input = depthCameraPix
        flipFlopPix.flop = .right
        if cameraPix.camera.mirrored {
            flipFlopPix.flip = .x
        }
        
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "depthCamera:channelMix"
        channelMixPix.input = flipFlopPix
        channelMixPix.green = .red
        channelMixPix.blue = .red
        
        return channelMixPix
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
}

#endif
