//
//  CameraPIX.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import AVKit

public class CameraPIX: PIXContent {
    
    public var camera: AVCaptureDevice.Position = .back { didSet { setupCamera() } }
    var orientation: UIInterfaceOrientation?
    
    var helper: CameraHelper?
    
    override var shaderUniforms: [Double] {
        return [Double(orientation?.rawValue ?? 0), camera == .front ? 1 : 0]
    }
    
    public init() {
        super.init(shader: "camera")
        setupCamera()
    }
    
    func setupCamera() {
        helper?.stop()
        helper = CameraHelper(camera: camera, setup: { resolution, orientation in
            // CHECK Why 2 setups on init?
//            print("CameraPIX:", "Setup:", "Resolution:", resolution, "Orientation:", orientation.rawValue)
            self.contentResolution = resolution
            self.orientation = orientation
        }, captured: { pixelBuffer in
            self.contentPixelBuffer = pixelBuffer
            self.setNeedsRender()
        })
    }
    
    deinit {
        helper!.stop()
    }
    
}

class CameraHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
//    let frame: CGRect
//    var got_res: Bool
//    var switchOrientation: Bool
    
    let cameraPosition: AVCaptureDevice.Position
    
    let captureSession: AVCaptureSession
    let sessionOutput: AVCaptureVideoDataOutput
    
    var initialFrameCaptured = false
    var deviceOrientationUpdated = false
    
//    var in_full_screen: Bool
    
    let setupCallback: (CGSize, UIInterfaceOrientation) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(camera: AVCaptureDevice.Position, setup: @escaping (CGSize, UIInterfaceOrientation) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
//        self.got_res = false
//        self.switchOrientation = false
        
        cameraPosition = camera
        
//        self.in_full_screen = false
        
        setupCallback = setup
        capturedCallback = captured

        captureSession = AVCaptureSession()
        sessionOutput = AVCaptureVideoDataOutput()
        
        super.init()
        
        captureSession.sessionPreset = .high
        
        sessionOutput.alwaysDiscardsLateVideoFrames = true
        sessionOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: HxPxE.main.bitMode.cameraPixelFormat]
        
        do {
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition)
            if device != nil {
                let input = try AVCaptureDeviceInput(device: device!)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    
                    if captureSession.canAddOutput(sessionOutput){
                        captureSession.addOutput(sessionOutput)
                        
                        let queue = DispatchQueue(label: "se.hexagons.hxpxe.pix.camera.queue")
                        sessionOutput.setSampleBufferDelegate(self, queue: queue)
                        
                        start()
                        
                    }
                    
                }
            }
            
        } catch {
//            print("exception!");
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    @objc func deviceRotated() {
        deviceOrientationUpdated = true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from
        connection: AVCaptureConnection) {
        
        let pixelBuffer: CVPixelBuffer = sampleBuffer.imageBuffer!
        
        DispatchQueue.main.async {
            
            if !self.initialFrameCaptured {
                self.setup(pixelBuffer)
                self.initialFrameCaptured = true
            } else if self.deviceOrientationUpdated {
                self.setup(pixelBuffer)
                self.deviceOrientationUpdated = false
            }
            
            self.capturedCallback(pixelBuffer)
            
        }
        
    }
    
    func setup(_ pixelBuffer: CVPixelBuffer) {
        
//        if self.metal_view?.superview != nil {
//            //                    self.metal_view!.checker_bg_view.removeFromSuperview()
//            self.metal_view!.removeFromSuperview()
//        }

//        let mirror = cameraPosition == .front
        
        let deviceOrientation = UIDevice.current.orientation
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution: CGSize
        let uiOrientation: UIInterfaceOrientation
        switch deviceOrientation {
        case .portrait:
            resolution = CGSize(width: height, height: width)
            uiOrientation = .portrait
        case .portraitUpsideDown:
            resolution = CGSize(width: height, height: width)
            uiOrientation = .portraitUpsideDown
        case .landscapeLeft:
            resolution = CGSize(width: width, height: height)
            uiOrientation = .landscapeLeft
        case .landscapeRight:
            resolution = CGSize(width: width, height: height)
            uiOrientation = .landscapeRight
        default:
            resolution = CGSize(width: height, height: width)
            uiOrientation = .portrait
            print("CAM ORIENTATION UNKNOWN")
        }
        
//        metal_view = MetalView(node: node, frame: frame, content_size: size, orientation: uiOrientation, mirror: mirror, uses_source_texture: true, fix_shader: fix_shader, draw_done: { texture in
//            draw_done(texture)
//        })
        
        setupCallback(resolution, uiOrientation)
        
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
}

