//
//  RecPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2017-12-15.
//  Open Source - MIT License
//

import AVKit

public class RecPIX: PIXOutput {
    
    // MARK: - Private Properties
    
    var recording: Bool
    var paused: Bool
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
    var pausedDate: Date?
    var pausedDuration: Double = 0.0

    // MARK: - Public Properties
    
    public var fps: Int = 30
    public var timeSync: Bool = true
    public var realtime: Bool = false
    public var directMode: Bool = true
    
    // MARK: - Property Helpers
    
    var customName: String?
    
    enum RecError: Error {
        case setup(String)
    }
    
    // MARK: - Life Cycle
    
    override public init() {
        
        recording = false
        paused = false
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
    
    // MARK: - Record
    
    public func startRec(name: String? = nil) throws {
        pixelKit.log(.info, nil, "Rec start.")
        customName = name
        try startRecord()
    }
    
    public func pauseRec() {
        pixelKit.log(.info, nil, "Rec pause.")
        pauseRecord()
    }
    
    public func resumeRec() {
        pixelKit.log(.info, nil, "Rec resume.")
        resumeRecord()
    }
    
    public func stopRec(_ exported: @escaping (URL) -> ()) {
        pixelKit.log(.info, nil, "Rec stop.")
//        guard recording else { return }
        stopRecord(done: {
            guard let url = self.exportUrl else { return }
            exported(url)
        })
    }
    
    // MARK: Export
    
    func realtimeListen() {
        pixelKit.listenToFrames(callback: {
            self.frameLoop()
        })
    }
    
    func frameLoop() {
        if !directMode && recording && realtime && connectedIn {
            if lastFrameDate == nil || -lastFrameDate!.timeIntervalSinceNow >= 1.0 / Double(fps) {
                if let texture = inPix?.texture {
                    DispatchQueue.global(qos: .background).async {
                        self.recordFrame(texture: texture)
                    }
                }
            }
        }
    }
    
    override public func didRender(texture: MTLTexture, force: Bool) {
        if !directMode && recording && !realtime {
            DispatchQueue.global(qos: .background).async {
                self.recordFrame(texture: texture)
            }
        }
        super.didRender(texture: texture)
    }
    
    enum RecordError: Error {
        case noInPix
        case noRes
    }
    
    func startRecord() throws {
        
        guard connectedIn else {
            throw RecordError.noInPix
        }
        guard let res = resolution else {
            throw RecordError.noRes
        }

        try self.setup(res: res)
    
        self.startDate = Date()
        self.frameIndex = 0
        self.recording = true
        
    }
    
    func pauseRecord() {
        paused = true
        pausedDate = Date()
    }
    
    func resumeRecord() {
        paused = false
        pausedDuration += -pausedDate!.timeIntervalSinceNow
        pausedDate = nil
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
        let pixelKit_url = documents_url.appendingPathComponent("pixelKit")
        let renders_url = pixelKit_url.appendingPathComponent("renders")
        let id_url = renders_url.appendingPathComponent(id.uuidString)
        do {
            try FileManager.default.createDirectory(at: id_url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            pixelKit.log(pix: self, .error, nil, "Creating exports folder.", e: error)
            throw RecError.setup("Creating exports folder.")
        }
        
        let name = customName ?? "PixelKit Export \(dateStr)"
        exportUrl = id_url.appendingPathComponent("\(name).mov") // CHECK CLEAN

        writer = try AVAssetWriter(outputURL: exportUrl!, fileType: .mov)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: res.w,
            AVVideoHeightKey: res.h
        ]
        writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerVideoInput!.expectsMediaDataInRealTime = true
        writer!.add(writerVideoInput!)
        
        
        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(pixelKit.bits.osARGB),
            kCVPixelBufferWidthKey as String: res.w,
            kCVPixelBufferHeightKey as String: res.h,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferCGImageCompatibilityKey as String: true
        ]
        
        writerAdoptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerVideoInput!, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        writer!.startWriting()
        
        if recordAudio {
            if let input = audioRecHelper?.writerAudioInput {
                writer!.add(input)
                audioRecHelper!.captureSession?.startRunning()
                audioRecHelper!.sampleCallback = { sampleBuffer in
                    if self.audioStartTime == nil {
                        self.audioStartTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        guard self.writer!.status != .unknown else {
                            PixelKit.main.log(.error, nil, "Audio Rec: Writer status is unknown.")
                            return
                        }
                        self.writer!.startSession(atSourceTime: self.audioStartTime!)
                    }
                    let success = input.append(sampleBuffer)
                    if !success {
                        PixelKit.main.log(.error, nil, "Audio Rec: Sample faied to write.")
                    }
                }
            }
        } else {
            writer!.startSession(atSourceTime: .zero)
        }
        
        let media_queue = DispatchQueue(label: "mediaInputQueue")
        
        writerVideoInput!.requestMediaDataWhenReady(on: media_queue, using: {
            
            guard self.recording && !self.paused else { return }
            
            if self.directMode {
                guard let texture = self.texture else { return }
                self.recordFrame(texture: texture)
            }
            
            if self.currentImage != nil {
                
                if self.writerVideoInput!.isReadyForMoreMediaData { // && self.recording
                    
                    let time: CMTime
                    if self.timeSync {
                        let duration = -self.startDate!.timeIntervalSinceNow
                        if self.recordAudio {
                            guard let startTime = self.audioStartTime else { return }
                            let offsetDuration = CMTimeGetSeconds(startTime) + duration + CMTimeGetSeconds(self.audioOffset) - self.pausedDuration
                            time = CMTime(seconds: offsetDuration, preferredTimescale: Int32(NSEC_PER_SEC))
                        } else {
                            time = CMTime(seconds: duration - self.pausedDuration, preferredTimescale: Int32(NSEC_PER_SEC))
                        }
                    } else {
                        time = CMTime(value: Int64(self.frameIndex), timescale: Int32(self.fps))
                    }
                    
                    if !self.appendPixelBufferForImageAtURL(self.writerAdoptor!, presentation_time: time, cg_image: self.currentImage!) {
                        self.pixelKit.log(pix: self, .error, nil, "Export Frame. Status: \(self.writer!.status.rawValue).", e: self.writer!.error)
                    }
                    
                    self.lastFrameDate = Date()
                    self.frameIndex += 1
                    
                } else {
                    self.pixelKit.log(pix: self, .error, nil, "isReadyForMoreMediaData is false.")
                }
                
                self.currentImage = nil
                
            }
            
        })
        
    }
    
