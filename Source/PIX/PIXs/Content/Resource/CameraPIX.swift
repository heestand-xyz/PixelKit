//
//  CameraPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import AVKit

#if os(iOS)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS)
typealias _Orientation = Void
#endif

public protocol CameraPIXDelegate {
    func cameraSetup(pix: CameraPIX)
    func cameraFrame(pix: CameraPIX, pixelBuffer: CVPixelBuffer)
}

public class CameraPIX: PIXResource {
        
    override open var shader: String { return "contentResourceCameraPIX" }
    
    public var cameraDelegate: CameraPIXDelegate?
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: _Orientation?
    
    // MARK: - Public Properties
    
    public enum CamRes: String, Codable, CaseIterable {
        case vga = "VGA"
        case _720p = "720p"
        #if os(iOS)
        case _1080p = "1080p"
        case _4K = "4K"
        #endif
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
            case .vga:
                return .vga640x480
            case ._720p:
                return .hd1280x720
            #if os(iOS)
            case ._1080p:
                return .hd1920x1080
            case ._4K:
                return .hd4K3840x2160
            #endif
            }
        }
        public var res: Res {
            switch self {
            case .vga: return .custom(w: 640, h: 480)
            case ._720p: return ._720p
            #if os(iOS)
            case ._1080p: return ._1080p
            case ._4K: return ._4K
            #endif
            }
        }
    }
    #if os(iOS)
    public var camRes: CamRes = ._1080p { didSet { setupCamera() } }
    #elseif os(macOS)
    public var camRes: CamRes = ._720p { didSet { setupCamera() } }
    #endif
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        #if os(iOS)
        case back = "Wide Camera"
        case tele = "Tele Camera"
        #elseif os(macOS)
        case external = "External Camera"
        #endif
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            #if os(iOS)
            case .back, .tele:
                return .back
            #elseif os(macOS)
            case .external:
                return .back
            #endif
            }
        }
        var mirrored: Bool {
            return self == .front
        }
        var flipFlop: Bool {
            #if os(iOS)
            return false
            #elseif os(macOS)
            return false
            #endif
        }
        var isTele: Bool {
            #if os(iOS)
            return self == .tele
            #elseif os(macOS)
            return false
            #endif
        }
    }
    #if os(iOS)
    public var camera: Camera = .back { didSet { setupCamera() } }
    #elseif os(macOS)
    public var camera: Camera = .front { didSet { setupCamera() } }
    #endif
    
    #if os(macOS)
    public var autoDetect: Bool = true
    #endif
    
    #if os(iOS)
    /*public*/ var depth: Bool = false { didSet { setupCamera() } }
    #endif
    
    #if os(iOS)
    
    public var manualExposure: Bool = false {
        didSet {
            helper?.manualExposure(manualExposure)
            if manualExposure {
                helper?.setLight(exposure, iso)
//                helper?.setTorch(torch)
            }
        }
    }
    public var exposure: CGFloat = 0.05 {
        didSet {
            guard manualExposure else { return }
            helper?.setLight(exposure, iso)
        }
    }
    public var iso: CGFloat = 300 {
        didSet {
            guard manualExposure else { return }
            helper?.setLight(exposure, iso)
        }
    }
