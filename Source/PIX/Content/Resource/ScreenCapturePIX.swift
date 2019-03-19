//
//  ScreenCapturePIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import AVKit

public class ScreenCapturePIX: PIXResource {
        
    override open var shader: String { return "contentResourcePIX" }
    
    // MARK: - Private Properties
    
    var helper: ScreenCaptureHelper?
    
    // MARK: - Public Properties
    
    public var screenIndex: Int = 0 { didSet { setupScreenCapture() } }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        setupScreenCapture()
    }
    
    deinit {
        helper!.stop()
    }
    
    // MARK: Setup
    
    func setupScreenCapture() {
        helper?.stop()
        helper = ScreenCaptureHelper(screenIndex: screenIndex, setup: { _ in
            self.pixels.log(pix: self, .info, .resource, "Screen Capture setup.")
        }, captured: { pixelBuffer in
            self.pixels.log(pix: self, .info, .resource, "Screen Capture frame captured.", loop: true)
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
        })
    }
    
}

class ScreenCaptureHelper: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate/*, AVCapturePhotoCaptureDelegate*/ {
    
    let pixels = Pixels.main
    
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
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: pixels.bits.os]
        
        if screenInput != nil {
            if captureSession.canAddInput(screenInput!) {
                captureSession.addInput(screenInput!)
                if captureSession.canAddOutput(videoOutput){
                    captureSession.addOutput(videoOutput)
                    let queue = DispatchQueue(label: "se.hexagons.pixels.pix.screen.capture.queue")
                    videoOutput.setSampleBufferDelegate(self, queue: queue)
                    start()
                } else {
                    pixels.log(.error, .resource, "Screen can't add output.")
                }
            } else {
                pixels.log(.error, .resource, "Screen can't add input.")
            }
        } else {
            pixels.log(.error, .resource, "Screen not found.")
        }
        
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

