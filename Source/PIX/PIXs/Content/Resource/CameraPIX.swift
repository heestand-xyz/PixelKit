//
//  CameraPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import AVKit
#if os(iOS) && !targetEnvironment(macCatalyst)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS) || targetEnvironment(macCatalyst)
typealias _Orientation = Void
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

public protocol CameraPIXDelegate {
    func cameraSetup(pix: CameraPIX)
    func cameraFrame(pix: CameraPIX, pixelBuffer: CVPixelBuffer)
}

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CameraPIXUI: View, PIXUI {
    public var node: NODE { pix }
    public let pix: PIX
    let cameraPix: CameraPIX
    public var body: some View {
        NODERepView(node: pix)
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public init(camera: CameraPIX.Camera = .back, camRes: CameraPIX.CamRes = ._1080p) {
        cameraPix = CameraPIX()
        cameraPix.camera = camera
        cameraPix.camRes = camRes
        pix = cameraPix
    }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public init(camera: CameraPIX.Camera = .front, camRes: CameraPIX.CamRes = ._720p) {
        cameraPix = CameraPIX()
        cameraPix.camera = camera
        cameraPix.camRes = camRes
        pix = cameraPix
    }
    #endif
    public func camRes(_ camRes: CameraPIX.CamRes) -> CameraPIXUI {
        cameraPix.camRes = camRes
        return self
    }
    public func camera(_ camera: CameraPIX.Camera) -> CameraPIXUI {
        cameraPix.camera = camera
        return self
    }
}
#endif

public class CameraPIX: PIXResource {
        
    override open var shaderName: String { return "contentResourceCameraPIX" }
    
    public var cameraDelegate: CameraPIXDelegate?
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: _Orientation?
    
    public override var bypass: Bool {
        didSet {
            super.bypass = bypass
            helper?.bypass = bypass
        }
    }
    
    // MARK: - Public Properties
    
    public enum CamRes: String, Codable, CaseIterable {
        case vga = "VGA"
        case sd = "SD"
        case _720p = "720p"
        #if os(iOS) && !targetEnvironment(macCatalyst)
        case _1080p = "1080p"
//        case _4K = "4K"
        #endif
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
            case .vga:
                return .vga640x480
            case .sd:
                return .iFrame960x540
            case ._720p:
                return .hd1280x720
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case ._1080p:
                return .hd1920x1080
//            case ._4K:
//                return .hd4K3840x2160
            #endif
            }
        }
        public var resolution: Resolution {
            switch self {
            case .vga: return .custom(w: 640, h: 480)
            case .sd: return .custom(w: 960, h: 540)
            case ._720p: return ._720p
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case ._1080p: return ._1080p
//            case ._4K: return ._4K
            #endif
            }
        }
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var camRes: CamRes = ._1080p { didSet { setupCamera() } }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public var camRes: CamRes = ._720p { didSet { setupCamera() } }
    #endif
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        #if os(iOS) && !targetEnvironment(macCatalyst)
        case back = "Wide Camera"
        case tele = "Tele Camera"
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        case external = "External Camera"
        #endif
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case .back, .tele:
                return .back
            #elseif os(macOS) || targetEnvironment(macCatalyst)
            case .external:
                return .back
            #endif
            }
        }
        var mirrored: Bool {
            return self == .front
        }
        var flipFlop: Bool {
            #if os(iOS) && !targetEnvironment(macCatalyst)
            return false
            #elseif os(macOS) || targetEnvironment(macCatalyst)
            return false
            #endif
        }
        var isTele: Bool {
            #if os(iOS) && !targetEnvironment(macCatalyst)
            return self == .tele
            #elseif os(macOS) || targetEnvironment(macCatalyst)
            return false
            #endif
        }
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var camera: Camera = .back { didSet { setupCamera() } }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public var camera: Camera = .front { didSet { setupCamera() } }
    #endif
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    public var autoDetect: Bool = true
    #endif
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var depth: Bool = false { didSet { setupCamera() } }
    public var filterDepth: Bool = false { didSet { setupCamera() } }
    var depthCallback: ((CVPixelBuffer) -> ())?
    #endif
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    
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
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        return [4, camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        
        super.init()
        
        name = "camera"
        
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
                    self.pixelKit.logger.log(node: self, .warning, .resource, "Camera Access Not Granted.")
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
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let extCam = false
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let extCam = camera == .external
        #endif
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let depth = self.depth
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let depth = false
        #endif
        helper = CameraHelper(camRes: camRes, cameraPosition: camera.position, tele: camera.isTele, depth: depth, filterDepth: filterDepth, useExternalCamera: extCam, setup: { _, orientation in
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera setup.")
            // CHECK multiple setups on init
            self.orientation = orientation
            #if os(iOS) && !targetEnvironment(macCatalyst)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #endif
            self.cameraDelegate?.cameraSetup(pix: self)
        }, captured: { pixelBuffer in
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera frame captured.", loop: true)
            self.pixelBuffer = pixelBuffer
            if self.view.resolution == nil || self.view.resolution! != self.renderResolution {
                self.applyResolution { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
            self.cameraDelegate?.cameraFrame(pix: self, pixelBuffer: pixelBuffer)
        }, capturedDepth: { depthPixelBuffer in
            self.depthCallback?(depthPixelBuffer)
        })
    }
    
    // MARK: - Camera Attatchment
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    
    func camAttatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixelKit.logger.log(node: self, .info, .resource, "Camera Attatched.")
        setupCamera()
    }
    
    func camDeattatched(device: AVCaptureDevice) {
        guard autoDetect else { return }
        self.pixelKit.logger.log(node: self, .info, .resource, "Camera Deattatched.")
        setupCamera()
    }
    
    #endif
    
}

