//
//  CameraPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import AVKit

#if os(iOS)
typealias _Orientation = UIInterfaceOrientation
#elseif os(macOS)
typealias _Orientation = Void
#endif

public class CameraPIX: PIXResource, PIXofaKind {
    
    let kind: PIX.Kind = .camera
    
    override open var shader: String { return "contentResourceCameraPIX" }
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: _Orientation?
    
    // MARK: - Public Properties
    
    public enum CamRes: String, Codable, CaseIterable {
//        case autoLow = "Low"
//        case autoHigh = "High"
        case vga = "VGA"
        case _720p = "720p"
        #if os(iOS)
        case _1080p = "1080p"
        case _4K = "4K"
        #endif
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
//            case .autoLow:
//                return .low
//            case .autoMid:
//                return .medium
//            case .autoHigh:
//                return .high
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
//            case .photo:
//                return .photo
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
        case back = "Back Camera"
        #endif
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            #if os(iOS)
            case .back:
                return .back
            #endif
            }
        }
        var mirrored: Bool { return self == .front }
    }
    #if os(iOS)
    public var camera: Camera = .back { didSet { setupCamera() } }
    #elseif os(macOS)
    public var camera: Camera = .front { didSet { setupCamera() } }
    #endif
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case camera; case camRes
    }
    
    open override var uniforms: [CGFloat] {
        #if os(iOS)
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0]
        #elseif os(macOS)
        return [0, camera.mirrored ? 1 : 0]
        #endif
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        setupCamera()
    }
    
    // MARK: - JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let camera = try container.decode(Camera.self, forKey: .camera)
        let camRes = try container.decode(CamRes.self, forKey: .camRes)
        if camera != self.camera || camRes != self.camRes {
            self.camera = camera
            self.camRes = camRes
            setupCamera()
        }
    }
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(camera, forKey: .camera)
        try container.encode(camRes, forKey: .camRes)
    }
    
    // MARK: Access
    
    func requestAccess(gotAccess: @escaping () -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { accessGranted in
            if accessGranted {
                gotAccess()
            } else {
                self.pixels.log(pix: self, .warning, .resource, "Camera Access Not Granted.")
            }
            self.access = accessGranted
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
        helper = CameraHelper(camRes: camRes, cameraPosition: camera.position, setup: { _, orientation in
            self.pixels.log(pix: self, .info, .resource, "Camera setup.")
            // CHECK multiple setups on init
            self.orientation = orientation
            #if os(iOS)
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
            #elseif os(macOS)
            self.flop = false
            #endif
        }, captured: { pixelBuffer in
            self.pixels.log(pix: self, .info, .resource, "Camera frame captured.", loop: true)
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
        })
    }
    
    deinit {
        helper!.stop()
    }
    
}

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let pixels = Pixels.main
    
    let cameraPosition: AVCaptureDevice.Position
    
    let captureSession: AVCaptureSession
    let sessionOutput: AVCaptureVideoDataOutput
    
    var lastUIOrientation: _Orientation

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, _Orientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(camRes: CameraPIX.CamRes, cameraPosition: AVCaptureDevice.Position, setup: @escaping (CGSize, _Orientation) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
        self.cameraPosition = cameraPosition
        
        setupCallback = setup
        capturedCallback = captured
        
        #if os(iOS)
        lastUIOrientation = UIApplication.shared.statusBarOrientation
        #elseif os(macOS)
        lastUIOrientation = ()
        #endif
        
        captureSession = AVCaptureSession()
        sessionOutput = AVCaptureVideoDataOutput()
        
        super.init()
        
        let preset: AVCaptureSession.Preset = camRes.sessionPreset
        
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        } else {
            captureSession.sessionPreset = .high
        }
        
        sessionOutput.alwaysDiscardsLateVideoFrames = true
        sessionOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixels.colorBits.os]
        
        #if os(iOS)
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
        #elseif os(macOS)
        let device = AVCaptureDevice.default(for: .video)
        #endif
        
        if device != nil {
            do {
                let input = try AVCaptureDeviceInput(device: device!)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    if captureSession.canAddOutput(sessionOutput){
                        captureSession.addOutput(sessionOutput)
                        let queue = DispatchQueue(label: "se.hexagons.pixels.pix.camera.queue")
                        sessionOutput.setSampleBufferDelegate(self, queue: queue)
                        start()
                    } else {
                        pixels.log(.error, .resource, "Camera can't add output.")
                    }
                } else {
                    pixels.log(.error, .resource, "Camera can't add input.")
                }
            } catch {
                pixels.log(.error, .resource, "Camera input failed to load.", e: error)
            }
        } else {
            pixels.log(.error, .resource, "Camera not found.")
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
        let forceCount = pixels.fpsMax * 2
        var forceIndex = 0
        let forceTimer = Timer(timeInterval: 1 / Double(pixels.fpsMax), repeats: true, block: { timer in
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
            pixels.log(.error, .resource, "Camera buffer conversion failed.")
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
            pixels.log(.warning, .resource, "Camera orientation unknown.")
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
    
}

