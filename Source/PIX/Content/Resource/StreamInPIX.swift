//
//  StreamInPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-02-27.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import CoreGraphics

public class StreamInPIX: PIXResource {
    
    override open var shader: String { return "contentResourceImagePIX" }
    
    enum Connected {
        case disconnected
        case connecting
        case connected
    }
    
    var connected: Connected = .disconnected
    var steamed: Bool = false
    var streamSize: CGSize?
    var peer: Peer?
    
    #if os(iOS)
    var image: UIImage? { didSet { setNeedsBuffer() } }
    #elseif os(macOS)
//    var image: NSImage? { didSet { setNeedsBuffer() } }
    #endif
    
    // MARK: - Life Cycle
    
    public override init() {
        
        super.init()
        
        peer = Peer(gotImg: { img in
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
            pixels.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if pixels.frame == 0 {
            pixels.log(pix: self, .debug, .resource, "One frame delay.")
            pixels.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = pixels.buffer(from: image) else {
            pixels.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixels.log(pix: self, .info, .resource, "Image Loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