//    public var torch: CGFloat = 0.0 {
//        didSet {
//            guard manualExposure else { return }
//            helper?.setTorch(torch)
//        }
//    }
    
    public var manualFocus: Bool = false {
        didSet {
            helper?.manualFocus(manualFocus)
            if manualFocus {
                helper?.setFocus(focus)
            }
        }
    }
    public var focus: CGFloat = 1.0 {
        didSet {
            guard manualFocus else { return }
            helper?.setFocus(focus)
        }
    }
    public var focusPoint: CGPoint {
        return helper?.getFocusPoint() ?? .zero
    }
    
    public var manualWhiteBalance: Bool = false {
        didSet {
            helper?.manualWhiteBalance(manualWhiteBalance)
            if manualWhiteBalance {
                helper?.setWhiteBalance(LiveColor(whiteBalance))
            }
        }
    }
    public var whiteBalance: UIColor {
        get {
            return helper?.getWhiteBalance().uiColor ?? .white
        }
        set {
            guard manualWhiteBalance else { return }
            helper?.setWhiteBalance(LiveColor(whiteBalance))
        }
    }

    public var minExposure: CGFloat {
        return helper?.minExposure ?? 0.0
    }
    public var maxExposure: CGFloat {
        return helper?.maxExposure ?? 0.0
    }
    
    public var minISO: CGFloat {
        return helper?.minISO ?? 0.0
    }
    public var maxISO: CGFloat {
        return helper?.maxISO ?? 0.0
    }
    
    #endif

    // MARK: - Property Helpers
    
    open override var uniforms: [CGFloat] {
        #if os(iOS)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #elseif os(macOS)
        return [4, camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        setupCamera()
        
        #if os(macOS)
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: nil) { (notif) -> Void in
            self.camAttatched(device: notif.object! as! AVCaptureDevice)
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { (notif) -> Void in
            self.camDeattatched(device: notif.object! as! AVCaptureDevice)
        }
        #endif
        
//        #if os(iOS)
//        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceSubjectAreaDidChange, object: nil, queue: nil) { (notif) -> Void in }
//        #endif
        
    }
    
    deinit {
        helper!.stop()
    }
    
    // MARK: Access
    
    func requestAccess(gotAccess: @escaping () -> ()) {
        if #available(OSX 10.14, *) {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                if accessGranted {
                    gotAccess()
                } else {
                    self.pixelKit.log(pix: self, .warning, .resource, "Camera Access Not Granted.")
                }
                self.access = accessGranted
            }
        } else {
            gotAccess()
            self.access = true
        }
    }
    
    // MARK: Setup
    
    func setupCamera() {
        if !access {
            requestAccess {
                DispatchQueue.main.async {
                    self.setupCamera()
                }
                return
            }
        }
        helper?.stop()
        #if os(iOS)
        let extCam = false
        #elseif os(macOS)
        let extCam = camera == .external
        #endif
        #if os(iOS)
        let depth = self.depth
        #elseif os(macOS)
        let depth = false
        #endif
        helper = CameraHelper(camRes: camRes, cameraPosition: camera.position, tele: camera.isTele, depth: depth, useExternalCamera: extCam, setup: { _, orientation in
            self.pixelKit.log(pix: self, .info, .resource, "Camera setup.")
            // CHECK multiple setups on init
            self.orientation = orientation
            #if os(iOS)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #endif
            self.cameraDelegate?.cameraSetup(pix: self)
        }, captured: { pixelBuffer in
            self.pixelKit.log(pix: self, .info, .resource, "Camera frame captured.", loop: true)
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
            self.cameraDelegate?.cameraFrame(pix: self, pixelBuffer: pixelBuffer)
        })
    }
    
    // MARK: - Camera Attatchment
    
    #if os(macOS)
    
    func camAttatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixelKit.log(pix: self, .info, .resource, "Camera Attatched.")
        setupCamera()
    }
    
    func camDeattatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixelKit.log(pix: self, .info, .resource, "Camera Deattatched.")
        setupCamera()
    }
    
    #endif
    
}

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate/*, AVCaptureDepthDataOutputDelegate, AVCapturePhotoCaptureDelegate*/ {

    let pixelKit = PixelKit.main
    
    var device: AVCaptureDevice?
    
    let cameraPosition: AVCaptureDevice.Position
//    let photoSupport: Bool
    
    let captureSession: AVCaptureSession
    var videoOutput: AVCaptureVideoDataOutput?
    
//    #if os(iOS)
//    var depthOutput: AVCaptureDepthDataOutput?
////    var depthConnection: AVCaptureConnection!
////    var depthSynchronizer: AVCaptureDataOutputSynchronizer!
//    #endif
    
//    let photoOutput: AVCapturePhotoOutput?
    

    var lastUIOrientation: _Orientation

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, _Orientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(camRes: CameraPIX.CamRes, cameraPosition: AVCaptureDevice.Position, tele: Bool = false, depth: Bool = false, useExternalCamera: Bool = false, /*photoSupport: Bool = false, */setup: @escaping (CGSize, _Orientation) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
        #if os(iOS)
        device = AVCaptureDevice.default(tele ? .builtInTelephotoCamera : .builtInWideAngleCamera, for: .video, position: cameraPosition)
        if device == nil {
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
        }
        #elseif os(macOS)
        if !useExternalCamera {
            device = AVCaptureDevice.default(for: .video)
        } else {
            var firstFound = false
            var secondFound = false
            for iDevice in AVCaptureDevice.devices() {
                if iDevice.hasMediaType(.video) {
                    if firstFound {
                        device = iDevice
                        secondFound = true
                        break
                    }
                    firstFound = true
                }
            }
            if !secondFound {
                device = AVCaptureDevice.default(for: .video)
            }
        }
        #endif
        
        self.cameraPosition = cameraPosition
//        self.photoSupport = photoSupport
        
        setupCallback = setup
        capturedCallback = captured
        
        #if os(iOS)
        lastUIOrientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS)
        lastUIOrientation = ()
        #endif
        
        captureSession = AVCaptureSession()

//        #if os(iOS)
//        if depth {
//            depthOutput = AVCaptureDepthDataOutput()
//        } else {
        videoOutput = AVCaptureVideoDataOutput()
//        }
//        #endif
        
//        photoOutput = photoSupport ? AVCapturePhotoOutput() : nil
        
        
        super.init()
        
        
        guard device != nil else {
            pixelKit.log(.error, nil, "Camera device not found.")
            return
        }
        
        if depth {
            
//            #if os(iOS)
//            depthOutput!.isFilteringEnabled = false
////            depthConnection = depthOutput!.connection(with: .depthData)
////            guard depthConnection != nil else {
////                pixelKit.log(.error, nil, "Camera depth connection failed.")
////                return
////            }
////            depthConnection!.isEnabled = true
//
////            let depthFormats = device!.activeFormat.supportedDepthDataFormats
////            let filtered = depthFormats.filter({
////                CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat16
////            })
////            let selectedFormat = filtered.max(by: {
////                first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
////            })
////
////            do {
////                try device!.lockForConfiguration()
////                device!.activeDepthDataFormat = selectedFormat
////                device!.unlockForConfiguration()
////            } catch {
////                pixelKit.log(.error, nil, "Could not lock device for depth configuration.", e: error)
////                return
////            }
//
////            let depthQueue = DispatchQueue(label: "se.hexagons.pixelKit.pix.camera.depth.queue")
////
////            depthSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [depthOutput!])
////            depthSynchronizer.setDelegate(self, queue: depthQueue)
//            #endif
    
        } else {
            
            let preset: AVCaptureSession.Preset = camRes.sessionPreset
            if captureSession.canSetSessionPreset(preset) {
                captureSession.sessionPreset = preset
            } else {
                captureSession.sessionPreset = .high
            }
            
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixelKit.bits.os]
            
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                var output: AVCaptureOutput!
                if depth {
//                    #if os(iOS)
//                    output = depthOutput!
//                    #endif
                } else {
                    output = videoOutput!
                }
                if captureSession.canAddOutput(output){
                    captureSession.addOutput(output)
                    let queue = DispatchQueue(label: "se.hexagons.pixelKit.pix.camera.queue")
                    if depth {
//                        #if os(iOS)
//                        depthOutput!.setDelegate(self, callbackQueue: queue)
//                        #endif
                    } else {
                        videoOutput!.setSampleBufferDelegate(self, queue: queue)
                    }
                    start()
                } else {
                    pixelKit.log(.error, .resource, "Camera can't add output.")
                }
            } else {
                pixelKit.log(.error, .resource, "Camera can't add input.")
            }
        } catch {
            pixelKit.log(.error, .resource, "Camera input failed to load.", e: error)
        }
    
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
        
    }
    
    #if os(iOS)
    @objc func deviceRotated() {
        if lastUIOrientation != UIApplication.shared.statusBarOrientation {
            orientationUpdated = true
        } else {
            forceDetectUIOrientation(new: {
                self.orientationUpdated = true
            })
        }
    }
    #endif
    
    #if os(iOS)
    func forceDetectUIOrientation(new: @escaping () -> ()) {
        let forceCount = pixelKit.fpsMax * 2
        var forceIndex = 0
        let forceTimer = Timer(timeInterval: 1 / Double(pixelKit.fpsMax), repeats: true, block: { timer in
            if self.lastUIOrientation != UIApplication.shared.statusBarOrientation {
                new()
                timer.invalidate()
            } else {
                forceIndex += 1
                if forceIndex >= forceCount {
                    timer.invalidate()
                }
            }
        })
        RunLoop.current.add(forceTimer, forMode: .common)
    }
    #endif
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            pixelKit.log(.error, .resource, "Camera buffer conversion failed.")
            return
        }
        
        DispatchQueue.main.async {
            
            if !self.initialFrameCaptured {
                self.setup(pixelBuffer)
                self.initialFrameCaptured = true
            } else if self.orientationUpdated {
                self.setup(pixelBuffer)
                self.orientationUpdated = false
            }
            
            self.capturedCallback(pixelBuffer)
            
        }
        
    }
    
