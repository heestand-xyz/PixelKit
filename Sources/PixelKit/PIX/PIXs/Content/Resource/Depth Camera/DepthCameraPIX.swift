//
//  DepthCameraPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-12-02.
//

import Foundation
import RenderKit
import Resolution
import PixelColor

#if os(iOS) && !targetEnvironment(macCatalyst)
final public class DepthCameraPIX: PIXResource, PIXViewable {
    
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
                self.pixelKit.logger.log(node: self, .info, .resource, "Depth Camera frame captured.", loop: true)
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
        
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Depth Camera", typeName: "pix-content-resource-depth-camera")
        setup()
    }
    
    func setup() {
        flop = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.cameraPix == nil {
                self.pixelKit.logger.log(node: self, .warning, .resource, "Please set the .cameraPix property.")
                self.pixelKit.logger.log(node: self, .warning, .resource, "Also enable .depth on the CameraPIX.")
                self.pixelKit.logger.log(node: self, .warning, .resource, "To access values outside of the 0.0 and 1.0 bounds please use PixelKit.main.render.bits = ._16")
                self.pixelKit.logger.log(node: self, .info, .resource, "The depth image will be rotated, use DepthCameraPIX.setupCamera() to fix this or use a FlipFlopPIX.")
                self.pixelKit.logger.log(node: self, .info, .resource, "The depth image will be red, use DepthCameraPIX.setupCamera() to fix this or use a ChannelMixPIX.")
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
    
}
#endif
