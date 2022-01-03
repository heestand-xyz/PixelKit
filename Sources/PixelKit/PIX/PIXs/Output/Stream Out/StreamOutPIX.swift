//
//  StreamOutPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-02-27.
//

#if os(iOS)

import Foundation
import CoreGraphics
import CoreImage
import RenderKit
import Resolution
import UIKit

final public class StreamOutPIX: PIXOutput, PIXViewable {
    
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
    
    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Stream Out", typeName: "pix-output-stream-out")
        setup()
    }
    
    func setup() {
        guard let viewController: UIViewController = viewController else {
            pixelKit.logger.log(.error, .view, "View Controller Not Found")
            return
        }
        peer = Peer(viewController: viewController, peer: { connect_state, device_name in
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
    
    public override func didRender(renderPack: RenderPack) {
        super.didRender(renderPack: renderPack)
        stream(texture: renderPack.response.texture)
    }
    
    func stream(texture: MTLTexture) {
        guard connected == .connected else { return }
        guard let image: UIImage = Texture.image(from: texture, colorSpace: pixelKit.render.colorSpace, vFlip: false) else {
            pixelKit.logger.log(.warning, .resource, "Stream Image Convert Failed.")
            return
        }
//        let ci_image = CIImage(mtlTexture: texture, options: nil)
//        let context: CIContext = CIContext.init(options: nil)
//        let cg_image: CGImage = context.createCGImage(ci_image!, from: ci_image!.extent)!
//        let size = ci_image!.extent.size
//        UIGraphicsBeginImageContext(size)
//        let bitmap = UIGraphicsGetCurrentContext()
//        bitmap!.draw(cg_image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        peer.sendImg(img: image, quality: quality)
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

#endif