//    #if os(iOS)
//    func depthDataOutput(_ output: AVCaptureDepthDataOutput,
//                         didOutput depthData: AVDepthData,
//                         timestamp: CMTime,
//                         connection: AVCaptureConnection) {
//        
//        var convertedDepth: AVDepthData
//        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
//            convertedDepth = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
//        } else {
//            convertedDepth = depthData
//        }
//        print("DEPTH")
//        let pixelBuffer = convertedDepth.depthDataMap
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.capturedCallback(pixelBuffer)
//        }
//        
//    }
//    #endif
    
    func setup(_ pixelBuffer: CVPixelBuffer) {
        
        #if os(iOS)
        let _orientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS)
        let _orientation: Void = ()
        #endif
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution: CGSize
        #if os(iOS)
        switch _orientation {
        case .portrait, .portraitUpsideDown:
            resolution = CGSize(width: height, height: width)
        case .landscapeLeft, .landscapeRight:
            resolution = CGSize(width: width, height: height)
        default:
            resolution = CGSize(width: width, height: height)
            pixelKit.log(.warning, .resource, "Camera orientation unknown.")
        }
        #elseif os(macOS)
        resolution = CGSize(width: width, height: height)
        #endif
        
        setupCallback(resolution, _orientation)
        
        lastUIOrientation = _orientation
        
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    // MARK: Manual
    
    #if os(iOS)
    
    func manualExposure(_ active: Bool) {
        do {
            try device?.lockForConfiguration()
            device?.exposureMode = active ? .custom : .continuousAutoExposure
        } catch {
            pixelKit.log(.error, .resource, "Camera custom setting (exposureMode) failed.", e: error)
        }
    }
    
    func manualFocus(_ active: Bool) {
        guard device!.isFocusModeSupported(.locked) else { return }
        do {
            try device?.lockForConfiguration()
            device?.focusMode = active ? .locked : .continuousAutoFocus
        } catch {
            pixelKit.log(.error, .resource, "Camera custom setting (focusMode) failed.", e: error)
        }
    }
    
    func manualWhiteBalance(_ active: Bool) {
        do {
            try device?.lockForConfiguration()
            device?.whiteBalanceMode = active ? .locked : .continuousAutoWhiteBalance
        } catch {
            pixelKit.log(.error, .resource, "Camera custom setting (whiteBalanceMode) failed.", e: error)
        }
    }
    
    var minExposure: CGFloat {
        return CGFloat(device!.activeFormat.minExposureDuration.seconds)
    }
    var maxExposure: CGFloat {
        return CGFloat(device!.activeFormat.maxExposureDuration.seconds)
    }
    
    var minISO: CGFloat {
        return CGFloat(device!.activeFormat.minISO)
    }
    var maxISO: CGFloat {
        return CGFloat(device!.activeFormat.maxISO)
    }
    
    func setLight(_ exposure: CGFloat, _ iso: CGFloat) {
        let clampedExposure = min(max(exposure, minExposure), maxExposure)
        let clampedIso = min(max(iso, minISO), maxISO)
        device!.setExposureModeCustom(duration: CMTime(seconds: Double(clampedExposure), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), iso: Float(clampedIso))
    }
