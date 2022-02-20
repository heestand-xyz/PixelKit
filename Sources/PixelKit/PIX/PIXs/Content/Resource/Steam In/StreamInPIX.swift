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
    
    public typealias Model = StreamInPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { return "contentResourceBGRPIX" }
    
    public enum Connected {
        case disconnected
        case connecting
        case connected
    }
    
    public private(set) var connected: Connected = .disconnected
    
    var peer: Peer?
    
    var image: UIImage? { didSet { setNeedsBuffer() } }
    
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
    
    func setup() {
        
        guard let viewController: UIViewController = viewController else {
            PixelKit.main.logger.log(.error, .view, "View Controller Not Found")
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
            }
        }, disconnect: {
            self.connected = .disconnected
        })
        peer!.startHosting()
        
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
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard let image = image else {
            PixelKit.main.logger.log(node: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        guard let buffer = Texture.buffer(from: image, bits: PixelKit.main.render.bits) else {
            PixelKit.main.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        resourcePixelBuffer = buffer
        PixelKit.main.logger.log(node: self, .info, .resource, "Image Loaded.")
        applyResolution { [weak self] in
            self?.render()
        }
    }
    
}

#endif
