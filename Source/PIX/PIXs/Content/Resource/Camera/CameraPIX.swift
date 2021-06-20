//
//  CameraPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//


import RenderKit
import Resolution
import AVKit
#if os(iOS) && !targetEnvironment(macCatalyst)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS) || targetEnvironment(macCatalyst)
typealias _Orientation = Void
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
import PixelColor

#if !os(tvOS)

public protocol CameraPIXDelegate {
    func cameraSetup(pix: CameraPIX)
    func cameraFrame(pix: CameraPIX, pixelBuffer: CVPixelBuffer)
}

final public class CameraPIX: PIXResource, PIXViewable {
        
    override public var shaderName: String { return "contentResourceCameraPIX" }
    
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
    
    public var active: Bool = true {
        didSet {
            if active {
                helper?.start()
            } else {
                helper?.stop()
            }
        }
    }
    
    public enum CameraResolution: String, Codable, CaseIterable {
        case vga = "VGA"
        case _540p = "540p"
        case _720p = "720p"
        #if os(iOS) && !targetEnvironment(macCatalyst)
        case _1080p = "1080p"
//        case _4K = "4K"
        #endif
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
            case .vga:
                return .vga640x480
            case ._540p:
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
            case ._540p: return .custom(w: 960, h: 540)
            case ._720p: return ._720p
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case ._1080p: return ._1080p
//            case ._4K: return ._4K
            #endif
            }
        }
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var cameraResolution: CameraResolution = ._1080p { didSet { if setup { setupCamera() } } }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public var cameraResolution: CameraResolution = ._720p { didSet { if setup { setupCamera() } } }
    #endif
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        #if os(iOS) && !targetEnvironment(macCatalyst)
        case back = "Wide Camera"
        case tele = "Tele Camera"
        case ultraWide = "Ultra Wide Camera"
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        case external = "External Camera"
        #endif
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case .back, .tele, .ultraWide:
                return .back
            #elseif os(macOS) || targetEnvironment(macCatalyst)
            case .external:
                return .back
            #endif
            }
        }
        @available(OSX 10.15, *)
        var deviceType: AVCaptureDevice.DeviceType {
            switch self {
            #if os(iOS) && !targetEnvironment(macCatalyst)
            case .tele:
                return .builtInTelephotoCamera
            case .ultraWide:
                if #available(iOS 13.0, *) {
                    return .builtInUltraWideCamera
                } else {
                    return .builtInWideAngleCamera
                }
            #endif
            default:
                return .builtInWideAngleCamera
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
        var isUltraWide: Bool {
            #if os(iOS) && !targetEnvironment(macCatalyst)
            return self == .ultraWide
            #elseif os(macOS) || targetEnvironment(macCatalyst)
            return false
            #endif
        }
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var camera: Camera = .back { didSet { if setup { setupCamera() } } }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public var camera: Camera = .front { didSet { if setup { setupCamera() } } }
    #endif
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    public var autoDetect: Bool = true
    #endif
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    
    public var depth: Bool = false { didSet { if setup { setupCamera() } } }
    public var filterDepth: Bool = false { didSet { if setup { setupCamera() } } }
    var depthCallback: ((CVPixelBuffer) -> ())?
    
    public var multi: Bool = false { didSet { if setup { setupCamera() } } }
    struct MultiCallback {
        let id: UUID
        let camera: () -> (Camera?)
        let setup: (_Orientation) -> ()
        let frameLoop: (CVPixelBuffer) -> ()
    }
    var multiCallbacks: [MultiCallback] = []
    
    public var manualExposure: Bool = false {
        didSet {
            helper?.manualExposure(manualExposure)
            if manualExposure {
                helper?.setLight(exposure, iso)
            }
        }
    }
    /// exposure time in seconds
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
    public var torch: CGFloat = 0.0 {
        didSet {
            helper?.setTorch(torch)
        }
    }
    
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
                helper?.setWhiteBalance(PixelColor(whiteBalance))
            }
        }
    }
    public var whiteBalance: UIColor {
        get {
            return helper?.getWhiteBalance().uiColor ?? .white
        }
        set {
            guard manualWhiteBalance else { return }
            helper?.setWhiteBalance(PixelColor(newValue))
        }
    }

    public var minExposure: CGFloat? {
        return helper?.minExposure
    }
    public var maxExposure: CGFloat? {
        return helper?.maxExposure
    }
    
    public var minISO: CGFloat? {
        return helper?.minISO
    }
    public var maxISO: CGFloat? {
        return helper?.maxISO
    }
    
    #endif
    
    var setup: Bool = false
    var didSetup: Bool = false
    var setupCallbacks: [() -> ()]  = []

    // MARK: - Property Helpers
    
    public override var uniforms: [CGFloat] {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        return [4, camera.mirrored ? 1 : 0, camera.flipFlop ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Camera", typeName: "pix-content-resource-camera")
        DispatchQueue.main.async { [weak self] in
            self?.setupCamera()
            self?.setup = true
        }
        setupNotifications()
    }
    
    public convenience init(at cameraResolution: CameraResolution? = nil, camera: Camera? = nil) {
        self.init()
        #if os(iOS) && !targetEnvironment(macCatalyst)
        self.camera = camera ?? .back
        self.cameraResolution = cameraResolution ?? ._1080p
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        self.camera = camera ?? .front
        self.cameraResolution = cameraResolution ?? ._720p
        #endif
        setupCamera()
    }
    
    deinit {
        helper!.stop()
    }
    
    // MARK: Codable
    
    enum CodingKeys: CodingKey {
        case active
        case cameraResolution
        case camera
        case autoDetect
        case depth
        case filterDepth
        case multi
        case manualExposure
        case exposure
        case iso
        case torch
        case manualFocus
        case focus
        case focusPoint
        case manualWhiteBalance
        case whiteBalance
        case minExposure
        case maxExposure
        case minISO
        case maxISO
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        active = try container.decode(Bool.self, forKey: .active)
        cameraResolution = try container.decode(CameraResolution.self, forKey: .cameraResolution)
        camera = try container.decode(Camera.self, forKey: .camera)
        
        try super.init(from: decoder)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.setupCamera()
            self.setup = true
        
            #if os(macOS) || targetEnvironment(macCatalyst)
            if let value = try? container.decode(Bool.self, forKey: .autoDetect) { self.autoDetect = value }
            #endif
            
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if let value = try? container.decode(Bool.self, forKey: .depth) { self.depth = value }
            if let value = try? container.decode(Bool.self, forKey: .filterDepth) { self.filterDepth = value }
            if let value = try? container.decode(Bool.self, forKey: .multi) { self.multi = value }
            if let value = try? container.decode(Bool.self, forKey: .manualExposure) { self.manualExposure = value }
            if let value = try? container.decode(CGFloat.self, forKey: .exposure) { self.exposure = value }
            if let value = try? container.decode(CGFloat.self, forKey: .iso) { self.iso = value }
            if let value = try? container.decode(CGFloat.self, forKey: .torch) { self.torch = value }
            if let value = try? container.decode(Bool.self, forKey: .manualFocus) { self.manualFocus = value }
            if let value = try? container.decode(CGFloat.self, forKey: .focus) { self.focus = value }
            if let value = try? container.decode(Bool.self, forKey: .manualWhiteBalance) { self.manualWhiteBalance = value }
            if let value = try? container.decode(PixelColor.self, forKey: .whiteBalance) { self.whiteBalance = value.uiColor }
            #endif
            
        }
        setupNotifications()
    }
    
    public override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(active, forKey: .active)
        try container.encode(cameraResolution, forKey: .cameraResolution)
        try container.encode(camera, forKey: .camera)
        
        #if os(macOS) || targetEnvironment(macCatalyst)
        try container.encode(autoDetect, forKey: .autoDetect)
        #endif
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        try container.encode(depth, forKey: .depth)
        try container.encode(filterDepth, forKey: .filterDepth)
        try container.encode(multi, forKey: .multi)
        try container.encode(manualExposure, forKey: .manualExposure)
        try container.encode(exposure, forKey: .exposure)
        try container.encode(iso, forKey: .iso)
        try container.encode(torch, forKey: .torch)
        try container.encode(manualFocus, forKey: .manualFocus)
        try container.encode(focus, forKey: .focus)
        try container.encode(manualWhiteBalance, forKey: .manualWhiteBalance)
        try container.encode(PixelColor(whiteBalance), forKey: .whiteBalance)
        #endif
        
        try super.encode(to: encoder)
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
    
    func setupNotifications() {
        #if os(macOS)
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: nil) { (notif) -> Void in
            self.camAttatched(device: notif.object! as! AVCaptureDevice)
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { (notif) -> Void in
            self.camDeattatched(device: notif.object! as! AVCaptureDevice)
        }
        #endif
    }
    
    func setupCamera() {
        if !access {
            requestAccess {
                DispatchQueue.main.async { [weak self] in
                    self?.setupCamera()
                }
                return
            }
            return
        }
        helper?.stop()
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let extCam = false
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let extCam = camera == .external
        #endif
        #if os(iOS) && !targetEnvironment(macCatalyst)
        let depth = self.depth
        let filterDepth = self.filterDepth
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let depth = false
        let filterDepth = false
        #endif
        #if os(iOS) && !targetEnvironment(macCatalyst)
        var multiCameras: [Camera]?
        if #available(iOS 13.0, *) {
            multiCameras = self.multi ? self.multiCallbacks.compactMap({ $0.camera() }) : nil
        }
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let multiCameras: [Camera]? = nil
        #endif
        helper = CameraHelper(cameraResolution: cameraResolution, cameraPosition: camera.position, tele: camera.isTele, ultraWide: camera.isUltraWide, depth: depth, filterDepth: filterDepth, multiCameras: multiCameras, useExternalCamera: extCam, setup: { [weak self] _, orientation in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera setup.")
            // CHECK multiple setups on init
            self.orientation = orientation
            #if os(iOS) && !targetEnvironment(macCatalyst)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #endif
            self.cameraDelegate?.cameraSetup(pix: self)
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if self.multi {
                self.multiCallbacks.forEach { multiCallback in
                    multiCallback.setup(orientation)
                }
            }
            #endif
            self.setupCallbacks.forEach({ $0() })
            self.setupCallbacks = []
            self.didSetup = true
        }, captured: { [weak self] pixelBuffer in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera frame captured.", loop: true)
            self.resourcePixelBuffer = pixelBuffer
            if self.view.resolution == nil || self.view.resolution! != self.finalResolution {
                self.applyResolution { [weak self] in
                    self?.render()
                }
            } else {
                self.render()
            }
            self.cameraDelegate?.cameraFrame(pix: self, pixelBuffer: pixelBuffer)
        }, capturedDepth: { [weak self] depthPixelBuffer in
            #if os(iOS) && !targetEnvironment(macCatalyst)
            self?.depthCallback?(depthPixelBuffer)
            #endif
        }, capturedMulti: { [weak self] multiIndex, multiPixelBuffer in
            guard let self = self else { return }
            #if os(iOS) && !targetEnvironment(macCatalyst)
            guard multiIndex < self.multiCallbacks.count else { return }
            self.multiCallbacks[multiIndex].frameLoop(multiPixelBuffer)
            #endif
        })
    }
    
    public func listenToSetup(_ completion: @escaping () -> ()) {
        guard !didSetup else {
            completion()
            return
        }
        setupCallbacks.append(completion)
    }
    
    public static func supports(cameraResolution: CameraPIX.CameraResolution) -> Bool {
        CameraHelper.supports(cameraResolution: cameraResolution)
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
    
    // MARK: - Property Funcs
    
    public func pixCameraActive(_ value: Bool) -> CameraPIX {
        active = value
        return self
    }
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public func pixCameraManualExposure(_ value: Bool = true) -> CameraPIX {
        manualExposure = value
        return self
    }
    
    public func pixCameraExposure(_ value: CGFloat) -> CameraPIX {
        if !manualExposure {
            manualExposure = true
        }
        exposure = value
        return self
    }
    
    public func pixCameraISO(_ value: CGFloat) -> CameraPIX {
        if !manualExposure {
            manualExposure = true
        }
        iso = value
        return self
    }
    
    public func pixCameraTorch(_ value: CGFloat) -> CameraPIX {
        torch = value
        return self
    }
    
    public func pixCameraManualFocus(_ value: Bool = true) -> CameraPIX {
        manualFocus = value
        return self
    }
    
    public func pixCameraFocus(_ value: CGFloat) -> CameraPIX {
        if !manualFocus {
            manualFocus = true
        }
        focus = value
        return self
    }
    
    public func pixCameraManualWhiteBalance(_ value: Bool = true) -> CameraPIX {
        manualWhiteBalance = value
        return self
    }
    
    public func pixCameraWhiteBalance(_ value: UIColor) -> CameraPIX {
        if !manualFocus {
            manualFocus = true
        }
        whiteBalance = value
        return self
    }
    #endif
    
}














