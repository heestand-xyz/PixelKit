//
//  RecPIX.swift
//  Pixels
//
//  Created by Hexagons on 2017-12-15.
//  Open Source - MIT License
//

//import UIKit
import AVKit

public class RecPIX: PIXOutput { //AVAudioRecorderDelegate {
    
    // MARK: - Private Properties
    
    var recording: Bool
    var frameIndex: Int
    var startDate: Date?
    var lastFrameDate: Date?
    var writer: AVAssetWriter?
    var writerVideoInput: AVAssetWriterInput?
    var writerAdoptor: AVAssetWriterInputPixelBufferAdaptor?
    var currentImage: CGImage?
    var exportUrl: URL?
    
    public var audioOffset: CMTime = .zero
    
    public var recordAudio: Bool = false {
        didSet {
            if recordAudio {
                audioRecHelper = AudioRecHelper()
            } else {
                audioRecHelper = nil
            }
        }
    }
    var audioRecHelper: AudioRecHelper?
    var audioStartTime: CMTime?
//    var recordingSession: AVAudioSession?
//    var audioRecorder: AVAudioRecorder?
    
    // MARK: - Public Properties
    
    public var fps: Int = 30
    public var timeSync: Bool = true
    public var realtime: Bool = false
    
    // MARK: - Property Helpers
    
//    enum CodingKeys: String, CodingKey {
//        case fps; case realtime
//    }
    
    var customName: String?
    
    // MARK: - Life Cycle
    
    override public init() {
        
        recording = false
        realtime = true
        fps = 30
        frameIndex = 0
        lastFrameDate = nil
        writer = nil
        writerVideoInput = nil
        writerAdoptor = nil
        currentImage = nil
        exportUrl = nil
        
        super.init()

        realtimeListen()
        
    }
    
//    // MARK: - JSON
//
//    required convenience init(from decoder: Decoder) throws {
//        self.init()
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        fps = try container.decode(Int.self, forKey: .fps)
//        realtime = try container.decode(Bool.self, forKey: .realtime)
//        setNeedsRender()
//    }
//
//    public override func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(fps, forKey: .fps)
//        try container.encode(realtime, forKey: .realtime)
//    }
    
    // MARK: - Record
    
    public func startRec(name: String? = nil) throws {
        customName = name
        try startRecord()
    }
    
    public func stopRec(_ exported: @escaping (URL) -> ()) {
        guard recording else { return }
        stopRecord(done: {
            guard let url = self.exportUrl else { return }
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
            if lastFrameDate == nil || -lastFrameDate!.timeIntervalSinceNow >= 1.0 / Double(fps) {
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
        
        startDate = Date()
        
        guard connectedIn else {
            throw RecordError.noInPix
        }
        guard let res = resolution else {
            throw RecordError.noRes
        }
        
//        if recordAudio { try setupAudio() }
        try setup(res: res)
    
        frameIndex = 0
        recording = true
        
    }
    
//    func setupAudio() throws {
//
//        recordingSession = AVAudioSession.sharedInstance()
//
//        try recordingSession!.setCategory(.record, mode: .default)
//        try recordingSession!.setActive(true)
//
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//        audioRecorder!.delegate = self
//        audioRecorder!.record()
//
//    }
    
    func setup(res: Res) throws {
        
        let id = UUID()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd HHmss"
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
        
        let name = customName ?? "Pixels Export \(dateStr)"
        exportUrl = id_url.appendingPathComponent("\(name).mov") // CHECK CLEAN

        writer = try AVAssetWriter(outputURL: exportUrl!, fileType: .mov)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: res.w,
            AVVideoHeightKey: res.h
        ]
        writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerVideoInput!.expectsMediaDataInRealTime = true
        writer!.add(writerVideoInput!)
        
        
        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(pixels.bits.osARGB),
            kCVPixelBufferWidthKey as String: res.w,
            kCVPixelBufferHeightKey as String: res.h
        ]
        
        writerAdoptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerVideoInput!, sourcePixelBufferAttributes: sourceBufferAttributes)
        
//            let x = AVAssetWriterInputMetadataAdaptor
        
        if recordAudio {
            if let input = audioRecHelper?.writerAudioInput {
                writer!.add(input)
                audioRecHelper!.captureSession?.startRunning()
                audioRecHelper!.sampleCallback = { sampleBuffer in
                    if self.audioStartTime == nil {
                        self.audioStartTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        self.writer!.startSession(atSourceTime: self.audioStartTime!)
                    }
                    let success = input.append(sampleBuffer)
                    if !success {
                        Pixels.main.log(.error, nil, "Audio Rec sample faied to write.")
                    }
                }
            }
        } else {
            writer!.startSession(atSourceTime: .zero)
        }

        writer!.startWriting()
        
        let media_queue = DispatchQueue(label: "mediaInputQueue")
        
        writerVideoInput!.requestMediaDataWhenReady(on: media_queue, using: {
            
            guard self.recording else { return }
            
            if self.currentImage != nil {
                
                if self.writerVideoInput!.isReadyForMoreMediaData { // && self.recording
                    
                    let time: CMTime
                    if self.timeSync {
                        let duration = -self.startDate!.timeIntervalSinceNow
                        if self.recordAudio {
                            guard let startTime = self.audioStartTime else { return }
                            let offsetDuration = CMTimeGetSeconds(startTime) + duration + CMTimeGetSeconds(self.audioOffset)
                            time = CMTime(seconds: offsetDuration, preferredTimescale: Int32(self.fps))
                        } else {
                            time = CMTime(seconds: duration, preferredTimescale: Int32(self.fps))
                        }
                    } else {
                        time = CMTime(value: Int64(self.frameIndex), timescale: Int32(self.fps))
                    }
                    
                    if !self.appendPixelBufferForImageAtURL(self.writerAdoptor!, presentation_time: time, cg_image: self.currentImage!) {
                        self.pixels.log(pix: self, .error, nil, "Export Frame. Status: \(self.writer!.status.rawValue).", e: self.writer!.error)
                    }
                    
                    self.lastFrameDate = Date()
                    self.frameIndex += 1
                    
                } else {
                    self.pixels.log(pix: self, .error, nil, "isReadyForMoreMediaData is false.")
                }
                
                self.currentImage = nil
                
            }
            
        })
//
//        } catch {
//            self.pixels.log(pix: self, .error, nil, "Creating new asset writer.", e: error)
//        }
        
    }
    
