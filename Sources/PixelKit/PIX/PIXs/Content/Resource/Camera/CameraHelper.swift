//
//  Created by Anton Heestand on 2021-09-23.
//

import Foundation

import RenderKit
import Resolution
import AVKit
#if canImport(SwiftUI)
import SwiftUI
#endif
import PixelColor

#if !os(tvOS)

// MARK: - Camera Helper

@available(macCatalyst 14.0, *)
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

    var lastUIOrientation: _Orientation?

    var initialFrameCaptured = false
    var orientationUpdated = false
    
    let setupCallback: (CGSize, _Orientation?) -> ()
    let capturedCallback: (CVPixelBuffer) -> ()
    let capturedDepthCallback: (CVPixelBuffer) -> ()
    let capturedMultiCallback: (Int, CVPixelBuffer) -> ()
    let capturedSampleBuffer: (CMSampleBuffer) -> ()
    
    var presentedDownstreamPix: () -> (PIX?)
    
    #if os(iOS)
    var window: UIWindow? {
        presentedDownstreamPix()?.view.window
    }
    #endif

    init(cameraResolution: CameraPIX.CameraResolution,
         cameraPosition: AVCaptureDevice.Position,
         tele: Bool = false,
         ultraWide: Bool = false,
         depth: Bool = false,
         filterDepth: Bool,
         multiCameras: [CameraPIX.Camera]?,
         useExternalCamera: Bool = false,
         useCenterStage: Bool = false,
         presentedDownstreamPix: @escaping () -> (PIX?),
         setup: @escaping (CGSize, _Orientation?) -> (),
         clear: @escaping () -> (),
         captured: @escaping (CVPixelBuffer) -> (),
         capturedDepth: @escaping (CVPixelBuffer) -> (),
         capturedMulti: @escaping (Int, CVPixelBuffer) -> (),
         capturedSampleBuffer: @escaping (CMSampleBuffer) -> ()) {
        
        self.presentedDownstreamPix = presentedDownstreamPix
        
        self.capturedSampleBuffer = capturedSampleBuffer
        
        var multi: Bool = false
        
        if #available(iOS 14.5, macOS 12.3, *) {
            PixelKit.main.logger.log(.warning, .resource, "Camera Center Stage (mode: \(AVCaptureDevice.centerStageControlMode), active: \(device?.isCenterStageActive ?? false), enabled: \(AVCaptureDevice.isCenterStageEnabled))")
            if useCenterStage {
                AVCaptureDevice.centerStageControlMode = .app
            }
            AVCaptureDevice.isCenterStageEnabled = useCenterStage
        }
        
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
                    PixelKit.main.logger.log(.warning, .resource, "Ultra Wide Camera is only available in iOS 13.")
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
            PixelKit.main.logger.log(.info, .resource, "Camera \"\(deviceType.rawValue)\" Setup.")
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
        
        let defaultDevice = AVCaptureDevice.default(for: .video)
        if !useExternalCamera {
            device = defaultDevice
        } else {
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .video, position: .unspecified)
            for iDevice in discoverySession.devices {
                guard iDevice != defaultDevice else { continue }
                guard iDevice.hasMediaType(.video) else { continue }
                device = iDevice
                break
            }
            if device == nil {
                PixelKit.main.logger.log(.warning, .view, "External Camera Not Found")
                clear()
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
        
//        #if os(iOS) && !targetEnvironment(macCatalyst)
//        if let interfaceOrientation: UIInterfaceOrientation = presentedDownstreamPix()?.view.window?.windowScene?.interfaceOrientation {
//            lastUIOrientation = interfaceOrientation
//        } else {
//            PixelKit.main.logger.log(.warning, .view, "Interface Orientation for Camera Not Found")
//            lastUIOrientation = .portrait
//        }
//        #elseif os(macOS) || targetEnvironment(macCatalyst)
//        lastUIOrientation = ()
//        #endif
        
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
                PixelKit.main.logger.log(.error, nil, "Camera device not found.")
                return
            }
        }
        
        if !multi {
            let preset: AVCaptureSession.Preset = depth ? .vga640x480 : cameraResolution.sessionPreset
            if captureSession.canSetSessionPreset(preset) {
                captureSession.sessionPreset = preset
                PixelKit.main.logger.log(.info, nil, "Camera preset set to: \(preset)")
            } else if captureSession.canSetSessionPreset(.high) {
                PixelKit.main.logger.log(.warning, nil, "Default camera preset (\(preset)) can't be added. Defaulting to .high.")
                captureSession.sessionPreset = .high
            } else if captureSession.canSetSessionPreset(.medium) {
                PixelKit.main.logger.log(.warning, nil, "Camera preset .high can't be added. Defaulting to .medium.")
                captureSession.sessionPreset = .medium
            } else if captureSession.canSetSessionPreset(.low) {
                PixelKit.main.logger.log(.warning, nil, "Camera preset .medium can't be added. Defaulting to .low.")
                captureSession.sessionPreset = .low
            } else {
                PixelKit.main.logger.log(.error, nil, "No good camera preset found found.")
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
//                            PixelKit.main.logger.log(.error, nil, "Camera Device configuration failed for \"\(multiDevice.deviceType.rawValue)\".")
//                        }
//                    } else {
//                        PixelKit.main.logger.log(.error, nil, "CameraResolution not supported for \"\(multiDevice.deviceType.rawValue)\".")
//                    }
//                }
//            }
        }

        PixelKit.main.logger.log(.info, .resource, "Camera Active Format: \(device?.activeFormat.description ?? "nil")")
        
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
//                PixelKit.main.logger.log(.info, nil, "Camera device final format set to: \(format.description) fps: \(fps)")
//            } catch {
//                PixelKit.main.logger.log(.error, nil, "Camera device final format fail", e: error)
//                return
//            }
//        }
        
        if !multi {
            videoOutput!.alwaysDiscardsLateVideoFrames = true
            videoOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: PixelKit.main.render.bits.os]
        } else {
            #if os(iOS)
            multiVideoOutputs.forEach { multiVideoOutput in
                multiVideoOutput.alwaysDiscardsLateVideoFrames = true
                multiVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: PixelKit.main.render.bits.os]
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
                    PixelKit.main.logger.log(.error, .resource, "Camera can't add input.")
                    return
                }
                captureSession.addInput(input)
                guard captureSession.canAddOutput(videoOutput!) else {
                    PixelKit.main.logger.log(.error, .resource, "Camera can't add output.")
                    return
                }
                captureSession.addOutput(videoOutput!)
            } else {
                #if os(iOS)
                try multiDevices.forEach { multiDevice in
                    let input = try AVCaptureDeviceInput(device: multiDevice)
                    guard captureSession.canAddInput(input) else {
                        PixelKit.main.logger.log(.error, .resource, "Camera can't add multi input.")
                        return
                    }
                    captureSession.addInput(input)
                }
                multiVideoOutputs.forEach { multiVideoOutput in
                    guard captureSession.canAddOutput(multiVideoOutput) else {
                        PixelKit.main.logger.log(.error, .resource, "Camera can't add multi output.")
                        return
                    }
                    captureSession.addOutput(multiVideoOutput)
                }
                #endif
            }
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if depth {
//                #warning("Add support for LiDAR Cameras")
//                guard cameraPosition == .front && UIDevice.current.userInterfaceIdiom == .phone else {
//                    PixelKit.main.logger.log(.error, .resource, "Camera can't add depth output on back camera or iPad (right now).")
//                    return
//                }
                guard captureSession.canAddOutput(depthOutput!) else {
                    PixelKit.main.logger.log(.error, .resource, "Camera can't add depth output.")
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
            PixelKit.main.logger.log(.error, .resource, "Camera input failed to load.", e: error)
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
        guard let orientation: UIInterfaceOrientation = window?.windowScene?.interfaceOrientation else {
            PixelKit.main.logger.log(.warning, .view, "Interface Orientation for CameraPIX Not Found")
            return
        }
        if lastUIOrientation != orientation {
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
        let forceCount = PixelKit.main.render.fpsMax * 2
        var forceIndex = 0
        let forceTimer = Timer(timeInterval: 1 / Double(PixelKit.main.render.fpsMax), repeats: true, block: { [weak self] timer in
            guard let orientation: UIInterfaceOrientation = self?.window?.windowScene?.interfaceOrientation else {
                PixelKit.main.logger.log(.warning, .view, "Interface Orientation for CameraPIX Not Found")
                return
            }
            if self?.lastUIOrientation != orientation {
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
        
//        PixelKit.main.logger.log(.info, .resource, "--> Captured Output.")
        
//        capturedSampleBuffer(sampleBuffer)
        
        guard !bypass else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            PixelKit.main.logger.log(.error, .resource, "Camera buffer conversion failed.")
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
        var _orientation: UIInterfaceOrientation?
        if let orientation: UIInterfaceOrientation = window?.windowScene?.interfaceOrientation {
            _orientation = orientation
        } else {
            PixelKit.main.logger.log(.warning, .view, "Interface Orientation for CameraPIX Not Found")
        }
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        let _orientation: Void? = nil
        #endif
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var resolution: CGSize = CGSize(width: width, height: height)
        #if os(iOS) && !targetEnvironment(macCatalyst)
        if let _orientation = _orientation {
            switch _orientation {
            case .portrait, .portraitUpsideDown:
                resolution = CGSize(width: height, height: width)
            case .landscapeLeft, .landscapeRight:
                resolution = CGSize(width: width, height: height)
            default:
                resolution = CGSize(width: width, height: height)
                PixelKit.main.logger.log(.warning, .resource, "Camera orientation unknown.")
            }
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
        PixelKit.main.logger.log(.info, .resource, "Manual Exposure active:\(active)")
        do {
            try device?.lockForConfiguration()
            device?.exposureMode = active ? .custom : .continuousAutoExposure
            device?.unlockForConfiguration()
        } catch {
            PixelKit.main.logger.log(.error, .resource, "Camera custom setting (exposureMode) failed.", e: error)
        }
    }
    
    func manualFocus(_ active: Bool) {
        PixelKit.main.logger.log(.info, .resource, "Manual Focus active:\(active)")
        guard device?.isFocusModeSupported(.locked) == true else {
            PixelKit.main.logger.log(.info, .resource, "Manual Focus - Failed - Not Supported")
            return
        }
        do {
            try device?.lockForConfiguration()
            device?.focusMode = active ? .locked : .continuousAutoFocus
            device?.unlockForConfiguration()
        } catch {
            PixelKit.main.logger.log(.error, .resource, "Camera custom setting (focusMode) failed.", e: error)
        }
    }
    
    func manualWhiteBalance(_ active: Bool) {
        PixelKit.main.logger.log(.info, .resource, "Manual White Balance active:\(active)")
        do {
            try device?.lockForConfiguration()
            device?.whiteBalanceMode = active ? .locked : .continuousAutoWhiteBalance
            device?.unlockForConfiguration()
        } catch {
            PixelKit.main.logger.log(.error, .resource, "Camera custom setting (whiteBalanceMode) failed.", e: error)
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
        PixelKit.main.logger.log(.info, .resource, "Camera Light exposure:\(exposure) iso:\(iso)")
        guard let device = device else {
            PixelKit.main.logger.log(.warning, .resource, "Camera Light - Failed - Device is nil")
            return
        }
        let clampedExposure = min(max(exposure, minExposure ?? 0.0), maxExposure ?? 1.0)
        let clampedIso = min(max(iso, minISO ?? 0), maxISO ?? 1000)
        do {
            try device.lockForConfiguration()
            device.setExposureModeCustom(duration: CMTime(seconds: Double(clampedExposure), preferredTimescale: CMTimeScale(NSEC_PER_SEC)), iso: Float(clampedIso))
            device.unlockForConfiguration()
        } catch {
            PixelKit.main.logger.log(.error, .resource, "Camera Light - Failed with Error", e: error)
        }
    }
    func setTorch(_ value: CGFloat) {
        PixelKit.main.logger.log(.info, .resource, "Camera Torch \(value)")
        guard let device = device else {
            PixelKit.main.logger.log(.warning, .resource, "Camera Torch - Failed - Device is nil")
            return
        }
        let level: Float = Float(min(max(value, 0.0), 1.0))
        if level > 0.0 {
            guard device.isTorchModeSupported(.on) else {
                PixelKit.main.logger.log(.warning, .resource, "Camera Torch - Failed - Not ON Supported")
                return
            }
        } else {
            guard device.isTorchModeSupported(.off) else {
                PixelKit.main.logger.log(.warning, .resource, "Camera Torch - Failed - Not OFF Supported")
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
            PixelKit.main.logger.log(.error, .resource, "Camera Torch - Failed with Error", e: error)
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
//            PixelKit.main.logger.log(.warning, .resource, "Photo Capture not enabled.")
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
        
//        PixelKit.main.logger.log(.info, .resource, "--> Captured Depth Output.")
        
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
    
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        guard !depthProcessing else {
            PixelKit.main.logger.log(.error, .resource, "Camera depth processing, skipped frame.")
            return
        }
        depthProcessing = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            guard let rawImageData: AVCaptureSynchronizedData = synchronizedDataCollection.synchronizedData(for: self.videoOutput!) else {
                PixelKit.main.logger.log(.error, .resource, "Camera image data not found.")
                self.depthProcessing = false
                return
            }
            guard let rawDepthData: AVCaptureSynchronizedData = synchronizedDataCollection.synchronizedData(for: self.depthOutput!) else {
                PixelKit.main.logger.log(.error, .resource, "Camera depth data not found.")
                self.depthProcessing = false
                return
            }
            
            guard let sampleBuffer = (rawImageData as? AVCaptureSynchronizedSampleBufferData)?.sampleBuffer else {
                PixelKit.main.logger.log(.error, .resource, "Camera image data in bad format.")
                self.depthProcessing = false
                return
            }
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                PixelKit.main.logger.log(.error, .resource, "Camera image data could not be converted.")
                self.depthProcessing = false
                return
            }
            
            guard let depthData = (rawDepthData as? AVCaptureSynchronizedDepthData)?.depthData else {
                PixelKit.main.logger.log(.error, .resource, "Camera depth data in bad format.")
                self.depthProcessing = false
                return
            }
            let depthPixelBuffer = depthData.depthDataMap
            
//            guard let rotatedDepthPixelBuffer = Texture.rotate90(pixelBuffer: depthPixelBuffer, factor: 3) else {
//                PixelKit.main.logger.log(.error, .resource, "Camera depth image rotation failed.")
//                depthProcessing = false
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