//    func setTorch(_ value: CGFloat) {
//        try? device!.setTorchModeOn(level: Float(max(value, 0.001)))
//    }
    
    func setFocus(_ value: CGFloat) {
        guard device!.isFocusModeSupported(.locked) else { return }
        device!.setFocusModeLocked(lensPosition: Float(value))
    }
    
    func setWhiteBalance(_ color: LiveColor) {
        let range = device!.maxWhiteBalanceGain - 1.0
        device!.setWhiteBalanceModeLocked(with: AVCaptureDevice.WhiteBalanceGains(redGain: 1.0 + Float(color.r.cg) * range, greenGain: 1.0 + Float(color.g.cg) * range, blueGain: 1.0 + Float(color.b.cg) * range))
    }
    
    func getExposure() -> CGFloat {
        return CGFloat(device!.exposureDuration.seconds)
    }
    
    func getISO() -> CGFloat {
        return CGFloat(device!.iso)
    }
    
    func getFocusPoint() -> CGPoint {
        return device!.focusPointOfInterest
    }

    func getWhiteBalance() -> LiveColor {
        let range = device!.maxWhiteBalanceGain - 1.0
        return LiveColor(r: LiveFloat((device!.deviceWhiteBalanceGains.redGain - 1.0) / range),
                          g: LiveFloat((device!.deviceWhiteBalanceGains.greenGain - 1.0) / range),
                          b: LiveFloat((device!.deviceWhiteBalanceGains.blueGain - 1.0) / range))
    }
    
    #endif
    
