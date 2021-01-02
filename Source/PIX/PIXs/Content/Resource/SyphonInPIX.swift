//
//  SyphonInPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-29.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import AppKit
import GLKit
import OpenGL

public class SyphonInPIX: PIXResource {
    
    override open var shaderName: String { return "contentResourcePIX" }
    
    var context: NSOpenGLContext?
    var clinet: SyphonClient?
    
//    var eaglContext: EAGLContext!
//    var frameBuffer: SRFrameBuffer!
//    var cvGlTextureCache: CVOpenGLTextureCache!
//    var cvGlTexture: CVOpenGLTexture!
    var cvPixelBuffer: CVPixelBuffer?
    
    var tex: GLuint = 0
    var fbo: GLuint = 0
    var pbo: GLuint = 0
    var prevFBO: GLint = 0
    var prevReadFBO: GLint = 0
    var prevDrawFBO: GLint = 0
    var prevPBO: GLint = 0
    
    var firstFrame = true
    
    // MARK: - Public Properties
    
    public override init() {
        super.init(name: "Syphon In", typeName: "pix-content-resource-syphon-in")
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
            if size != self.resolution?.size {
                self.glSetup(at: size)
            }
            let glTexture = frameImage.textureName
            self.render(glTexture: glTexture, at: size)
        })
        if clinet == nil {
            pixelKit.logger.log(.error, .connection, "Syphon client init failed.")
        }
    }
    
    func glSetup(at size: NSSize) {
//        // Set-up: usually do this once and re-use these resources, however you may
//        // have to recreate them if the dimensions change
//
//        // Set-up: usually do this once and re-use these resources, however you may
//        // have to recreate them if the dimensions change
//
//
//        // Store previous state
//        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &prevFBO)
//        glGetIntegerv(GLenum(GL_READ_FRAMEBUFFER_BINDING), &prevReadFBO)
//        glGetIntegerv(GLenum(GL_DRAW_FRAMEBUFFER_BINDING), &prevDrawFBO)
//
//        // Push attribs
////        glPushAttrib(GL_ALL_SHADER_BITS)
//
//        glEnable(GLenum(GL_TEXTURE_RECTANGLE))
//
//        // Create the texture we draw into
//        glGenTextures(1, &tex)
//        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), tex)
//        glTexImage2D(GLenum(GL_TEXTURE_RECTANGLE), 0, GL_RGBA8, GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_BGRA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), nil)
//
//        // Create the FBO
//        glGenFramebuffers(1, &fbo)
//        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
//
//        // Test that binding works
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_RECTANGLE), tex, 0)
//        let status: GLenum = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
//        if status != GL_FRAMEBUFFER_COMPLETE {
//            // Deal with this error - you won't be able to draw into the FBO
//            pixelKit.logger.log(.error, .connection, "Syphon In FBO failed.")
//        }
//
//        // Restore state we're done with thus-far
//        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), 0)
//        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLuint(prevFBO))
//        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), GLuint(prevReadFBO))
//        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), GLuint(prevDrawFBO))
//
//        // Save PBO state
//        glGetIntegerv(GLenum(GL_PIXEL_PACK_BUFFER_BINDING), &prevPBO)
//
//        // Create our PBO and request storage for it
//        glGenBuffers(1, &pbo)
//        glBindBuffer(GLenum(GL_PIXEL_PACK_BUFFER), pbo)
//        glBufferData(GLenum(GL_PIXEL_PACK_BUFFER), Int(size.width) * Int(size.height) * 4, nil, GLenum(GL_DYNAMIC_READ))
//        if glGetError() != GL_NO_ERROR {
//            // Storage for the PBO couldn't be allocated, deal with it here
//            pixelKit.logger.log(.error, .connection, "Syphon In PBO failed.")
//        }
//
//        // Restore state
//        glBindBuffer(GLenum(GL_PIXEL_PACK_BUFFER), GLuint(prevPBO))
////        glPopAttrib()

    }
    
    func render(glTexture: GLuint, at size: NSSize) {
//        var glTexture = glTexture
        
        
//        // Save state as above, skipped for brevity
//        glGetIntegerv(GLenum(GL_PIXEL_PACK_BUFFER_BINDING), &prevPBO)
//        
//        // The first thing we do is read data from the previous render-cycle
//        // This means the GPU has had a full frame's time to perform the download to PBO
//        // Skip this the first frame
//        if !firstFrame {
//            glBindBuffer(GLenum(GL_PIXEL_PACK_BUFFER), pbo)
//            var pixelData = glMapBuffer(GLenum(GL_PIXEL_PACK_BUFFER), GLenum(GL_READ_ONLY))
//            // Do something with the pixel data
//        }
//
//        // Now start the current frame downloading
//
//        // Attach the FBO
//        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo)
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GL_TEXTURE_RECTANGLE, tex, 0)
//
//        // Set up required state
//        glViewport(0, 0, GLsizei(size.width), GLsizei(size.height))
////        glMatrixMode(GL_PROJECTION)
////        glPushMatrix()
////        glLoadIdentity()
//
//        glOrtho(0.0, width, 0.0, height, -1, 1)
//
//        glMatrixMode(GL_MODELVIEW)
//        glPushMatrix()
//        glLoadIdentity()
//
//        // Clear
//        glClearColor(0.0, 0.0, 0.0, 0.0)
//        glClear(GL_COLOR_BUFFER_BIT)
//
//        // Bind the texture
//        glEnable(GL_TEXTURE_RECTANGLE_ARB)
//        glActiveTexture(GL_TEXTURE0)
//        glBindTexture(GL_TEXTURE_RECTANGLE, image?.textureName)
//
//        // Configure texturing as we want it
//        glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_S, GL_CLAMP)
//        glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_WRAP_T, GL_CLAMP)
//        glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
//        glTexParameteri(GL_TEXTURE_RECTANGLE, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
//        glEnable(GL_BLEND)
//        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
//        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
//
//        glColor4f(1.0, 1.0, 1.0, 1.0)
//
//        // Draw it
//        // These coords flip the texture vertically because often you'll want to do that
//        var texCoords = [0.0, height, width, height, width, 0.0, 0.0, 0.0]
//
//        var verts = [0.0, 0.0, width, 0.0, width, height, 0.0, height]
//
//        glEnableClientState(GL_TEXTURE_COORD_ARRAY)
//        glTexCoordPointer(2, GL_FLOAT, 0, texCoords)
//        glEnableClientState(GL_VERTEX_ARRAY)
//        glVertexPointer(2, GL_FLOAT, 0, verts)
//        glDrawArrays(GL_TRIANGLE_FAN, 0, 4)
//
//        // Now perform the download into the PBO
//
//        glBindBuffer(GL_PIXEL_PACK_BUFFER, pbo)
//        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, tex)
//
//        // This is a minimal setup of pixel storage - if anything else might have touched it
//        // be more explicit
//        glPixelStorei(GL_PACK_ROW_LENGTH, width)
//
//        // Start the download to PBO
//        glGetTexImage(GL_TEXTURE_RECTANGLE_ARB, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, 0)
//
//        // Restore state, skipped for brevity, see set-up section
//        // ...

        
        
        
        
        
        
        
        
        
        
        
        