    func recordFrame(texture: MTLTexture) {
        
        if recording && !self.paused && writer != nil && writerVideoInput != nil && writerAdoptor != nil {
        
            let options: [CIImageOption : Any] = [
                CIImageOption.colorSpace: pixelKit.colorSpace.cg
            ]
            let ci_image = CIImage(mtlTexture: texture, options: options)
            if ci_image != nil {
                #if os(iOS)
                // FIXME: Debug
                EAGLContext.setCurrent(nil)
                #endif
                let context = CIContext.init(options: nil)
                let cg_image = context.createCGImage(ci_image!, from: ci_image!.extent, format: pixelKit.bits.ci, colorSpace: pixelKit.colorSpace.cg)
                if cg_image != nil {
                    
                    currentImage = flip(cg_image!)
                
                } else {
                    self.pixelKit.log(pix: self, .error, nil, "cg_image is nil.")
                }
            } else {
                self.pixelKit.log(pix: self, .error, nil, "ci_image is nil.")
            }
            
        } else {
            self.pixelKit.log(pix: self, .error, nil, "Some writer is nil.")
        }
        
    }
    
    func flip(_ cgImage: CGImage) -> CGImage? {
        guard let size = resolution?.size else { return nil }
        guard let context = CGContext(data: nil,
                                      width: Int(size.width.cg),
                                      height: Int(size.height.cg),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4 * Int(size.width.cg),
                                      space: pixelKit.colorSpace.cg,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                                      ) else { return nil }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -size.height.cg)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width.cg, height: size.height.cg))
        guard let image = context.makeImage() else { return nil }
        return image
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
                    self.pixelKit.log(pix: self, .error, nil, "Rec Stop. Cancelled. Writer Status: \(writer.status).")
                } else {
                    self.pixelKit.log(pix: self, .error, nil, "Rec Stop. Writer Error. Writer Status: \(writer.status).", e: writer.error)
                }
            } else {
                self.pixelKit.log(pix: self, .error, nil, "Writer not found")
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
        paused = false
        startDate = nil
        pausedDuration = 0
        pausedDate = nil
        
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
                    self.pixelKit.log(pix: self, .error, nil, "Allocating pixel buffer from pool.")
                }
                
//                pixel_buffer_pointer.deallocate(capacity: 1)
                
            } else {
                self.pixelKit.log(pix: self, .error, nil, "pixel_buffer_adoptor.pixelBufferPool is nil")
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
            PixelKit.main.log(.error, nil, "Record context failed.")
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
            PixelKit.main.log(.error, nil, "Audo Rec Helper setup failed.", e: error)
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return }
        guard let input = writerAudioInput else { return }
        guard input.isReadyForMoreMediaData else { return }
        sampleCallback?(sampleBuffer)
    }
    
}
