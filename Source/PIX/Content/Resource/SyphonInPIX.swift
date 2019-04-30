//
//  SyphonInPIX.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-29.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import AppKit
import GLKit
import OpenGL

public class SyphonInPIX: PIXResource {
    
    override open var shader: String { return "contentResourcePIX" }
    
    var context: NSOpenGLContext?
    var clinet: SyphonClient?
    
//    var eaglContext: EAGLContext!
//    var frameBuffer: SRFrameBuffer!
    var cvGlTextureCache: CVOpenGLTextureCache!
    var cvGlTexture: CVOpenGLTexture!
    
    // MARK: - Public Properties
    
    public override init() {
        super.init()
        RunLoop.current.add(Timer(timeInterval: 1.0, repeats: true, block: { t in
            guard self.clinet == nil else { return }
            self.scan()
        }), forMode: .common)
    }
    
    func scan() {
        let servers = SyphonServerDirectory.shared()!.servers!
        guard let server = servers.first else { return }
        setup(server: server)
    }
    
    func setup(server: Any) {
//        eaglContext = EAGLContext()
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
        clinet = SyphonClient(serverDescription: server as? [AnyHashable : Any], context: context!.cglContextObj, options: nil, newFrameHandler: { client in
            guard let frameImage = self.clinet!.newFrameImage() else { return }
            let size = frameImage.textureSize
            let glTexture = frameImage.textureName
            self.render(glTexture: glTexture, at: size)
        })
        if clinet == nil {
            pixels.log(.error, .connection, "Syphon client init failed.")
        }
    }
    
    func render(glTexture: GLuint, at size: NSSize) {
        var glTexture = glTexture
        
        if pixelBuffer != nil {
            CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.readOnly)
        }

        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32RGBA, nil, &pixelBuffer)

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer!)

//        glBindTexture(GLenum(GL_TEXTURE_2D), glTexture)
//        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(size.width), GLsizei(size.height))
        
        
//        let attributes: [CGLPixelFormatAttribute] = [
//            kCGLPFADepthSize,
//            _CGLPixelFormatAttribute(rawValue: 24),
//            _CGLPixelFormatAttribute(rawValue: 0)
//        ]
//        var pixelFormatObj: CGLPixelFormatObj? = nil
//        var numPixelFormats: GLint = 0
//        CGLChoosePixelFormat(attributes, &pixelFormatObj, &numPixelFormats)
//
//        let err: CVReturn = CVOpenGLTextureCacheCreate(kCFAllocatorDefault, nil, context!.cglContextObj!, pixelFormatObj!, nil, &cvGlTextureCache)
//        if err != 0 {
//            print("CVOpenGLESTextureCacheCreate error:", err)
//            return
//        }
//
//        var empty: CFDictionary?
//        var attrs: CFMutableDictionary?
//        var key = kCFTypeDictionaryKeyCallBacks
//        var val = kCFTypeDictionaryValueCallBacks
//        empty = CFDictionaryCreate(kCFAllocatorDefault, nil, nil, 0, &key, &val)
//        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &key, &val)
//
//        var ioSurf = kCVPixelBufferIOSurfacePropertiesKey
//        CFDictionarySetValue(attrs, &ioSurf, &empty)
//        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
//
//        CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, cvGlTextureCache, pixelBuffer!, nil, &cvGlTexture)

        
        
//        frameBuffer = SRFrameBuffer(context: context, withSize: CGSize(width: 512, height: 512))
//        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, frameBuffer.target, &formatDescription)

        
        
//        glBindBuffer(CVOpenGLTextureGetTarget(pixelBuffer!), CVOpenGLTextureGetName(pixelBuffer!))
        
//        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil) //GL_UNSIGNED_INT_8_8_8_8_REV
        
        glGenTextures(1, &glTexture)
        glBindTexture(GLenum(GL_TEXTURE_2D), glTexture)
        glCopyTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLenum(GL_RGBA), 0, 0, GLsizei(size.width), GLsizei(size.height), 0)
        
//        glGetTexImage(0, 1, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &pixelBuffer)
        
        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 1)
        glGetTexImage(GLenum(GL_TEXTURE_2D), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), baseAddress)
        
//        glReadPixels(0, 0, GLsizei(size.width), GLsizei(size.height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), baseAddress)
        
//        return raw_frame;
        
//        glGenFramebuffers(1, &glTexture);
//        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), glTexture);
//        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(size.width), GLsizei(size.height));

//        glGenFramebuffers(1, &glTexture);
//        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), glTexture);
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLTextureGetName(pixelBuffer!), 0);
//        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), glTexture);
//
//        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GL_FRAMEBUFFER_COMPLETE {
//            print("failed to make complete framebuffer object:", glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)));
//        }
        
//        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
//        IOSurface
        
//        let x: Int = 0
//        let y: Int = 0
//        let dataLength: Int = Int(size.width) * Int(size.height) * 4
//        let pixels: UnsafeMutableRawPointer? = malloc(dataLength * MemoryLayout<GLubyte>.size)
//        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 4)
//        glReadPixels(GLint(x), GLint(y), GLsizei(size.width), GLsizei(size.height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixels)
//        let pixelData: UnsafePointer = (UnsafeRawPointer(pixels)?.assumingMemoryBound(to: UInt8.self))!
//        let cfdata: CFData = CFDataCreate(kCFAllocatorDefault, pixelData, dataLength * MemoryLayout<GLubyte>.size)
//
//        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
//
//        let iref: CGImage? = CGImage(width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(size.width)*4, space: Pixels.main.colorSpace.cg, bitmapInfo: CGBitmapInfo.byteOrder32Big, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
//        UIGraphicsBeginImageContext(size)
//        let cgcontext: CGContext? = UIGraphicsGetCurrentContext()
//        cgcontext!.setBlendMode(CGBlendMode.copy)
//        cgcontext!.draw(iref, in: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(width), height: CGFloat(height)))
//        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()

        applyRes { self.setNeedsRender() }
        
    }
    
}
