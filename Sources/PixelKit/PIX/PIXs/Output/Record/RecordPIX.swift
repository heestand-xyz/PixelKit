//
//  RecordPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2017-12-15.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import AVKit

@available(OSX 10.13, *)
@available(iOS 11, *)
@available(tvOS 11, *)
final public class RecordPIX: PIXOutput, PIXViewable {
    
    public typealias Model = RecordPixelModel
    
    private var model: Model {
        get { outputModel as! Model }
        set { outputModel = newValue }
    }
    
    // MARK: - Private Properties
    
    private var paused: Bool = false
    private var frameIndex: Int = 0
    private var startDate: Date?
    private var lastFrameDate: Date?
    private var writer: AVAssetWriter?
    private var writerVideoInput: AVAssetWriterInput?
    private var writerAdoptor: AVAssetWriterInputPixelBufferAdaptor?
    private var currentImage: CGImage?
    private var exportUrl: URL?
    
    #if !os(tvOS)
    private var audioRecHelper: AudioRecHelper?
    #endif
    private var audioStartTime: CMTime?
    private var pausedDate: Date?
    private var pausedDuration: Double = 0.0

    // MARK: - Public Properties
    
    public private(set) var recording: Bool = false
    
    public var fps: Int {
        get { model.fps }
        set { model.fps = newValue }
    }
    public var timeSync: Bool {
        get { model.timeSync }
        set { model.timeSync = newValue }
    }
    public var realtime: Bool {
        get { model.realtime }
        set { model.realtime = newValue }
    }
    public var directMode: Bool {
        get { model.directMode }
        set { model.directMode = newValue }
    }
    
    public enum Quality: Codable {
        case no
        case bad
        case low
        case mid
        case good
        case nice
        case fine
        case epic
        case custom(kbps: Int)
        public static let `default`: Quality = .good
        public var kbps: Int {
            switch self {
            case .no: return 0
            case .bad: return 125
            case .low: return 250
            case .mid: return 500
            case .good: return 1_000
            case .nice: return 2_000
            case .fine: return 4_000
            case .epic: return 8_000
            case .custom(let kbps):
                return kbps
            }
        }
        var bps: Int { kbps * 1_000 * 8 }
        public var title: String {
            switch self {
            case .no: return "No"
            case .bad: return "Bad"
            case .low: return "Low"
            case .mid: return "Mid"
            case .good: return "Good"
            case .nice: return "Nice"
            case .fine: return "Fine"
            case .epic: return "Epic"
            case .custom(let kbps):
                return "\(kbps)kbps"
            }
        }
        public init?(title: String) {
            switch title {
            case "No": self = .no
            case "Bad": self = .bad
            case "Low": self = .low
            case "Mid": self = .mid
            case "Good": self = .good
            case "Nice": self = .nice
            case "Fine": self = .fine
            case "Epic": self = .epic
            default: return nil
            }
        }
    }
    public var quality: Quality {
        get { model.quality }
        set { model.quality = newValue }
    }
    
    #if !os(tvOS)
    
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
    
    #else
    let recordAudio: Bool = false
    #endif
    
    public var lastRecordingUrl: URL?
    
    // MARK: - Property Helpers
    
    var customName: String?
    
    enum RecError: Error {
        case setup(String)
        case render(String)
        case audioSetupFailed
    }
    
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
        realtimeListen()
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
    
    // MARK: - Record
    
    public func startRec(name: String? = nil, didError: ((Error) -> ())? = nil) {
        do {
            try startRec(name: name)
        } catch {
            didError?(error)
        }
    }
    
    public func startRec(name: String? = nil) throws {
        pixelKit.logger.log(.info, nil, "Rec start.")
        customName = name
        try startRecord()
    }
    
    public func pauseRec() {
        pixelKit.logger.log(.info, nil, "Rec pause.")
        pauseRecord()
    }
    
    public func resumeRec() {
        pixelKit.logger.log(.info, nil, "Rec resume.")
        resumeRecord()
    }
    
    public func stopRec(_ exported: @escaping (URL) -> (), didError: ((Error) -> ())? = nil) {
        pixelKit.logger.log(.info, nil, "Rec stop.")
//        guard recording else { return }
        stopRecord(done: { [weak self] in
            guard let url = self?.exportUrl else { return }
            self?.lastRecordingUrl = url
            exported(url)
        }, didError: { error in
            didError?(error)
        })
    }
    
    // MARK: Export
    
    func realtimeListen() {
        pixelKit.render.listenToFrames(callback: { [weak self] in
            self?.frameLoop()
        })
    }
    
