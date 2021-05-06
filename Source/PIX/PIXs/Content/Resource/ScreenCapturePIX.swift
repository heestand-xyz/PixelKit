//
//  ScreenCapturePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

#if os(macOS) && !targetEnvironment(macCatalyst)

import AVKit

final public class ScreenCapturePIX: PIXResource, PIXViewable {
        
    override public var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Private Properties
    
    var helper: ScreenCaptureHelper?
    
    // MARK: - Public Properties
    
    public var screenIndex: Int = 0 { didSet { setupScreenCapture() } }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Screen Capture", typeName: "pix-content-resource-screen-capture")
        setupScreenCapture()
    }
    
    deinit {
        helper!.stop()
    }
    
    // MARK: Setup
    
    func setupScreenCapture() {
        helper?.stop()
        helper = ScreenCaptureHelper(screenIndex: screenIndex, setup: { _ in
            self.pixelKit.logger.log(node: self, .info, .resource, "Screen Capture setup.")
        }, captured: { pixelBuffer in
            self.pixelKit.logger.log(node: self, .info, .resource, "Screen Capture frame captured.", loop: true)
            self.resourcePixelBuffer = pixelBuffer
            if self.view.resolution == nil || self.view.resolution! != self.finalResolution {
                self.applyResolution { self.render() }
            } else {
                self.render()
            }
        })
    }
    
}

class ScreenCaptureHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate/*, AVCapturePhotoCaptureDelegate*/ {
    
    let pixelKit = PixelKit.main
    
    var screenInput: AVCaptureScreenInput?
    
    let captureSession: AVCaptureSession
    let videoOutput: AVCaptureVideoDataOutput
//    let photoOutput: AVCapturePhotoOutput?

    var initialFrameCaptured = false
    
    let setupCallback: (CGSize) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    
    init(screenIndex: Int, setup: @escaping (CGSize) -> (), captured: @escaping (CVPixelBuffer) -> ()) {
        
        let id = NSScreen.screens[screenIndex].deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as! CGDirectDisplayID
        screenInput = AVCaptureScreenInput(displayID: id)
        
        setupCallback = setup
        capturedCallback = captured
        
        captureSession = AVCaptureSession()
        videoOutput = AVCaptureVideoDataOutput()
        
        
        super.init()
        
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixelKit.render.bits.os]
        
        if screenInput != nil {
            if captureSession.canAddInput(screenInput!) {
                captureSession.addInput(screenInput!)
                if captureSession.canAddOutput(videoOutput){
                    captureSession.addOutput(videoOutput)
                    let queue = DispatchQueue(label: "se.hexagons.pixelKit.pix.screen.capture.queue")
                    videoOutput.setSampleBufferDelegate(self, queue: queue)
                    start()
                } else {
                    pixelKit.logger.log(.error, .resource, "Screen can't add output.")
                }
            } else {
                pixelKit.logger.log(.error, .resource, "Screen can't add input.")
            }
        } else {
            pixelKit.logger.log(.error, .resource, "Screen not found.")
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            pixelKit.logger.log(.error, .resource, "Camera buffer conversion failed.")
            return
        }
        
        DispatchQueue.main.async {
            
            if !self.initialFrameCaptured {
                self.setup(pixelBuffer)
                self.initialFrameCaptured = true
            }
            
            self.capturedCallback(pixelBuffer)
            
        }
        
    }
    
    func setup(_ pixelBuffer: CVPixelBuffer) {
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        let resolution = CGSize(width: width, height: height)
        
        setupCallback(resolution)
        
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }

}

#endif
