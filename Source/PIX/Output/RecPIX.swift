//
//  RecPIX.swift
//  Pixels
//
//  Created by Hexagons on 2017-12-15.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit
import AVKit

public class RecPIX: PIXOutput, PIXofaKind {
    
    let kind: PIX.Kind = .rec
    
    var recording: Bool
    var frame_index: Int
    var last_frame_date: Date?
    var writer: AVAssetWriter?
    var writer_input: AVAssetWriterInput?
    var writer_adoptor: AVAssetWriterInputPixelBufferAdaptor?
    var current_frame: CGImage?
    var export_url: URL?

    public var fps: Int = 30
    public var realtime: Bool = true
    enum CodingKeys: String, CodingKey {
        case fps; case realtime
    }
    
    override public init() {
        
        recording = false
        let default_realtime = true
        realtime = default_realtime
        let default_fps = 30
        fps = default_fps
        frame_index = 0
        last_frame_date = nil
        writer = nil
        writer_input = nil
        writer_adoptor = nil
        current_frame = nil
        export_url = nil
        
        super.init()

        realtimeListen()
        
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fps = try container.decode(Int.self, forKey: .fps)
        realtime = try container.decode(Bool.self, forKey: .realtime)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fps, forKey: .fps)
        try container.encode(realtime, forKey: .realtime)
    }
    
    // MARK: Record
    
    public func startRec() throws {
        try startRecord()
    }
    
    public func stopRec(_ exported: @escaping (URL) -> ()) {
        guard recording else { return }
        stopRecord(done: {
            guard let url = self.export_url else { return }
            exported(url)
        })
    }
    
