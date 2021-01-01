//
//  NDIPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-20.
//  Copyright © 2020 Hexagons. All rights reserved.
//

// NDI v4
// https://github.com/lizhming/NDI-recording-swift

import RenderKit


public protocol NDIPIXDelegate {
    func ndiPIXUpdated(sources: [String])
}

// FIXME: - iOS is excluded from Pods
// https://github.com/nariakiiwatani/ofxNDI
// Receivers on mobile OS won't work because they are not supported by SDK currently.

//public class NDIPIX: PIXResource {
//
//    public var ndiDelegate: NDIPIXDelegate? {
//        didSet {
//            if !ndiSources.isEmpty {
//                ndiDelegate?.ndiPIXUpdated(sources: ndiSources)
//            }
//        }
//    }
//
//    override open var shaderName: String { return "contentResourcePIX" }
////    #if os(iOS) || os(tvOS)
////    override open var shaderName: String { return "contentResourceFlipPIX" }
////    #elseif os(macOS)
////    override open var shaderName: String { return "contentResourceBGRPIX" }
////    #endif
//
//    // MARK: - Private Properties
//
//    let ndi: NDIWrapper
//
//    var ndiProcessing: Bool = false
//
//    var ndiResolution: Resolution? {
//        guard ndiCapturing else { return nil }
//        return .custom(w: Int(ndi.width), h: Int(ndi.height))
//    }
//
//    // MARK: - Public Properties
//
//    public var ndiSources: [String] = [] {
//        didSet {
//            if ndiSources != oldValue {
//                ndiDelegate?.ndiPIXUpdated(sources: ndiSources)
//            }
//        }
//    }
//    public var ndiSource: String? {
//        didSet {
//            if let source: String = ndiSource {
//                ndiConnect(to: source)
//            } else {
//                ndiDisconnect()
//            }
//        }
//    }
//
//    public var ndiCapturing: Bool = false
//
//    // MARK: - Life Cycle
//
//    public override init() {
//        ndi = NDIWrapper()
//        ndi.initWrapper()
//        super.init()
//        name = "NDI"
//        ndiUpdate()
//        PixelKit.main.render.listenToFrames { [weak self] in
//            guard let self = self else { return }
//            self.ndiUpdate()
//            guard self.ndiCapturing else { return }
//            guard !self.ndiProcessing else { return }
//            self.setNeedsBuffer()
//        }
//    }
//
//    // MARK: - NDI Update
//
//    func ndiUpdate() {
//        guard let sources: [String] = ndi.getNDISources() as? [String] else { return }
//        ndiSources = sources
//        if let source = ndiSource {
//            if !sources.contains(source) {
//                ndiSource = nil
//            }
//        }
//    }
//
//    // MARK: - NDI Connecton
//
//    public func connect(to soruce: String) {
//        ndiSource = soruce
//    }
//
//    func ndiConnect(to source: String) {
//        ndi.startCapture(source)
//        ndiCapturing = true
//        self.pixelKit.logger.log(node: self, .info, .resource, "NDI Connected to \(source).", loop: true)
//    }
//
//    func ndiDisconnect() {
//        ndi.stopCapture()
//        pixelBuffer = nil
//        ndiCapturing = false
//        self.pixelKit.logger.log(node: self, .info, .resource, "NDI Disconnected.", loop: true)
//    }
//
//    // MARK: Buffer
//
//    func setNeedsBuffer() {
//        ndiProcessing = true
//        DispatchQueue.global(qos: .background).async {
//            var pixelBuffer : CVPixelBuffer! = nil
//            guard let outPtr: UnsafeMutablePointer<UInt8> = self.ndi.getVideoFrame() else {
//                self.pixelKit.logger.log(.error, .resource, "NDI Captured Frame Failed - Video Frame is nil.", loop: true)
//                self.ndiProcessing = false
//                return
//            }
//            guard let resolution: Resolution = self.ndiResolution else {
//                self.pixelKit.logger.log(.error, .resource, "NDI Captured Frame Failed - Resolution is nil.", loop: true)
//                self.ndiProcessing = false
//                return
//            }
//            let count: Int = resolution.count
//            let bytesPerRow: Int = resolution.w * 2
//            let ptr = UnsafeBufferPointer(start: outPtr, count: 2 * count)
//            let pixelBufferAttributes = [
//                kCVPixelBufferCGImageCompatibilityKey: true,
//                kCVPixelBufferCGBitmapContextCompatibilityKey: true
//            ]
//            _ = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, resolution.w, resolution.h, kCVPixelFormatType_422YpCbCr8, UnsafeMutableRawPointer(mutating: ptr.baseAddress!), bytesPerRow, nil, nil, pixelBufferAttributes as CFDictionary, &pixelBuffer)
//            guard pixelBuffer != nil else {
//                self.pixelKit.logger.log(.error, .resource, "NDI Captured Frame Failed - Pixel Buffer is nil.", loop: true)
//                self.ndiProcessing = false
//                return
//            }
//            DispatchQueue.main.async {
//                self.ndiProcessing = false
//                self.pixelBuffer = pixelBuffer
//                self.pixelKit.logger.log(node: self, .info, .resource, "NDI Frame Captured.", loop: true)
//                self.applyResolution { self.setNeedsRender() }
//            }
//        }
//    }
//
//}
