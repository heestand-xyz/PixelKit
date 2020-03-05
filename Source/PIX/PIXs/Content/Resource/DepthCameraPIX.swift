//
//  DepthCameraPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-12-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import RenderKit

#if os(iOS) && !targetEnvironment(macCatalyst)
public class DepthCameraPIX: PIXResource {
    
    override open var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Public Properties
    
    public var cameraPix: CameraPIX? {
        didSet {
            cameraPix?.depthCallback = { depthPixelBuffer in
                self.pixelKit.logger.log(node: self, .info, .resource, "Depth Camera frame captured.", loop: true)
                self.pixelBuffer = depthPixelBuffer
                if self.view.resolution == nil || self.view.resolution! != self.renderResolution {
                    self.applyResolution { self.setNeedsRender() }
                } else {
                    self.setNeedsRender()
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        name = "depthCamera"
        DispatchQueue.main.async {
            if self.cameraPix == nil {
                self.pixelKit.logger.log(node: self, .warning, .resource, "Please set the .cameraPix property.")
                self.pixelKit.logger.log(node: self, .warning, .resource, "Also enable .depth on the CameraPIX.")
                self.pixelKit.logger.log(node: self, .warning, .resource, "To access values outside of the 0.0 and 1.0 bounds please use PixelKit.main.render.bits = ._16")
                self.pixelKit.logger.log(node: self, .info, .resource, "The depth image will be rotated, use DepthCameraPIX.setup() to fix this or use a FlipFlopPIX.")
                self.pixelKit.logger.log(node: self, .info, .resource, "The depth image will be red, use DepthCameraPIX.setup() to fix this or use a ChannelMixPIX.")
            }
        }
    }
    
    public static func setup(with cameraPix: CameraPIX, filter: Bool = true) -> ChannelMixPIX {
        
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
