//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-01-03.
//

#if os(macOS) && !targetEnvironment(macCatalyst)

import AVKit
import RenderKit
import Resolution
import CoreMediaIO

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
        
        /// iOS Screen Capture
        enableDalDevices()
                
        NotificationCenter.default.addObserver(self, selector: #selector(newDevice), name: NSNotification.Name.AVCaptureDeviceWasConnected, object: nil)
        newDevice()
        
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
                    PixelKit.main.logger.log(.error, .resource, "Screen can't add output.")
                }
            } else {
                PixelKit.main.logger.log(.error, .resource, "Screen can't add input.")
            }
        } else {
            PixelKit.main.logger.log(.error, .resource, "Screen not found.")
        }
        
    }
    
    
    public func enableDalDevices() {

        var property = CMIOObjectPropertyAddress(mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices), mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal), mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        var allow : UInt32 = 1
        let sizeOfAllow = MemoryLayout.size(ofValue: allow)
        CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &property, 0, nil, UInt32(sizeOfAllow), &allow)

    }
    
    var setupScreenDevice: Bool = false
    @objc func newDevice() {
        guard !setupScreenDevice else { return }
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: nil, position: .unspecified)
        guard let screenDevice = discoverySession.devices.first else { return }
        let screenInput = try! AVCaptureDeviceInput(device: screenDevice)
        if captureSession.canAddInput(screenInput) {
            captureSession.addInput(screenInput)
            if captureSession.canAddOutput(videoOutput){
                captureSession.addOutput(videoOutput)
                let queue = DispatchQueue(label: "se.hexagons.pixelKit.pix.screen.capture.queue")
                videoOutput.setSampleBufferDelegate(self, queue: queue)
                start()
            } else {
                PixelKit.main.logger.log(.error, .resource, "Screen can't add output.")
            }
        } else {
            PixelKit.main.logger.log(.error, .resource, "Screen can't add input.")
        }
        
        setupScreenDevice = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            PixelKit.main.logger.log(.error, .resource, "Camera buffer conversion failed.")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
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
