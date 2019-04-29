//
//  SyphonInPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-29.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import AppKit

public class SyphonInPIX: PIXResource {
    
    override open var shader: String { return "contentResourcePIX" }
    
    var context: NSOpenGLContext?
    var clinet: SyphonClient?
    
    // MARK: - Public Properties
    
    public override init() {
        super.init()
        RunLoop.current.add(Timer(timeInterval: 1.0, repeats: true, block: { t in
            guard clinet == nil else { return }
            self.scan()
        }), forMode: .common)
    }
    
    func scan() {
        print("scan:")
        let servers = SyphonServerDirectory.shared()!.servers!
        guard let server = servers.first else { return }
    }
    
    func setup(server: Any) {
        let glPFAttributes: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), UInt32(24),
            UInt32(NSOpenGLPFAAlphaSize), UInt32(8),
            UInt32(NSOpenGLPFAMultisample),
            UInt32(NSOpenGLPFASampleBuffers), UInt32(1),
            UInt32(NSOpenGLPFASamples), UInt32(4),
            UInt32(NSOpenGLPFAMinimumPolicy),
            UInt32(0)
        ]
        let format = NSOpenGLPixelFormat(attributes: glPFAttributes)!
        context = NSOpenGLContext(format: format, share: nil)
        clinet = SyphonClient(serverDescription: ["server": server], context: context!.cglContextObj, options: nil, newFrameHandler: { client in
            let frameImage = self.clinet!.newFrameImage()
            let size = frameImage?.textureSize
            let glTexture = frameImage?.textureName
            
            
            
            
            
            
            
        })
    }
    
}
