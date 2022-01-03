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
    
    public typealias Model = CameraPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { return "contentResourceCameraPIX" }
    
    public var cameraDelegate: CameraPIXDelegate?
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: _Orientation?
    
//    public var sampleBuffer: CMSampleBuffer?

    public override var bypass: Bool {
        didSet {
            helper?.bypass = bypass
        }
    }
    
    // MARK: - Public Properties
    
    public var active: Bool {
        get { model.active }
        set {
            model.active = newValue
            if newValue {
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
        case _1080p = "1080p"
        #if os(iOS) && !targetEnvironment(macCatalyst)
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
            case ._1080p:
                return .hd1920x1080
            #if os(iOS) && !targetEnvironment(macCatalyst)
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
            case ._1080p: return ._1080p
            #if os(iOS) && !targetEnvironment(macCatalyst)
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
    public var cameraResolution: CameraResolution {
        get { model.cameraResolution }
        set {
            model.cameraResolution = newValue
            if setup {
                setupCamera()
            }
        }
    }
    
    public var orientationCorrectResolution: Resolution {
        if flop {
            return cameraResolution.resolution.flopped
        } else {
            return cameraResolution.resolution
        }
    }
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        #if os(iOS) && !targetEnvironment(macCatalyst)
        case back = "Wide Camera"
        case tele = "Tele Camera"
        case ultraWide = "Ultra Wide Camera"
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        case external = "External Camera"
        #endif
        public static let `default`: Camera = {
            #if os(iOS)
            return .back
            #elseif os(macOS)
            return .front
            #endif
        }()
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
    public var camera: Camera {
        get { model.camera }
        set {
            model.camera = newValue
            if setup {
                setupCamera()
            }
        }
    }
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    public var autoDetect: Bool {
        get { model.autoDetect }
        set { model.autoDetect = newValue }
    }
    #endif
    
    #if os(iOS) && !targetEnvironment(macCatalyst)
    
    public var depth: Bool {
        get { model.depth }
        set {
            model.depth = newValue
            if setup {
                setupCamera()
            }
        }
    }
    public var filterDepth: Bool {
        get { model.filterDepth }
        set {
            model.filterDepth = newValue
            if setup {
                setupCamera()
            }
        }
    }
    var depthCallback: ((CVPixelBuffer) -> ())?
    
    public var multi: Bool {
        get { model.multi }
        set {
            model.multi = newValue
            if setup {
                setupCamera()
            }
        }
    }
    struct MultiCallback {
        let id: UUID
        let camera: () -> (Camera?)
        let setup: (_Orientation?) -> ()
        let frameLoop: (CVPixelBuffer) -> ()
    }
    var multiCallbacks: [MultiCallback] = []
    
    public var manualExposure: Bool {
        get { model.manualExposure }
        set {
            model.manualExposure = newValue
            helper?.manualExposure(newValue)
            if newValue {
                helper?.setLight(exposure, iso)
            }
        }
    }
    /// exposure time in seconds
    public var exposure: CGFloat {
        get { model.exposure }
        set {
            model.exposure = newValue
            guard manualExposure else { return }
            helper?.setLight(newValue, iso)
        }
    }
    public var iso: CGFloat {
        get { model.iso }
        set {
            model.iso = newValue
            guard manualExposure else { return }
            helper?.setLight(exposure, newValue)
        }
    }
    public var torch: CGFloat {
        get { model.torch }
        set {
            model.torch = newValue
            helper?.setTorch(newValue)
        }
    }
    
    public var manualFocus: Bool {
        get { model.manualFocus }
        set {
            model.manualFocus = newValue
            helper?.manualFocus(newValue)
            if newValue {
                helper?.setFocus(focus)
            }
        }
    }
    public var focus: CGFloat {
        get { model.focus }
        set {
            model.focus = newValue
            guard manualFocus else { return }
            helper?.setFocus(newValue)
        }
    }
    public var focusPoint: CGPoint {
        helper?.getFocusPoint() ?? .zero
    }
    
    public var manualWhiteBalance: Bool {
        get { model.manualWhiteBalance }
        set {
            model.manualWhiteBalance = newValue
            helper?.manualWhiteBalance(newValue)
            if newValue {
                helper?.setWhiteBalance(whiteBalance)
            }
        }
    }
    public var realWhiteBalance: PixelColor {
        helper?.getWhiteBalance() ?? .clear
    }
    public var whiteBalance: PixelColor {
        get { model.whiteBalance }
        set {
            model.whiteBalance = newValue
            guard manualWhiteBalance else { return }
            helper?.setWhiteBalance(newValue)
        }
    }

    public var minExposure: CGFloat? {
        helper?.minExposure
    }
    public var maxExposure: CGFloat? {
        helper?.maxExposure
    }
    
    public var minISO: CGFloat? {
        helper?.minISO
    }
    public var maxISO: CGFloat? {
        helper?.maxISO
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
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
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
    }
    
    deinit {
        helper?.stop()
    }
    
    // MARK: Access
    
    func requestAccess(gotAccess: @escaping () -> ()) {
        if #available(OSX 10.14, *) {
            AVCaptureDevice.requestAccess(for: .video) { accessGranted in
                if accessGranted {
                    gotAccess()
                } else {
                    PixelKit.main.logger.log(node: self, .warning, .resource, "Camera Access Not Granted.")
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
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: nil) { [weak self] (notification) -> Void in
            self?.cameraAttached(device: notification.object! as! AVCaptureDevice)
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: nil) { [weak self] (notification) -> Void in
            self?.cameraDetached(device: notification.object! as! AVCaptureDevice)
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
            PixelKit.main.logger.log(node: self, .info, .resource, "Camera setup.")
            self.orientation = orientation
            #if os(iOS)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #else
            self.flop = false
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
            PixelKit.main.logger.log(node: self, .info, .resource, "Camera frame captured.", loop: true)
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
        if !active {
            helper!.stop()
        }
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
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Camera Attachment
    
    #if os(macOS) || targetEnvironment(macCatalyst)
    
    func cameraAttached(device: AVCaptureDevice) {
        guard autoDetect else { return }
        PixelKit.main.logger.log(node: self, .info, .resource, "Camera Attatched.")
        setupCamera()
    }
    
    func cameraDetached(device: AVCaptureDevice) {
        guard autoDetect else { return }
        PixelKit.main.logger.log(node: self, .info, .resource, "Camera Deattatched.")
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
    
    public func pixCameraWhiteBalance(_ value: PixelColor) -> CameraPIX {
        if !manualFocus {
            manualFocus = true
        }
        whiteBalance = value
        return self
    }
    #endif
}

#endif
