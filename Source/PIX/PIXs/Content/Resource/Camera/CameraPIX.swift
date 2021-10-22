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
#if canImport(SwiftUI)
import SwiftUI
#endif
import PixelColor

#if os(iOS) && !targetEnvironment(macCatalyst)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS) || targetEnvironment(macCatalyst)
typealias _Orientation = Void
#endif

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
    
//    public var sampleBuffer: CMSampleBuffer?

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
        case _4K = "4K"
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
            case ._4K:
                return .hd4K3840x2160
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
            case ._4K: return ._4K
            #endif
            }
        }
        public init?(resolution: Resolution) {
            guard let cameraResolution = CameraResolution.allCases.first(where: { cameraResolution in
                cameraResolution.resolution == resolution
            }) else {
                return nil
            }
            self = cameraResolution
        }
    }
    #if os(iOS) && !targetEnvironment(macCatalyst)
    public var cameraResolution: CameraResolution = ._1080p { didSet { if setup { setupCamera() } } }
    #elseif os(macOS) || targetEnvironment(macCatalyst)
    public var cameraResolution: CameraResolution = ._720p { didSet { if setup { setupCamera() } } }
    #endif
    
    public var orientationCorrectResolution: Resolution {
        if flop {
            return cameraResolution.resolution.flopped
        } else {
            return cameraResolution.resolution
        }
    }
    
//    var orientedCameraResolution: Resolution {
//        #if os(iOS)
//        if [.portrait, .portraitUpsideDown].contains(orientation) {
//            return cameraResolution.resolution.flopped
//        }
//        #endif
//        return cameraResolution.resolution
//    }
//
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
            return self == .external
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
    public var filterDepth: Bool = true { didSet { if setup { setupCamera() } } }
    var depthCallback: ((CVPixelBuffer) -> ())?
    
    public var multi: Bool = false { didSet { if setup { setupCamera() } } }
    struct MultiCallback {
        let id: UUID
        let camera: () -> (Camera?)
        let setup: (_Orientation?) -> ()
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
        helper?.stop()
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
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: nil) { [weak self] (notif) -> Void in
            self?.camAttatched(device: notif.object! as! AVCaptureDevice)
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { [weak self] (notif) -> Void in
            self?.camDeattatched(device: notif.object! as! AVCaptureDevice)
        }
        #endif
//        #if os(iOS) && !targetEnvironment(macCatalyst)
//        NotificationCenter.default.addObserver(self, selector: #selector(orientationChangedNotification), name: UIDevice.orientationDidChangeNotification, object: nil)
//        #endif
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
        helper = CameraHelper(cameraResolution: cameraResolution,
                              cameraPosition: camera.position,
                              tele: camera.isTele,
                              ultraWide: camera.isUltraWide,
                              depth: depth,
                              filterDepth: filterDepth,
                              multiCameras: multiCameras,
                              useExternalCamera: extCam,
                              presentedDownstreamPix: { [weak self] in
            #if os(iOS)
            return self?.presentedDownstreamPix
            #else
            return nil
            #endif
        },
        setup: { [weak self] _, orientation in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera setup.")
            self.orientation = orientation
            #if os(iOS)
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
        }, clear: { [weak self] in
            self?.clearRender()
        }, captured: { [weak self] pixelBuffer in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .info, .resource, "Camera frame captured.", loop: true)
            self.resourcePixelBuffer = pixelBuffer
            if self.view.resolution == nil || self.view.resolution! != self.derivedResolution {
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
        }, capturedSampleBuffer: { [weak self] sampleBuffer in
//            self?.sampleBuffer = sampleBuffer
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
    
    public override func destroy() {
        super.destroy()
        helper?.stop()
        helper = nil
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
    
    // MARK: - Orienation
    
//    #if os(iOS)
//    @objc func orientationChangedNotification(_ notification: NSNotification) {
//        self.orientation = notification.object as? _Orientation
//    }
//    #endif
    
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

#endif