// MARK: - Camera Helper

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate/*, AVCapturePhotoCaptureDelegate*/ {

    let pixelKit = PixelKit.main
    
    var device: AVCaptureDevice?

//    let photoSupport: Bool
    
    let captureSession: AVCaptureSession
    var videoOutput: AVCaptureVideoDataOutput?

    #if os(iOS)
    var isMulti: Bool
    var multiDevices: [AVCaptureDevice] = []
    var multiVideoOutputs: [AVCaptureVideoDataOutput] = []
    #endif

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
    let capturedMultiCallback: (Int, CVPixelBuffer) -> ()

    init(cameraResolution: CameraPIX.CameraResolution, cameraPosition: AVCaptureDevice.Position, tele: Bool = false, ultraWide: Bool = false, depth: Bool = false, filterDepth: Bool, multiCameras: [CameraPIX.Camera]?, useExternalCamera: Bool = false, /*photoSupport: Bool = false, */setup: @escaping (CGSize, _Orientation) -> (), captured: @escaping (CVPixelBuffer) -> (), capturedDepth: @escaping (CVPixelBuffer) -> (), capturedMulti: @escaping (Int, CVPixelBuffer) -> ()) {
        
        var multi: Bool = false
        
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
                deviceType = .builtInTelephotoCamera
            } else if ultraWide {
                if #available(iOS 13.0, *) {
                    deviceType = .builtInUltraWideCamera
                } else {
                    pixelKit.logger.log(.warning, .resource, "Ultra Wide Camera is only avalible in iOS 13.")
                    deviceType = .builtInWideAngleCamera
                }
            } else {
                deviceType = .builtInWideAngleCamera
            }
        }
        
        var multiDeviceTypes: [AVCaptureDevice.DeviceType] = []
        var multiCameraPositions: [AVCaptureDevice.Position] = []
        if let multiCameras: [CameraPIX.Camera] = multiCameras {
            multiDeviceTypes.append(deviceType)
            multiDeviceTypes.append(contentsOf: multiCameras.map({ $0.deviceType }))
            multiCameraPositions.append(cameraPosition)
            multiCameraPositions.append(contentsOf: multiCameras.map({ $0.position }))
            multi = true
        }
        
        if !multi {
            pixelKit.logger.log(.info, .resource, "Camera \"\(deviceType.rawValue)\" Setup.")
            device = AVCaptureDevice.default(deviceType, for: .video, position: cameraPosition)
            if device == nil {
                device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
            }
        } else {
            for camera in zip(multiDeviceTypes, multiCameraPositions) {
                guard let multiDevice = AVCaptureDevice.default(camera.0, for: .video, position: camera.1) else {
                    fatalError("PixelKit - Multi Camera - Device Failed")
                }
                multiDevices.append(multiDevice)
            }
        }
        
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        
        if !useExternalCamera {
            device = AVCaptureDevice.default(for: .video)
        } else {
            var firstFound = false
            var secondFound = false
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            for iDevice in discoverySession.devices {
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
        
        #if os(iOS)
        isMulti = multi
        #endif
        
//        self.photoSupport = photoSupport
        
        setupCallback = setup
        capturedCallback = captured
        capturedDepthCallback = capturedDepth
        capturedMultiCallback = capturedMulti
        
        #if os(iOS) && !targetEnvironment(macCatalyst)
        lastUIOrientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        lastUIOrientation = ()
        #endif
        
        if !multi {
            captureSession = AVCaptureSession()
        } else {
            #if os(iOS)
            if #available(iOS 13.0, *) {
                captureSession = AVCaptureMultiCamSession()
            } else {
                fatalError("Multi Cam Requires iOS 13")
            }
            #else
            fatalError("Multi Cam Requires iOS")
            #endif
        }

        if !multi {
            videoOutput = AVCaptureVideoDataOutput()
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if depth {
                depthOutput = AVCaptureDepthDataOutput()
            }
            #endif
        } else {
            #if os(iOS)
            for _ in 0..<(multiCameras!.count + 1) {
                multiVideoOutputs.append(AVCaptureVideoDataOutput())
            }
            #endif
        }
        
//        photoOutput = photoSupport ? AVCapturePhotoOutput() : nil
        
        
        super.init()
        
        
        if !multi {
            guard device != nil else {
                pixelKit.logger.log(.error, nil, "Camera device not found.")
                return
            }
        }
        
        if !multi {
            let preset: AVCaptureSession.Preset = depth ? .vga640x480 : cameraResolution.sessionPreset
            if captureSession.canSetSessionPreset(preset) {
                captureSession.sessionPreset = preset
                pixelKit.logger.log(.info, nil, "Camera preset set to: \(preset)")
            } else if captureSession.canSetSessionPreset(.high) {
                pixelKit.logger.log(.warning, nil, "Default camera preset (\(preset)) can't be added. Defaulting to .high.")
                captureSession.sessionPreset = .high
            } else if captureSession.canSetSessionPreset(.medium) {
                pixelKit.logger.log(.warning, nil, "Camera preset .high can't be added. Defaulting to .medium.")
                captureSession.sessionPreset = .medium
            } else if captureSession.canSetSessionPreset(.low) {
                pixelKit.logger.log(.warning, nil, "Camera preset .medium can't be added. Defaulting to .low.")
                captureSession.sessionPreset = .low
            } else {
                pixelKit.logger.log(.error, nil, "No good camera preset found found.")
                return
            }
        } else {
//            if #available(iOS 13.0, *) {
//                multiDevices.forEach { multiDevice in
//                    let targetWidth: Int = cameraResolution.resolution.w
//                    let targetHeight: Int = cameraResolution.resolution.h
//                    var deviceFormat: AVCaptureDevice.Format?
//                    for format in multiDevice.formats {
//                        let dimensions = format.formatDescription.dimensions
//                        let width = Int(dimensions.width)
//                        let height = Int(dimensions.height)
//                        if targetWidth == width && targetHeight == height {
//                            guard format.isMultiCamSupported else { continue }
//                            deviceFormat = format
//                            break
//                        }
//                    }
//                    if let format = deviceFormat {
//                        do {
//                            try multiDevice.lockForConfiguration()
//                            multiDevice.activeFormat = format
//                            multiDevice.unlockForConfiguration()
//                            print("CAM", multiDevice.deviceType.rawValue, format.formatDescription.dimensions.width, format.formatDescription.dimensions.height)
//                        } catch {
//                            pixelKit.logger.log(.error, nil, "Camera Device configuration failed for \"\(multiDevice.deviceType.rawValue)\".")
//                        }
//                    } else {
//                        pixelKit.logger.log(.error, nil, "CameraResolution not supported for \"\(multiDevice.deviceType.rawValue)\".")
//                    }
//                }
//            }
        }

        pixelKit.logger.log(.info, .resource, "Camera Active Format: \(device!.activeFormat.description)")
        
//        print("Active Format: \(device!.activeFormat.description)")
//
//        let maxFpsDesired: Double = Double(UIScreen.main.maximumFramesPerSecond)
//        var finalMaxFps: Double?
//        var finalFormat: AVCaptureDevice.Format?
//        for format in device!.formats {
//            guard let frameRateRange: AVFrameRateRange = format.videoSupportedFrameRateRanges.first else { continue }
//            print("Format: \(device!.activeFormat.description) fps(min: \(frameRateRange.minFrameRate), max: \(frameRateRange.maxFrameRate))")
//            let maxFps: Double = frameRateRange.maxFrameRate
//            if maxFps >= (finalMaxFps ?? 0.0) && maxFps <= maxFpsDesired {
//                finalMaxFps = maxFps
//                finalFormat = format
//            }
////            finalFormat = ?
//        }
//        if let format: AVCaptureDevice.Format = finalFormat, let fps: Double = finalMaxFps {
//            print("Final Format: \(format.description)")
//            let timeValue = Int64(1200.0 / fps)
//            let timeScale: Int64 = 1200
//            do {
//                try device!.lockForConfiguration()
//                device!.activeFormat = format
//                device!.activeVideoMinFrameDuration = CMTimeMake(value: timeValue, timescale: Int32(timeScale))
//                device!.activeVideoMaxFrameDuration = CMTimeMake(value: timeValue, timescale: Int32(timeScale))
//                device!.unlockForConfiguration()
//                pixelKit.logger.log(.info, nil, "Camera device final format set to: \(format.description) fps: \(fps)")
//            } catch {
//                pixelKit.logger.log(.error, nil, "Camera device final format fail", e: error)
//                return
//            }
//        }
        
        if !multi {
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixelKit.render.bits.os]
        } else {
            #if os(iOS)
            multiVideoOutputs.forEach { multiVideoOutput in
                multiVideoOutput.alwaysDiscardsLateVideoFrames = true
                multiVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixelKit.render.bits.os]
            }
            #endif
        }

        #if os(iOS) && !targetEnvironment(macCatalyst)
        if depth {
            depthOutput!.isFilteringEnabled = filterDepth
        }
        #endif
        
        do {
            if !multi {
                let input = try AVCaptureDeviceInput(device: device!)
                guard captureSession.canAddInput(input) else {
                    pixelKit.logger.log(.error, .resource, "Camera can't add input.")
                    return
                }
                captureSession.addInput(input)
                guard captureSession.canAddOutput(videoOutput!) else {
                    pixelKit.logger.log(.error, .resource, "Camera can't add output.")
                    return
                }
                captureSession.addOutput(videoOutput!)
            } else {
                #if os(iOS)
                try multiDevices.forEach { multiDevice in
                    let input = try AVCaptureDeviceInput(device: multiDevice)
                    guard captureSession.canAddInput(input) else {
                        pixelKit.logger.log(.error, .resource, "Camera can't add multi input.")
                        return
                    }
                    captureSession.addInput(input)
                }
                multiVideoOutputs.forEach { multiVideoOutput in
                    guard captureSession.canAddOutput(multiVideoOutput) else {
                        pixelKit.logger.log(.error, .resource, "Camera can't add multi output.")
                        return
                    }
                    captureSession.addOutput(multiVideoOutput)
                }
                #endif
            }
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if depth {
                guard captureSession.canAddOutput(depthOutput!) else {
                    pixelKit.logger.log(.error, .resource, "Camera can't add depth output.")
                    return
                }
                captureSession.addOutput(depthOutput!)
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
                if !multi {
                    videoOutput!.setSampleBufferDelegate(self, queue: queue)
                } else {
                    #if os(iOS)
                    multiVideoOutputs.forEach { multiVideoOutput in
                        multiVideoOutput.setSampleBufferDelegate(self, queue: queue)
                    }
                    #endif
                }
            }
            start()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera input failed to load.", e: error)
        }
        
    
        #if os(iOS) && !targetEnvironment(macCatalyst)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
        
    }
    
    static func supports(cameraResolution: CameraPIX.CameraResolution) -> Bool {
        AVCaptureSession().canSetSessionPreset(cameraResolution.sessionPreset)
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
        
        func main() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
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
        
        #if !os(iOS)
        main()
        #else
        if !isMulti {
            
            main()
            
        } else {
            
            guard let videoOutput = output as? AVCaptureVideoDataOutput else { return }
            guard let index: Int = multiVideoOutputs.firstIndex(of: videoOutput) else { return }
            if index == 0 {
                main()
            } else {
                let multiIndex: Int = index - 1
                DispatchQueue.main.async { [weak self] in
                    
                    self?.capturedMultiCallback(multiIndex, pixelBuffer)
                    
                }
            }
            
        }
        #endif
        
        
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
        pixelKit.logger.log(.info, .resource, "Manual Exposure active:\(active)")
        do {
            try device?.lockForConfiguration()
            device?.exposureMode = active ? .custom : .continuousAutoExposure
            device?.unlockForConfiguration()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (exposureMode) failed.", e: error)
        }
    }
    
    func manualFocus(_ active: Bool) {
        pixelKit.logger.log(.info, .resource, "Manual Focus active:\(active)")
        guard device?.isFocusModeSupported(.locked) == true else {
            pixelKit.logger.log(.info, .resource, "Manual Focus - Failed - Not Supported")
            return
        }
        do {
            try device?.lockForConfiguration()
            device?.focusMode = active ? .locked : .continuousAutoFocus
            device?.unlockForConfiguration()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (focusMode) failed.", e: error)
        }
    }
    
    func manualWhiteBalance(_ active: Bool) {
        pixelKit.logger.log(.info, .resource, "Manual White Balance active:\(active)")
        do {
            try device?.lockForConfiguration()
            device?.whiteBalanceMode = active ? .locked : .continuousAutoWhiteBalance
            device?.unlockForConfiguration()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera custom setting (whiteBalanceMode) failed.", e: error)
        }
    }
    
    var minExposure: CGFloat? {
        guard let device = device else { return nil }
        return CGFloat(device.activeFormat.minExposureDuration.seconds)
    }
    var maxExposure: CGFloat? {
        guard let device = device else { return nil }
        return CGFloat(device.activeFormat.maxExposureDuration.seconds)
    }
    
    var minISO: CGFloat? {
        guard let device = device else { return nil }
        return CGFloat(device.activeFormat.minISO)
    }
    var maxISO: CGFloat? {
        guard let device = device else { return nil }
        return CGFloat(device.activeFormat.maxISO)
    }
    
    func setLight(_ exposure: CGFloat, _ iso: CGFloat) {
        pixelKit.logger.log(.info, .resource, "Camera Light exposure:\(exposure) iso:\(iso)")
        guard let device = device else {
            pixelKit.logger.log(.warning, .resource, "Camera Light - Failed - Device is nil")
            return
        }
        let clampedExposure = min(max(exposure, minExposure ?? 0.0), maxExposure ?? 1.0)
        let clampedIso = min(max(iso, minISO ?? 0), maxISO ?? 1000)
        do {
            try device.lockForConfiguration()
            device.setExposureModeCustom(duration: CMTime(seconds: Double(clampedExposure), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), iso: Float(clampedIso))
            device.unlockForConfiguration()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera Light - Failed with Error", e: error)
        }
    }
    func setTorch(_ value: CGFloat) {
        pixelKit.logger.log(.info, .resource, "Camera Torch \(value)")
        guard let device = device else {
            pixelKit.logger.log(.warning, .resource, "Camera Torch - Failed - Device is nil")
            return
        }
        let level: Float = Float(min(max(value, 0.0), 1.0))
        if level > 0.0 {
            guard device.isTorchModeSupported(.on) else {
                pixelKit.logger.log(.warning, .resource, "Camera Torch - Failed - Not ON Supported")
                return
            }
        } else {
            guard device.isTorchModeSupported(.off) else {
                pixelKit.logger.log(.warning, .resource, "Camera Torch - Failed - Not OFF Supported")
                return
            }
        }
        do {
            try device.lockForConfiguration()
            if level > 0.0 {
                try device.setTorchModeOn(level: level)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            pixelKit.logger.log(.error, .resource, "Camera Torch - Failed with Error", e: error)
        }
    }
    
    func setFocus(_ value: CGFloat) {
        guard let device = device else { return }
        guard device.isFocusModeSupported(.locked) else { return }
        try? device.lockForConfiguration()
        device.setFocusModeLocked(lensPosition: Float(value))
        device.unlockForConfiguration()
    }
    
    func setWhiteBalance(_ color: PixelColor) {
        guard let device = device else { return }
        let range = device.maxWhiteBalanceGain - 1.0
        try? device.lockForConfiguration()
        device.setWhiteBalanceModeLocked(with: AVCaptureDevice.WhiteBalanceGains(redGain: 1.0 + Float(color.red) * range, greenGain: 1.0 + Float(color.green) * range, blueGain: 1.0 + Float(color.blue) * range))
        device.unlockForConfiguration()
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

    func getWhiteBalance() -> PixelColor {
        guard let device = device else { return .clear }
        let range = device.maxWhiteBalanceGain - 1.0
        return PixelColor(red: CGFloat((device.deviceWhiteBalanceGains.redGain - 1.0) / range),
                          green: CGFloat((device.deviceWhiteBalanceGains.greenGain - 1.0) / range),
                          blue: CGFloat((device.deviceWhiteBalanceGains.blueGain - 1.0) / range))
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


//extension CVPixelBuffer {
//
//  func normalize() {
//
//    let width = CVPixelBufferGetWidth(self)
//    let height = CVPixelBufferGetHeight(self)
//
//    CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
//    let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float>.self)
//
//    var minPixel: Float = 1.0
//    var maxPixel: Float = 0.0
//
//    for y in 0 ..< height {
//      for x in 0 ..< width {
//        let pixel = floatBuffer[y * width + x]
//        minPixel = min(pixel, minPixel)
//        maxPixel = max(pixel, maxPixel)
//      }
//    }
//
//    let range = maxPixel - minPixel
//
//    for y in 0 ..< height {
//      for x in 0 ..< width {
//        let pixel = floatBuffer[y * width + x]
//        floatBuffer[y * width + x] = (pixel - minPixel) / range
//      }
//    }
//
//    CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
//  }
//
//}

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

#endif
