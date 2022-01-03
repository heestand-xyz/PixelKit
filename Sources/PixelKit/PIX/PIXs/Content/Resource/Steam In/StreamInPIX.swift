//
//  StreamInPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-02-27.
//

#if os(iOS)

import RenderKit
import Resolution
import UIKit
import CoreGraphics

final public class StreamInPIX: PIXResource, PIXViewable {
    
    override public var shaderName: String { return "contentResourceBGRPIX" }
    
    enum Connected {
        case disconnected
        case connecting
        case connected
    }
    
    var connected: Connected = .disconnected
    var steamed: Bool = false
    var streamSize: CGSize?
    var peer: Peer?
    
    #if os(iOS) || os(tvOS)
    var image: UIImage? { didSet { setNeedsBuffer() } }
    #elseif os(macOS)
//    var image: NSImage? { didSet { setNeedsBuffer() } }
    #endif
    
    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Stream In", typeName: "pix-content-resource-stream-in")
        setup()
    }
    
    func setup() {
        
        guard let viewController: UIViewController = viewController else {
            pixelKit.logger.log(.error, .view, "View Controller Not Found")
            return
        }
        
        peer = Peer(viewController: viewController, gotImg: { img in
            self.image = img
            self.connected = .connected
        }, peer: { connect_state, device_name in
            if connect_state == .connected {
                self.connected = .connecting
            } else if connect_state == .dissconnected {
                self.connected = .disconnected
                self.steamed = false
            }
        }, disconnect: {
            self.connected = .disconnected
            self.steamed = false
        })
        peer!.startHosting()
        
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            pixelKit.logger.log(node: self, .debug, .resource, "Nil not supported yet.")
            return
        }
//        if pixelKit.render.frame == 0 {
//            pixelKit.logger.log(node: self, .debug, .resource, "One frame delay.")
//            pixelKit.render.delay(frames: 1, done: {
//                self.setNeedsBuffer()
//            })
//            return
//        }
        guard let buffer = Texture.buffer(from: image, bits: pixelKit.render.bits) else {
            pixelKit.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        resourcePixelBuffer = buffer
        pixelKit.logger.log(node: self, .info, .resource, "Image Loaded.")
        applyResolution { [weak self] in
            self?.render()
        }
    }
    
}

#endif