// MARK: - Camera Helper

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate/*, AVCapturePhotoCaptureDelegate*/ {

    let pixelKit = PixelKit.main
    
    var device: AVCaptureDevice?
    
    let cameraPosition: AVCaptureDevice.Position
//    let photoSupport: Bool
    
    let captureSession: AVCaptureSession
    var videoOutput: AVCaptureVideoDataOutput?
    
    #if os(iOS)
    let depth: Bool
    var depthOutput: AVCaptureDepthDataOutput?
//    var depthConnection: AVCaptureConnection!
    var depthSynchronizer: AVCaptureDataOutputSynchronizer!
    var depthProcessing: Bool = false
    #endif
    
//    let photoOutput: AVCapturePhotoOutput?
    
    var bypass: Bool = false {
        didSet {
            if bypass {
                stop()
            } else {
                start()
            }
        }
    }

    var lastUIOrientation: _Orientation

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, _Orientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    let capturedDepthCallback: (CVPixelBuffer) -> ()
    
    init(camRes: CameraPIX.CamRes, cameraPosition: AVCaptureDevice.Position, tele: Bool = false, depth: Bool = false, filterDepth: Bool, useExternalCamera: Bool = false, /*photoSupport: Bool = false, */setup: @escaping (CGSize, _Orientation) -> (), captured: @escaping (CVPixelBuffer) -> (), capturedDepth: @escaping (CVPixelBuffer) -> ()) {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let deviceType: AVCaptureDevice.DeviceType
        if depth {
            if cameraPosition == .front {
                if #available(iOS 11.1, *) {
                    deviceType = .builtInTrueDepthCamera
                } else {
                    deviceType = .builtInWideAngleCamera
                }
            } else {
                deviceType = .builtInDualCamera
            }
        } else {
            if tele {
                deviceType = .builtInWideAngleCamera
            } else {
                deviceType = .builtInWideAngleCamera
            }
        }
        device = AVCaptureDevice.default(deviceType, for: .video, position: cameraPosition)
        if device == nil {
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
        }
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        if !useExternalCamera {
            print(":::::::::::::", AVCaptureDevice.devices())
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
        
        #if os(iOS)
        self.depth = depth
        #endif
        
        self.cameraPosition = cameraPosition
//        self.photoSupport = photoSupport
        
        setupCallback = setup
        capturedCallback = captured
        capturedDepthCallback = capturedDepth
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        lastUIOrientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        lastUIOrientation = ()
        #endif
        
        captureSession = AVCaptureSession()

        videoOutput = AVCaptureVideoDataOutput()
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if depth {
            depthOutput = AVCaptureDepthDataOutput()
        }
        #endif
        
//        photoOutput = photoSupport ? AVCapturePhotoOutput() : nil
        
        
        super.init()
        
        
        guard device != nil else {
            pixelKit.logger.log(.error, nil, "Camera device not found.")
            return
        }
        
        let preset: AVCaptureSession.Preset = depth ? .vga640x480 : camRes.sessionPreset
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        } else {
            captureSession.sessionPreset = .high
        }
        
        videoOutput!.alwaysDiscardsLateVideoFrames = true
        videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixelKit.render.bits.os]

        #if os(iOS) && !targetEnvironment(macCatalyst)
        if depth {
            depthOutput!.isFilteringEnabled = filterDepth
        }
        #endif
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                if captureSession.canAddOutput(videoOutput!){
                    captureSession.addOutput(videoOutput!)
                    #if os(iOS) && !targetEnvironment(macCatalyst)
                    if depth {
                        if captureSession.canAddOutput(depthOutput!){
                            captureSession.addOutput(depthOutput!)
                        } else {
                            pixelKit.logger.log(.error, .resource, "Camera can't add depth output.")
                            return
                        }
                    }
                    #endif
                    let queue = DispatchQueue(label: "se.hexagons.pixelkit.pix.camera.queue")
                    if depth {
                        #if os(iOS) && !targetEnvironment(macCatalyst)
                        depthSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoOutput!, depthOutput!])
                        depthOutput!.setDelegate(self, callbackQueue: queue)
                        depthSynchronizer!.setDelegate(self, queue: queue)
                        #endif
                    } else {
                        videoOutput!.setSampleBufferDelegate(self, queue: queue)
                    }
                    start()
                } else {
                    pixelKit.logger.log(.error, .resource, "Camera can't add output.")
                }
            } else {
                pixelKit.logger.log(.error, .resource, "Camera can't add input.")
            }
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera input failed to load.", e: error)
        }
        
    
        #if os(iOS) && !targetEnvironment(macCatalyst)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
        
    }
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
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
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    func forceDetectUIOrientation(new: @escaping () -> ()) {
        let forceCount = pixelKit.render.fpsMax * 2
        var forceIndex = 0
        let forceTimer = Timer(timeInterval: 1 / Double(pixelKit.render.fpsMax), repeats: true, block: { timer in
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
        
        guard !bypass else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            pixelKit.logger.log(.error, .resource, "Camera buffer conversion failed.")
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
    
    func setup(_ pixelBuffer: CVPixelBuffer) {
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let _orientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let _orientation: Void = ()
        #endif
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution: CGSize
        #if os(iOS) && !targetEnvironment(macCatalyst)
        switch _orientation {
        case .portrait, .portraitUpsideDown:
            resolution = CGSize(width: height, height: width)
        case .landscapeLeft, .landscapeRight:
            resolution = CGSize(width: width, height: height)
        default:
            resolution = CGSize(width: width, height: height)
            pixelKit.logger.log(.warning, .resource, "Camera orientation unknown.")
        }
        #elseif os(macOS) || targetEnvironment(macCatalyst)
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
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    
    func manualExposure(_ active: Bool) {
        do {
            try device?.lockForConfiguration()
            device?.exposureMode = active ? .custom : .continuousAutoExposure
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (exposureMode) failed.", e: error)
        }
    }
    
    func manualFocus(_ active: Bool) {
        guard device!.isFocusModeSupported(.locked) else { return }
        do {
            try device?.lockForConfiguration()
            device?.focusMode = active ? .locked : .continuousAutoFocus
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (focusMode) failed.", e: error)
        }
    }
    
    func manualWhiteBalance(_ active: Bool) {
        do {
            try device?.lockForConfiguration()
            device?.whiteBalanceMode = active ? .locked : .continuousAutoWhiteBalance
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (whiteBalanceMode) failed.", e: error)
        }
    }
    
    var minExposure: CGFloat {
        guard let device = device else { return 0.0 }
        return CGFloat(device.activeFormat.minExposureDuration.seconds)
    }
    var maxExposure: CGFloat {
        guard let device = device else { return 1.0 }
        return CGFloat(device.activeFormat.maxExposureDuration.seconds)
    }
    
    var minISO: CGFloat {
        guard let device = device else { return 0.0 }
        return CGFloat(device.activeFormat.minISO)
    }
    var maxISO: CGFloat {
        guard let device = device else { return 1.0 }
        return CGFloat(device.activeFormat.maxISO)
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
        guard let device = device else { return }
        guard device.isFocusModeSupported(.locked) else { return }
        device.setFocusModeLocked(lensPosition: Float(value))
    }
    
    func setWhiteBalance(_ color: LiveColor) {
        guard let device = device else { return }
        let range = device.maxWhiteBalanceGain - 1.0
        device.setWhiteBalanceModeLocked(with: AVCaptureDevice.WhiteBalanceGains(redGain: 1.0 + Float(color.r.cg) * range, greenGain: 1.0 + Float(color.g.cg) * range, blueGain: 1.0 + Float(color.b.cg) * range))
    }
    
    func getExposure() -> CGFloat {
        guard let device = device else { return 0.0 }
        return CGFloat(device.exposureDuration.seconds)
    }
    
    func getISO() -> CGFloat {
        guard let device = device else { return 0.0 }
        return CGFloat(device.iso)
    }
    
    func getFocusPoint() -> CGPoint {
        guard let device = device else { return .zero }
        return device.focusPointOfInterest
    }

    func getWhiteBalance() -> LiveColor {
        guard let device = device else { return .clear }
        let range = device.maxWhiteBalanceGain - 1.0
        return LiveColor(r: LiveFloat((device.deviceWhiteBalanceGains.redGain - 1.0) / range),
                         g: LiveFloat((device.deviceWhiteBalanceGains.greenGain - 1.0) / range),
                         b: LiveFloat((device.deviceWhiteBalanceGains.blueGain - 1.0) / range))
    }
    
    #endif
    
//    // MARK: Photo
//
//    func capture() {
//        guard photoSupport else {
//            pixelKit.logger.log(.warning, .resource, "Photo Capture not enabled.")
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


extension CVPixelBuffer {
  
  func normalize() {
    
    let width = CVPixelBufferGetWidth(self)
    let height = CVPixelBufferGetHeight(self)
    
    CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
    let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
    
    var minPixel: Float = 1.0
    var maxPixel: Float = 0.0
    
    for y in 0 ..< height {
      for x in 0 ..< width {
        let pixel = floatBuffer[y * width + x]
        minPixel = min(pixel, minPixel)
        maxPixel = max(pixel, maxPixel)
      }
    }
    
    let range = maxPixel - minPixel
    
    for y in 0 ..< height {
      for x in 0 ..< width {
        let pixel = floatBuffer[y * width + x]
        floatBuffer[y * width + x] = (pixel - minPixel) / range
      }
    }
    
    CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
  }
  
}

// MARK: - Depth

#if os(iOS) && !targetEnvironment(macCatalyst)
extension CameraHelper: AVCaptureDepthDataOutputDelegate, AVCaptureDataOutputSynchronizerDelegate {

    func depthDataOutput(_ output: AVCaptureDepthDataOutput,
                         didOutput depthData: AVDepthData,
                         timestamp: CMTime,
                         connection: AVCaptureConnection) {
        print("DEPTH")
        guard depth else { return }
        var convertedDepth: AVDepthData
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            convertedDepth = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        } else {
            convertedDepth = depthData
        }
        let pixelBuffer = convertedDepth.depthDataMap
//        pixelBuffer.clamp()

        DispatchQueue.main.async { [weak self] in
            self?.capturedCallback(pixelBuffer)
        }

    }
    
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        guard !depthProcessing else {
            pixelKit.logger.log(.error, .resource, "Camera depth processing, skipped frame.")
            return
        }
        depthProcessing = true
        DispatchQueue.global(qos: .background).async {
            
            guard let rawImageData: AVCaptureSynchronizedData = synchronizedDataCollection.synchronizedData(for: self.videoOutput!) else {
                self.pixelKit.logger.log(.error, .resource, "Camera image data not found.")
                self.depthProcessing = false
                return
            }
            guard let rawDepthData: AVCaptureSynchronizedData = synchronizedDataCollection.synchronizedData(for: self.depthOutput!) else {
                self.pixelKit.logger.log(.error, .resource, "Camera depth data not found.")
                self.depthProcessing = false
                return
            }
            
            guard let sampleBuffer = (rawImageData as? AVCaptureSynchronizedSampleBufferData)?.sampleBuffer else {
                self.pixelKit.logger.log(.error, .resource, "Camera image data in bad format.")
                self.depthProcessing = false
                return
            }
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                self.pixelKit.logger.log(.error, .resource, "Camera image data could not be converted.")
                self.depthProcessing = false
                return
            }
            
            guard let depthData = (rawDepthData as? AVCaptureSynchronizedDepthData)?.depthData else {
                self.pixelKit.logger.log(.error, .resource, "Camera depth data in bad format.")
                self.depthProcessing = false
                return
            }
            let depthPixelBuffer = depthData.depthDataMap
            
//            guard let rotatedDepthPixelBuffer = Texture.rotate90(pixelBuffer: depthPixelBuffer, factor: 3) else {
//                self.pixelKit.logger.log(.error, .resource, "Camera depth image rotation failed.")
//                self.depthProcessing = false
//                return
//            }
            
            DispatchQueue.main.async { [weak self] in
                self?.capturedCallback(pixelBuffer)
                self?.capturedDepthCallback(depthPixelBuffer)
            }
            self.depthProcessing = false
        }
    }

}
#endif
