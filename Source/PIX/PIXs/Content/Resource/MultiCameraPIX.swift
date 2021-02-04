//
//  MultiCameraPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-12-02.
//

import Foundation
import CoreGraphics
import RenderKit

#if os(iOS) && !targetEnvironment(macCatalyst)
@available(iOS 13.0, *)
final public class MultiCameraPIX: PIXResource, PIXViewable {
    
    override public var shaderName: String { return "contentResourceCameraPIX" }
    
    // MARK: - Public Properties
    
    public var camera: CameraPIX.Camera = .front {
        didSet {
            guard let cameraPix = cameraPix else { return }
            guard cameraPix.setup == true else { return }
            cameraPix.setupCamera()
        }
    }
    
    public var cameraPix: CameraPIX? {
        didSet {
            guard let cameraPix = cameraPix else { return }
            guard cameraPix.multiCallbacks.filter({ $0.id == id }).isEmpty else { return }
            cameraPix.multiCallbacks.append(
                CameraPIX.MultiCallback(
                    id: id, camera: { self.camera },
                    setup: { orientation in
                        self.orientation = orientation
                        self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
                    },
                    frameLoop: { pixelBuffer in
                        self.pixelKit.logger.log(node: self, .info, .resource, "Multi Camera frame captured.", loop: true)
                        self.pixelBuffer = pixelBuffer
                        if self.view.resolution == nil || self.view.resolution! != self.renderResolution {
                            self.applyResolution { self.setNeedsRender() }
                        } else {
                            self.setNeedsRender()
                        }
                })
            )
        }
    }
    
    var orientation: _Orientation?
    
    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        return [4, camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public init() {
        super.init(name: "Multi Camera", typeName: "pix-content-resource-multi-camera")
        DispatchQueue.main.async {
            if self.cameraPix == nil {
                self.pixelKit.logger.log(node: self, .warning, .resource, "Please set the .cameraPix property.")
                self.pixelKit.logger.log(node: self, .warning, .resource, "Also enable .multi on the CameraPIX.")
            }
        }
    }
    
    public static func setup(with cameraPix: CameraPIX, camera: CameraPIX.Camera) -> MultiCameraPIX {
        
        cameraPix.multi = true
        
        let multiCameraPix = MultiCameraPIX()
        multiCameraPix.name = "multiCamera"
        multiCameraPix.camera = camera
        multiCameraPix.cameraPix = cameraPix
        
        return multiCameraPix
    }
    
}
#endif
