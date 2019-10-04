//
//  StreamOutPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-02-27.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreImage
import UIKit

public class StreamOutPIX: NODEOutput {
    
    enum Connected {
        case disconnected
        case connecting
        case connected
    }
    
    var connected: Connected = .disconnected
    var timer: Timer?
    var peer: Peer!
    
    // MARK: - Public Properties
    
    public var quality: CGFloat = 0.5
    
    // MARK: - Life Cycle
    
    override public init() {
        
        super.init()
        
        name = "streamOut"
        
        peer = Peer(peer: { connect_state, device_name in
            if connect_state == .connected {
                self.connected = .connected
                if let texture = self.texture {
                    self.stream(texture: texture)
                }
            } else {
                self.connected = .disconnected
            }
        })
        
    }
    
    public override func didRender(texture: MTLTexture, force: Bool = false) {
        super.didRender(texture: texture, force: force)
        stream(texture: texture)
    }
    
    func stream(texture: MTLTexture) {
        guard connected == .connected else { return }
        let ci_image = CIImage(mtlTexture: texture, options: nil)
        if ci_image != nil {
            let context: CIContext = CIContext.init(options: nil)
            let cg_image: CGImage = context.createCGImage(ci_image!, from: ci_image!.extent)!
            let size = ci_image!.extent.size
            UIGraphicsBeginImageContext(size)
            let bitmap = UIGraphicsGetCurrentContext()
            bitmap!.draw(cg_image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if image != nil {
                
                peer.sendImg(img: image!, quality: quality)
                
            } else {
                pixelKit.logger.log(.warning, .resource, "Stream Image Convert B.")
            }
        } else {
            pixelKit.logger.log(.warning, .resource, "Stream Image Convert A.")
        }
    }
    
    public func connect() {
        peer.joinSession()
    }
    
    public func disconnect() {
        if connected == .connected {
            peer.sendDisconnect()
        }
    }
    
}
