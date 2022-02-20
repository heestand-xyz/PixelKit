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
    
    public typealias Model = StreamOutPixelModel
    
    private var model: Model {
        get { outputModel as! Model }
        set { outputModel = newValue }
    }
    
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
        guard let viewController: UIViewController = viewController else {
            PixelKit.main.logger.log(.error, .view, "View Controller Not Found")
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
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Render
    
    public override func didRender(renderPack: RenderPack) {
        super.didRender(renderPack: renderPack)
        stream(texture: renderPack.response.texture)
    }
    
    // MARK: - Stream
    
    func stream(texture: MTLTexture) {
        guard connected == .connected else { return }
        guard let image: UIImage = Texture.image(from: texture, colorSpace: PixelKit.main.render.colorSpace, vFlip: false) else {
            PixelKit.main.logger.log(.warning, .resource, "Stream Image Convert Failed.")
            return
        }
        peer.sendImg(img: image, quality: quality)
    }
    
    // MARK: - Connect
    
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
