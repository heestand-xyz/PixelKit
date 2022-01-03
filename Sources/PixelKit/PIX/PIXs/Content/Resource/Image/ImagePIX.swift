//
//  ImagePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-07.
//  Open Source - MIT License
//

import RenderKit
import Resolution

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
import PixelColor

#if os(iOS) || os(tvOS)
public typealias UINSImage = UIImage
#elseif os(macOS)
public typealias UINSImage = NSImage
#endif

final public class ImagePIX: PIXResource, PIXViewable {
    
    public typealias Model = ImagePixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { "contentResourceImagePIX" }
    
    // MARK: - Private Properties
    
    var flip: Bool {
        #if os(iOS) || os(tvOS)
        return true
        #elseif os(macOS)
        return false
        #endif
    }
    
    var swizzle: Bool {
        false
    }
    
    // MARK: - Public Properties
    
    public var image: UINSImage? { didSet { setNeedsBuffer() } }
    
    @Published public private(set) var imageLoaded: Bool = false
    
    /// Set `resizeResolution` to update image.
    public var resizePlacement: Texture.ImagePlacement {
        get { model.resizePlacement }
        set { model.resizePlacement = newValue }
    }
    public var resizeResolution: Resolution? {
        get { model.resizeResolution }
        set {
            model.resizeResolution = newValue
            guard newValue != resizeResolution else { return }
            setNeedsBuffer()
        }
    }
    var resizedResolution: Resolution?
    
    @available(*, deprecated)
    public var tint: Bool = false
    @available(*, deprecated)
    public var tintColor: PixelColor = .white
    @available(*, deprecated)
    public var bgColor: PixelColor = .clear

    // MARK: - Property Helpers
    
    public override var values: [Floatable] {
        [tint, tintColor, bgColor, flip, swizzle]
    }
    
    // MARK: - Life Cycle
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
    }
    
    #if os(macOS)
    public convenience init(image: NSImage) {
        self.init()
        self.image = image
        setNeedsBuffer()
    }
    #else
    public convenience init(image: UIImage) {
        self.init()
        self.image = image
        setNeedsBuffer()
    }
    #endif
    public convenience init(named name: String) {
        self.init()
        self.image = UINSImage(named: name)
        setNeedsBuffer()
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard var image = image else {
            PixelKit.main.logger.log(node: self, .debug, .resource, "Setting Image to Nil")
            clearRender()
            imageLoaded = false
            return
        }
        if let res = resizeResolution {
            image = Texture.resize(image, to: res.size, placement: resizePlacement)
            resizedResolution = image.resolution
        }
        let bits: Bits = pixelKit.render.bits
//        if bits == ._16 {
//            do {
//                let texture: MTLTexture = try Texture.loadTexture(from: image, device: PixelKit.main.render.metalDevice)
//                resourceTexture = texture
//            } catch {
//                PixelKit.main.logger.log(node: self, .error, .resource, "Float16 requires iOS 14 or macOS 11.", loop: true, e: error)
//            }
//        } else {
        guard let buffer: CVPixelBuffer = Texture.buffer(from: image, bits: bits) else {
            PixelKit.main.logger.log(node: self, .error, .resource, "Pixel Buffer creation failed.", loop: true)
            return
        }
        resourcePixelBuffer = buffer
//        }
        PixelKit.main.logger.log(node: self, .info, .resource, "Image Loaded.")
        applyResolution { [weak self] in
            self?.imageLoaded = true
            self?.render()
            PixelKit.main.render.delay(frames: 10, done: { [weak self] in
                self?.render()
            })
            PixelKit.main.render.delay(frames: 60, done: { [weak self] in
                self?.render()
            })
        }
    }
    
}