    func recordFrame(texture: MTLTexture) {
        
        if writer != nil && writerVideoInput != nil && writerAdoptor != nil {
        
            let ci_image = CIImage(mtlTexture: texture, options: nil)
            if ci_image != nil {
                #if os(iOS)
                // FIXME: Debug
                EAGLContext.setCurrent(nil)
                #endif
                let context = CIContext.init(options: nil)
                let cg_image = context.createCGImage(ci_image!, from: ci_image!.extent)
                if cg_image != nil {
                    
                    currentImage = cg_image!
                
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
        
//        audioRecorder?.stop()
        audioRecHelper?.captureSession?.stopRunning()
        audioRecHelper?.writerAudioInput?.markAsFinished()
        
        writerVideoInput?.markAsFinished()
        writer?.finishWriting {
            if let writer = self.writer {
                if writer.status == .completed {
                    DispatchQueue.main.async {
                        done()
                    }
                } else if writer.error == nil {
                    self.pixels.log(pix: self, .error, nil, "Rec Stop. Cancelled. Writer Status: \(writer.status).")
                } else {
                    self.pixels.log(pix: self, .error, nil, "Rec Stop. Writer Error. Writer Status: \(writer.status).", e: writer.error)
                }
            } else {
                self.pixels.log(pix: self, .error, nil, "Writer not found")
            }
            self.writerVideoInput = nil
            self.writer = nil
        }
        
//        try? recordingSession?.setActive(false)
//        recordingSession = nil
//        audioRecorder?.delegate = nil
//        audioRecorder = nil
        
        audioStartTime = nil
        frameIndex = 0
        recording = false
        startDate = nil
        
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
//                    pixel_buffer_pointer.deinitialize()
                    
                } else {
                    self.pixels.log(pix: self, .error, nil, "Allocating pixel buffer from pool.")
                }
                
//                pixel_buffer_pointer.deallocate(capacity: 1)
                
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
    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if !flag {
//
//        }
//    }
    
}

class AudioRecHelper: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    var captureSession: AVCaptureSession?
    var audioOutput: AVCaptureAudioDataOutput?
    var writerAudioInput: AVAssetWriterInput?
    
    var sampleCallback: ((CMSampleBuffer) -> ())?
    
    override init() {
        
        super.init()
        
        captureSession = AVCaptureSession()
        
        let audioSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44_100,
//            AVEncoderBitRateKey: 128_000
        ]
        writerAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        writerAudioInput!.expectsMediaDataInRealTime = true
        
        let microphone = AVCaptureDevice.default(for: .audio)!
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession!.canAddInput(micInput){
                captureSession!.addInput(micInput)
            }
            
            audioOutput = AVCaptureAudioDataOutput()
            if captureSession!.canAddOutput(audioOutput!){
                captureSession!.addOutput(audioOutput!)
            }
            let captureSessionQueue = DispatchQueue(label: "MicSessionQueue", attributes: [])
            audioOutput!.setSampleBufferDelegate(self, queue: captureSessionQueue)
            
            captureSession!.commitConfiguration()
            
        } catch {
            Pixels.main.log(.error, nil, "Audo Rec Helper setup failed.", e: error)
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return }
        guard let input = writerAudioInput else { return }
        guard input.isReadyForMoreMediaData else { return }
        sampleCallback?(sampleBuffer)
    }
    
}