//        if cvPixelBuffer != nil {
//            CVPixelBufferUnlockBaseAddress(cvPixelBuffer!, CVPixelBufferLockFlags.readOnly)
//        }
//
//        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32RGBA, nil, &cvPixelBuffer)
//        guard cvPixelBuffer != nil else {
//            print("pixel buffer failed to create")
//            return
//        }
//        CVPixelBufferLockBaseAddress(cvPixelBuffer!, CVPixelBufferLockFlags.readOnly)
//        let baseAddress = CVPixelBufferGet BaseAddress(cvPixelBuffer!)

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
//        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs, &cvPixelBuffer)
//
//        CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, cvGlTextureCache, cvPixelBuffer!, nil, &cvGlTexture)

        
        
//        frameBuffer = SRFrameBuffer(context: context, withSize: CGSize(width: 512, height: 512))
//        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, frameBuffer.target, &formatDescription)

        
        
//        glBindBuffer(CVOpenGLTextureGetTarget(cvPixelBuffer!), CVOpenGLTextureGetName(cvPixelBuffer!))
        
//        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil) //GL_UNSIGNED_INT_8_8_8_8_REV
        
//        glGenTextures(1, &glTexture)
//        glBindTexture(GLenum(GL_TEXTURE_2D), glTexture)
//        glCopyTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLenum(GL_RGBA), 0, 0, GLsizei(size.width), GLsizei(size.height), 0)
//        let length = Int(size.width * size.height * 3)
//        glGetTexImage(0, 1, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &cvPixelBuffer)
//        var pixelKit: [UInt8] = Array<UInt8>(repeating: 0, count: size) //GLubyte(exactly: Int(size.width * size.height * 4))!
//        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 1)
//        glGetTexImage(GLenum(GL_TEXTURE_2D), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &pixelKit)
        