//    // MARK: Photo
//
//    func capture() {
//        guard photoSupport else {
//            pixelKit.log(.warning, .resource, "Photo Capture not enabled.")
//            return
//        }
//        guard let availableRawFormat = photoOutput!.availableRawPhotoPixelFormatTypes.first else { return }
//        let photoSettings = AVCapturePhotoSettings(rawPixelFormatType: availableRawFormat,
//                                                   processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc])
//        photoSettings.isAutoStillImageStabilizationEnabled = false // RAW is incompatible with image stabilization.
//        photoOutput!.capturePhoto(with: photoSettings, delegate: self)
//    }
//
//    var rawImageFileURL: URL?
////    var compressedFileData: Data?
//
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//
//        if photo.isRawPhoto {
//            // Save the RAW (DNG) file data to a URL.
//            let dngFileURL = self.makeUniqueTempFileURL(extension: "dng")
//            do {
//                try photo.fileDataRepresentation()!.write(to: dngFileURL)
//                // ...
//            } catch {
//                fatalError("couldn't write DNG file to URL")
//            }
//        } else {
////            self.compressedFileData = photo.fileDataRepresentation()!
//        }
//
//    }
//
//    func makeUniqueTempFileURL(extension type: String) -> URL {
//        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
//        let uniqueFilename = ProcessInfo.processInfo.globallyUniqueString
//        let urlNoExt = temporaryDirectoryURL.appendingPathComponent(uniqueFilename)
//        let url = urlNoExt.appendingPathExtension(type)
//        return url
//    }

}