//    public func export() -> URL {
//
//    }
    
    // MARK: Export
    
    func realtimeListen() {
        pixels.listenToFrames(callback: { () -> (Bool) in
            self.frameLoop()
            return false
        })
    }
    
    func frameLoop() {
        if recording && realtime && connectedIn {
            if last_frame_date == nil || -last_frame_date!.timeIntervalSinceNow >= 1.0 / Double(fps) {
                if let texture = inPix?.texture {
                    recordFrame(texture: texture)
                }
            }
        }
    }
    
    override public func didRender(texture: MTLTexture, force: Bool) {
        if recording && !realtime {
            recordFrame(texture: texture)
        }
        super.didRender(texture: texture)
    }
    
    enum RecordError: Error {
        case noInPix
        case noRes
//        case stopFailed
    }
    
    func startRecord() throws {
        
        guard connectedIn else {
            throw RecordError.noInPix
        }
        guard let resSize = resolution?.size else {
            throw RecordError.noRes
        }
        
        try setup(size: resSize)
    
        frame_index = 0
        recording = true
        
    }
    
    func setup(size: CGSize) throws {
        
        let id = UUID()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = dateFormatter.string(from: date)
        
        let documents_url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let pixels_url = documents_url.appendingPathComponent("pixels")
        let renders_url = pixels_url.appendingPathComponent("renders")
        let id_url = renders_url.appendingPathComponent(id.uuidString)
        do {
            try FileManager.default.createDirectory(at: id_url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            pixels.log(pix: self, .error, nil, "Creating exports folder.", e: error)
            return
        }
        
        export_url = id_url.appendingPathComponent("Pixels Export \(dateStr).mov") // CHECK CLEAN
        
        do {
            
            writer = try AVAssetWriter(outputURL: export_url!, fileType: .mov)
            let video_settings: [String: AnyObject] = [
                AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey: size.width as AnyObject,
                AVVideoHeightKey: size.height as AnyObject
            ]
            
            writer_input = AVAssetWriterInput(mediaType: .video, outputSettings: video_settings)
            writer!.add(writer_input!)
            
            let source_buffer_attributes: [String: AnyObject] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB) as AnyObject,
                kCVPixelBufferWidthKey as String: size.width as AnyObject,
                kCVPixelBufferHeightKey as String: size.height as AnyObject
            ]
            writer_adoptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writer_input!, sourcePixelBufferAttributes: source_buffer_attributes)
            
            writer!.startWriting()
            writer!.startSession(atSourceTime: .zero)
            
            let media_queue = DispatchQueue(label: "mediaInputQueue")
            
            writer_input!.requestMediaDataWhenReady(on: media_queue, using: {
                
                if self.current_frame != nil {
                    
                    if self.writer_input!.isReadyForMoreMediaData { // && self.recording
                        
                        let presentation_time = CMTime(value: Int64(self.frame_index), timescale: Int32(self.fps))
                        
                        if !self.appendPixelBufferForImageAtURL(self.writer_adoptor!, presentation_time: presentation_time, cg_image: self.current_frame!) {
                            self.pixels.log(pix: self, .error, nil, "Export Frame. Status: \(self.writer!.status.rawValue).", e: self.writer!.error)
                        }
                        
                        self.last_frame_date = Date()
                        self.frame_index += 1
                        
                    } else {
                        self.pixels.log(pix: self, .error, nil, "isReadyForMoreMediaData is false.")
                    }
                    
                    self.current_frame = nil
                    
                }
                
            })
            
        } catch {
            self.pixels.log(pix: self, .error, nil, "Creating new asset writer.", e: error)
        }
        
    }
    
    func recordFrame(texture: MTLTexture) {
        
        if writer != nil && writer_input != nil && writer_adoptor != nil {
        
            let ci_image = CIImage(mtlTexture: texture, options: nil)
            if ci_image != nil {
                EAGLContext.setCurrent(nil) // CHECK TESTING
                let context = CIContext.init(options: nil)
                let cg_image = context.createCGImage(ci_image!, from: ci_image!.extent)
                if cg_image != nil {
                    
                    current_frame = cg_image!
                
                } else {
                    self.pixels.log(pix: self, .error, nil, "cg_image is nil.")
                }
            } else {
                self.pixels.log(pix: self, .error, nil, "ci_image is nil.")
            }
            
        } else {
            self.pixels.log(pix: self, .error, nil, "Some writer is nil.")
        }
        
    }
    
    func stopRecord(done: @escaping () -> ()) {
        
        if writer != nil && writer_input != nil && writer_adoptor != nil {
            
            writer_input!.markAsFinished()
            writer!.finishWriting {
                if self.writer!.error == nil {
                    DispatchQueue.main.async {
                        done()
                    }
                } else {
                    self.pixels.log(pix: self, .error, nil, "Convering images to video failed. Status: \(self.writer!.status.rawValue).", e: self.writer!.error)
                }
            }
            
            
        } else {
//            throw RecordError.stopFailed
            pixels.log(pix: self, .error, nil, "Some writer is nil.")
        }

        frame_index = 0
        recording = false
        
    }
    
    func appendPixelBufferForImageAtURL(_ pixel_buffer_adoptor: AVAssetWriterInputPixelBufferAdaptor, presentation_time: CMTime, cg_image: CGImage) -> Bool {
        
        var append_succeeded = false
        
        autoreleasepool {
            
            if let pixel_buffer_pool = pixel_buffer_adoptor.pixelBufferPool {
                
                let pixel_buffer_pointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixel_buffer_pool,
                    pixel_buffer_pointer
                )
                
                if let pixel_buffer = pixel_buffer_pointer.pointee, status == 0 {
                    
                    fillPixelBufferFromImage(pixel_buffer, cg_image: cg_image)
                    append_succeeded = pixel_buffer_adoptor.append(pixel_buffer, withPresentationTime: presentation_time)
                    pixel_buffer_pointer.deinitialize()
                    
                } else {
                    self.pixels.log(pix: self, .error, nil, "Allocating pixel buffer from pool.")
                }
                
                pixel_buffer_pointer.deallocate(capacity: 1)
                
            } else {
                self.pixels.log(pix: self, .error, nil, "pixel_buffer_adoptor.pixelBufferPool is nil")
            }
            
        }
        
        return append_succeeded
        
    }
    
    func fillPixelBufferFromImage(_ pixel_buffer: CVPixelBuffer, cg_image: CGImage) {
        
        CVPixelBufferLockBaseAddress(pixel_buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pixel_data = CVPixelBufferGetBaseAddress(pixel_buffer)
        let rgb_color_space = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixel_data,
            width: Int(cg_image.width),
            height: Int(cg_image.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixel_buffer),
            space: rgb_color_space,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            )
        
        guard let c = context else {
            Pixels.main.log(.error, nil, "Record context failed.")
            return
        }
        
        let draw_cg_rect = CGRect(x: 0, y: 0, width: cg_image.width, height: cg_image.height)
        c.draw(cg_image, in: draw_cg_rect)
        
        CVPixelBufferUnlockBaseAddress(pixel_buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
    }
    
}