//        print("pixel data:", pixelKit.first)
        
        
        
//
//        //Establish a New Frame Buffer
//        var frameBuffer: GLuint?
//        glGenFramebuffers(1, &frameBuffer!)
//
//
//        //Causes a clearing of the framebuffer
//        //glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
//
//
//        //Texture
//        var texture: GLuint?
//        glGenTextures(1, &texture!)
//        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), texture!)
//        glBindTexture(GLenum(GL_TEXTURE_RECTANGLE), glTexture)
//        glTexImage2D(GLenum(GL_TEXTURE_RECTANGLE), 0, GL_RGB, GLsizei(size.width), GLsizei(size.height), 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
//
//
//        glActiveTexture(GLenum(GL_TEXTURE0))
//        glEnable(GLenum(GL_TEXTURE_RECTANGLE))
//
//
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_RECTANGLE), glTexture, 0)
//
//
//        //Determins if Frame Status has been Complete
//        let status: GLenum = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
//        if status != GL_FRAMEBUFFER_COMPLETE {
//            print("NOT Complete")
//        }
//
//        // allocate array and read pixelKit into it.
//        var buffer: GLubyte? = GLubyte(exactly: length)
//        var buffer2: GLubyte? = GLubyte(exactly: length)
//
//
//        //Get Texture to Buffer
//        glGetTexImage(GLenum(GL_TEXTURE_RECTANGLE), GLint(glTexture), GLenum(GL_RGB), GLenum(GL_INT), &buffer)
//
//        //Read PixelKit frome Frame Buffer
//        glReadPixelKit(0, 0, GLsizei(size.width), GLsizei(size.height), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), &buffer2)
//
//        //NSLog(@ "Width %f  Height: %f", imageSize.width, imageSize.height);
//
//
//        //Texture
//        //NSLog(@ "Texture RGB: %d %d %d", buffer[0], buffer[1], buffer[2]);
//        //NSLog(@ "Texture RGB: %d %d %d", buffer[3], buffer[4], buffer[5]);
//
//
//        //Frame Buffer
//        //NSLog(@ "FrameBuffer RGB: %d %d %d", buffer2[0], buffer2[1], buffer2[2]);
//        //NSLog(@ "FrameBuffer RGB: %d %d %d", buffer2[3], buffer2[4], buffer2[5]);
//
//        // Close Frame Buffers etc.
//        glDeleteFramebuffers(1, &frameBuffer!)

        
        
        
        
//        glReadPixelKit(0, 0, GLsizei(size.width), GLsizei(size.height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_INT_8_8_8_8_REV), baseAddress)
        
//        return raw_frame;
        
//        glGenFramebuffers(1, &glTexture);
//        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), glTexture);
//        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(size.width), GLsizei(size.height));

//        glGenFramebuffers(1, &glTexture);
//        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), glTexture);
//        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), CVOpenGLTextureGetName(cvPixelBuffercvPixelBuffer!), 0);
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
//        let pixelKit: UnsafeMutableRawPointer? = malloc(dataLength * MemoryLayout<GLubyte>.size)
//        glPixelStorei(GLenum(GL_PACK_ALIGNMENT), 4)
//        glReadPixelKit(GLint(x), GLint(y), GLsizei(size.width), GLsizei(size.height), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixelKit)
//        let pixelData: UnsafePointer = (UnsafeRawPointer(pixelKit)?.assumingMemoryBound(to: UInt8.self))!
//        let cfdata: CFData = CFDataCreate(kCFAllocatorDefault, pixelData, dataLength * MemoryLayout<GLubyte>.size)
//
//        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
//
//        let iref: CGImage? = CGImage(width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(size.width)*4, space: PixelKit.main.colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Big, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
//        UIGraphicsBeginImageContext(size)
//        let cgcontext: CGContext? = UIGraphicsGetCurrentContext()
//        cgcontext!.setBlendMode(CGBlendMode.copy)
//        cgcontext!.draw(iref, in: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(width), height: CGFloat(height)))
//        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()

//        pixelBuffer = cvPixelBuffer
        
        applyResolution { self.setNeedsRender() }
        
        firstFrame = false
        
    }
    
}
