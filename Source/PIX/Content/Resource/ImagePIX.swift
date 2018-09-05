//
//  ImagePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-07.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class ImagePIX: PIXResource, PIXofaKind {
    
    var kind: PIX.Kind = .image
    
    override var shader: String { return "contentResourceImagePIX" }
    
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    
    public convenience init(named: String) {
        if let image = UIImage(named: named) {
            self.init(image: image)
        } else {
            self.init()
            pixels.log(.error, .resource, "Image named \"\(named)\" not found.")
        }
    }
    
    public init(image: UIImage? = nil) {
        super.init()
        if image != nil {
            self.image = image
            setNeedsBuffer() // CHECK
        }
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    override public func encode(to encoder: Encoder) throws {}
    
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