    func frameLoop() {
        if !directMode && recording && realtime && connectedIn {
            if lastFrameDate == nil || -lastFrameDate!.timeIntervalSinceNow >= 1.0 / Double(fps) {
                if let texture = input?.texture {
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        self?.recordFrame(texture: texture)
                    }
                }
            }
        }
    }
    
    override public func didRender(renderPack: RenderPack) {
        if !directMode && recording && !realtime {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.recordFrame(texture: renderPack.response.texture)
            }
        }
        super.didRender(renderPack: renderPack)
    }
    
    enum RecordError: Error {
        case noInPix
        case noRes
    }
    
    func startRecord() throws {
        
        guard connectedIn else {
            throw RecordError.noInPix
        }
        guard let res = derivedResolution else {
            throw RecordError.noRes
        }

        try self.setup(resolution: res)
    
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
    
    func setup(resolution: Resolution) throws {
        
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
            pixelKit.logger.log(node: self, .error, nil, "Creating exports folder.", e: error)
            throw RecError.setup("Creating exports folder.")
        }
        
        let name = customName ?? "PixelKit Export \(dateStr)"
        exportUrl = id_url.appendingPathComponent("\(name).mov") // CHECK CLEAN
        
        writer = try AVAssetWriter(outputURL: exportUrl!, fileType: .mov)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: resolution.w,
            AVVideoHeightKey: resolution.h,
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: quality.bps]
        ]
        writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        writerVideoInput!.expectsMediaDataInRealTime = true
        writer!.add(writerVideoInput!)
        
        
        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(pixelKit.render.bits.os),
            kCVPixelBufferWidthKey as String: resolution.w,
            kCVPixelBufferHeightKey as String: resolution.h,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferCGImageCompatibilityKey as String: true
        ]
        
        writerAdoptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerVideoInput!, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        if recordAudio {
            #if !os(tvOS)
            if let input = audioRecHelper?.writerAudioInput {
                writer!.add(input)
                writer!.startWriting()
                audioRecHelper!.captureSession?.startRunning()
                audioRecHelper!.sampleCallback = { [weak self] sampleBuffer in
                    guard let self = self else { return }
                    if self.audioStartTime == nil {
                        self.audioStartTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                        guard self.writer!.status != .unknown else {
                            PixelKit.main.logger.log(.error, nil, "Audio Rec: Writer status is unknown.")
                            return
                        }
                        self.writer!.startSession(atSourceTime: self.audioStartTime!)
                    }
                    let success = input.append(sampleBuffer)
                    if !success {
                        PixelKit.main.logger.log(.error, nil, "Audio Rec: Sample faied to write.")
                    }
                }
            } else {
                throw RecError.audioSetupFailed
            }
            #endif
        } else {
            writer!.startWriting()
            writer!.startSession(atSourceTime: .zero)
        }

        record(at: resolution)
        
    }
    
    func record(at resolution: Resolution) {
        
        let media_queue = DispatchQueue(label: "mediaInputQueue", qos: .background)
                
        writerVideoInput!.requestMediaDataWhenReady(on: media_queue, using: { [weak self] in
            guard let self = self else { return }

            guard self.writer!.status == .writing else { return }
            
            guard self.writerAdoptor!.assetWriterInput.isReadyForMoreMediaData else { return }
            
            guard self.recording && !self.paused else { return }
            
            if self.directMode {
                guard let texture = self.texture else { return }
                self.recordFrame(texture: texture)
            }
            
            if self.currentImage != nil {
                
                guard self.writerVideoInput != nil else {
                    self.pixelKit.logger.log(node: self, .error, nil, "writerVideoInput is nil.")
                    return
                }
                if self.writerVideoInput!.isReadyForMoreMediaData {
                    
                    let time: CMTime
                    if self.timeSync {
                        let duration = -self.startDate!.timeIntervalSinceNow
                        if self.recordAudio {
                            guard let startTime = self.audioStartTime else { return }
                            var offsetDuration = CMTimeGetSeconds(startTime)
                            offsetDuration += duration
                            #if !os(tvOS)
                            offsetDuration += CMTimeGetSeconds(self.audioOffset)
                            #endif
                            offsetDuration -= self.pausedDuration
                            time = CMTime(seconds: offsetDuration, preferredTimescale: Int32(NSEC_PER_SEC))
                        } else {
                            time = CMTime(seconds: duration - self.pausedDuration, preferredTimescale: Int32(NSEC_PER_SEC))
                        }
                    } else {
                        time = CMTime(value: Int64(self.frameIndex), timescale: Int32(self.fps))
                    }
                    
                    self.pixelKit.logger.log(node: self, .detail, nil, "Exporting frame at \(time.seconds).", loop: true)
                    self.appendPixelBufferForImageAtURL(self.writerAdoptor!, presentation_time: time, cg_image: self.currentImage!, at: resolution.size)
                    
                    self.lastFrameDate = Date()
                    self.frameIndex += 1
                    
                } else {
                    self.pixelKit.logger.log(node: self, .error, nil, "isReadyForMoreMediaData is false.")
                }
                
                self.currentImage = nil
                
            }
            
        })
        
    }
    
    func recordFrame(texture: MTLTexture) {
        
        self.pixelKit.logger.log(node: self, .detail, nil, "Record Frame.", loop: true)
        
        if recording && !self.paused && writer != nil && writerVideoInput != nil && writerAdoptor != nil {
            
            let options: [CIImageOption : Any] = [
                CIImageOption.colorSpace: pixelKit.render.colorSpace
            ]
            let ci_image = CIImage(mtlTexture: texture, options: options)
            if ci_image != nil {
                #if (os(iOS) && !targetEnvironment(macCatalyst)) || os(tvOS)
                // FIXME: Debug
                EAGLContext.setCurrent(nil)
                #endif
                let context = CIContext.init(options: nil)
                let cg_image = context.createCGImage(ci_image!, from: ci_image!.extent, format: Bits._8.ci, colorSpace: pixelKit.render.colorSpace)
                if cg_image != nil {
                    
                    currentImage = cg_image!
                
                } else {
                    self.pixelKit.logger.log(node: self, .error, nil, "cg_image is nil.")
                }
            } else {
                self.pixelKit.logger.log(node: self, .error, nil, "ci_image is nil.")
            }
            
        } else {
            self.pixelKit.logger.log(node: self, .error, nil, "Some writer is nil.")
        }
        
    }
    
    func stopRecord(done: @escaping () -> (), didError: @escaping (Error) -> ()) {
        
        #if !os(tvOS)
        audioRecHelper?.captureSession?.stopRunning()
        #endif

        if let writer = writer, let writerVideoInput = writerVideoInput {
            if writer.status == .writing {
                writerVideoInput.markAsFinished()
                #if !os(tvOS)
                audioRecHelper?.writerAudioInput?.markAsFinished()
                #endif
                writer.finishWriting {
                    if writer.status == .completed {
                        DispatchQueue.main.async {
                            done()
                        }
                    } else if writer.error == nil {
                        self.pixelKit.logger.log(node: self, .error, nil, "Rec Stop E. Cancelled. Writer Status: \(writer.status).")
                        DispatchQueue.main.async {
                            didError(RecError.render("Rec Stop E. Cancelled."))
                        }
                    } else {
                        self.pixelKit.logger.log(node: self, .error, nil, "Rec Stop D. Writer Error. Writer Status: \(writer.status).", e: writer.error)
                        DispatchQueue.main.async {
                            didError(RecError.render("Rec Stop D. Writer Error."))
                        }
                    }
                    self.writerVideoInput = nil
                    self.writer = nil
                }
            } else {
                self.pixelKit.logger.log(node: self, .error, nil, "Rec Stop B. Writer has bad satus: \(writer.status.rawValue)")
                didError(RecError.render("Rec Stop B. Writer has bad satus: \(writer.status.rawValue)"))
                self.writerVideoInput = nil
                self.writer = nil
            }
        } else {
            self.pixelKit.logger.log(node: self, .error, nil, "Rec Stop A. Writer or Input not found.")
            didError(RecError.render("Rec Stop A. Writer or Input not found."))
            self.writerVideoInput = nil
            self.writer = nil
        }
        
//        writer.cancelWriting()
        
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
    
    func appendPixelBufferForImageAtURL(_ pixel_buffer_adoptor: AVAssetWriterInputPixelBufferAdaptor, presentation_time: CMTime, cg_image: CGImage, at size: CGSize) {
        guard writer?.status == .some(.writing) else {
            self.pixelKit.logger.log(node: self, .error, nil, "Export frame Canceled, Bad writer status: \(String(describing: writer?.status.rawValue)).", e: writer?.error)
            return
        }
        guard let pixelBuffer = Texture.buffer(from: cg_image, at: size, swizzle: true) else {
            self.pixelKit.logger.log(node: self, .error, nil, "Export frame Canceled, Texture not Found.")
            return
        }
        if !pixel_buffer_adoptor.append(pixelBuffer, withPresentationTime: presentation_time) {
            guard let writer = self.writer else { return }
            self.pixelKit.logger.log(node: self, .error, nil, "Exported frame failed, writer status: \(writer.status.rawValue).", e: writer.error)
        }
    }
    
}

#if !os(tvOS)
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
        
        if let microphone = AVCaptureDevice.default(for: .audio) {
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
                PixelKit.main.logger.log(.error, nil, "Audio Rec Helper setup failed. Mic failed.", e: error)
            }
        } else {
            PixelKit.main.logger.log(.error, nil, "Audio Rec Helper setup failed. No mic found.")
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return }
        guard let input = writerAudioInput else { return }
        guard input.isReadyForMoreMediaData else { return }
        sampleCallback?(sampleBuffer)
    }
    
}
#endif
