//
//  CameraPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import AVKit

public class CameraPIX: PIXResource, PIXofaKind {
    
    let kind: PIX.Kind = .camera
    
    override open var shader: String { return "contentResourceCameraPIX" }
    
    // MARK: - Private Properties
    
    var helper: CameraHelper?
    
    var access: Bool = false
    var orientation: UIInterfaceOrientation?
    
    // MARK: - Public Properties
    
    public enum CamRes: String, Codable, CaseIterable {
//        case autoLow = "Low"
//        case autoHigh = "High"
        case vga = "VGA"
        case _720p = "720p"
        case _1080p = "1080p"
        case _4K = "4K"
        public var sessionPreset: AVCaptureSession.Preset {
            switch self {
//            case .autoLow:
//                return .low
//            case .autoHigh:
//                return .high
            case .vga:
                return .vga640x480
            case ._720p:
                return .hd1280x720
            case ._1080p:
                return .hd1920x1080
            case ._4K:
                return .hd4K3840x2160
//            case .photo:
//                return .photo
            }
        }
        public var res: Res {
            switch self {
            case .vga: return .custom(w: 640, h: 480)
            case ._720p: return ._720p
            case ._1080p: return ._1080p
            case ._4K: return ._4K
            }
        }
    }
    public var camRes: CamRes = ._1080p { didSet { setupCamera() } }
    
    public enum Camera: String, Codable, CaseIterable {
        case front = "Front Camera"
        case back = "Back Camera"
        var position: AVCaptureDevice.Position {
            switch self {
            case .front:
                return .front
            case .back:
                return .back
            }
        }
        var mirrored: Bool { return self == .front }
    }
    public var camera: Camera = .back { didSet { setupCamera() } }
    
    // MARK: - Property Helpers
    
    enum CodingKeys: String, CodingKey {
        case camera; case camRes
    }
    
    open override var uniforms: [CGFloat] {
        return [CGFloat(orientation?.rawValue ?? 0), camera.mirrored ? 1 : 0]
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
            self.flop = [.portrait, .portraitUpsideDown].contains(orientation)
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
    
    var lastUIOrientation: UIInterfaceOrientation

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, UIInterfaceOrientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(camRes: CameraPIX.CamRes, cameraPosition: AVCaptureDevice.Position, setup: @escaping (CGSize, UIInterfaceOrientation) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
        self.cameraPosition = cameraPosition
        
        setupCallback = setup
        capturedCallback = captured
        
        lastUIOrientation = UIApplication.shared.statusBarOrientation

        captureSession = AVCaptureSession()
        sessionOutput = AVCaptureVideoDataOutput()
        
        super.init()
        
        let preset: AVCaptureSession.Preset
        switch camRes {
//        case .autoLow:
//            preset = .low
//        case .autoHigh:
//            preset = .high
        case .vga:
            preset = .vga640x480
        case ._720p:
            preset = .hd1280x720
        case ._1080p:
            preset = .hd1920x1080
        case ._4K:
            preset = .hd4K3840x2160
        }
        
        if captureSession.canSetSessionPreset(preset) {
            captureSession.sessionPreset = preset
        } else {
            captureSession.sessionPreset = .high
        }
        
        sessionOutput.alwaysDiscardsLateVideoFrames = true
        sessionOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixels.colorBits.os]
        
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
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
    
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    @objc func deviceRotated() {
        if lastUIOrientation != UIApplication.shared.statusBarOrientation {
            orientationUpdated = true
        } else {
            forceDetectUIOrientation(new: {
                self.orientationUpdated = true
            })
        }
    }
    
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
        
        let uiOrientation = UIApplication.shared.statusBarOrientation
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution: CGSize
        switch uiOrientation {
        case .portrait, .portraitUpsideDown:
            resolution = CGSize(width: height, height: width)
        case .landscapeLeft, .landscapeRight:
            resolution = CGSize(width: width, height: height)
        default:
            resolution = CGSize(width: width, height: height)
            pixels.log(.warning, .resource, "Camera orientation unknown.")
        }
        
        setupCallback(resolution, uiOrientation)
        
        lastUIOrientation = uiOrientation
        
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
}

