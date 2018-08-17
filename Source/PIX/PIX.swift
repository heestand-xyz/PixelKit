//
//  PIX.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

public class PIX: Codable {
    
    public var delegate: PIXDelegate?
    
    var id = UUID()
    
    var shader: String { return "nilPIX" }
    var shaderUniforms: [CGFloat] { return [] }
    var shaderNeedsAspect: Bool { return false }
    
    public let view: PIXView
    
    var texture: MTLTexture?
    
    public var interpolate: MTLSamplerMinMagFilter = .linear {
        didSet {
            sampler = HxPxE.main.makeSampler(interpolate: interpolate, extend: extend)
            Logger.main.log(pix: self, .info, nil, "New Sample Mode: Interpolate: \(interpolate)")
            setNeedsRender()
        }
    }

    public var extend: MTLSamplerAddressMode = .clampToZero {
        didSet {
            sampler = HxPxE.main.makeSampler(interpolate: interpolate, extend: extend)
            Logger.main.log(pix: self, .info, nil, "New Sample Mode: Extend: \(extend)")
            setNeedsRender()
        }
    }
    
    var pipeline: MTLRenderPipelineState?
    var sampler: MTLSamplerState?
    var allGood: Bool {
        return pipeline != nil && sampler != nil
    }
    
    var customRenderActive: Bool = false
    var customRenderDelegate: CustomRenderDelegate?
    
    var rendering = false
    var needsRender = false
    
    // MARK: - Life Cycle
    
    init() {
    
        view = PIXView()
        
        if HxPxE.main.aLive {
            pipeline = HxPxE.main.makeShaderPipeline(shader)
            sampler = HxPxE.main.makeSampler(interpolate: interpolate, extend: extend)
            if allGood {
                HxPxE.main.add(pix: self)
                print(self, "Created and linked with main engine.")
            } else {
                print(self, "Not allGood...")
            }
        }
        
    }
    
    // MARK: JSON

    public required init(from decoder: Decoder) throws {
        fatalError("PIX Decoder Initializer is not supported.") // CHECK
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    // MARK: - Render
    
    func setNeedsRender() {
        guard !needsRender else {
            Logger.main.log(pix: self, .warning, .render, "Already requested.", loop: true)
            return
        }
        guard resolution != nil else {
            Logger.main.log(pix: self, .warning, .render, "Resolution unknown.", loop: true)
            return
        }
        guard view.metalView.res != nil else {
            Logger.main.log(pix: self, .warning, .render, "Metal View res not set.", loop: true)
            return
        }
        if let pixResource = self as? PIXResource {
            guard pixResource.pixelBuffer != nil else {
                Logger.main.log(pix: self, .warning, .render, "Content not loaded.", loop: true)
                return
            }
        }
        if HxPxE.main.frameIndex < 10 {
            Logger.main.log(pix: self, .info, .render, "Requested.", loop: true)
        }
        needsRender = true
        delegate?.pixWillRender(self)
    }
    
    func didRender(texture: MTLTexture, force: Bool = false) {
        self.texture = texture
        delegate?.pixDidRender(self)
        if !force { // CHECK the force!
            if let pixOut = self as? PIXOutIO {
                for pixOutPath in pixOut.pixOutPathList {
                    pixOutPath.pixIn.setNeedsRender()
                }
            }
        }
    }
    
    // MARK: - Connect
    
    struct OutPath {
        let pixIn: PIX & PIXIn
        let inIndex: Int
    }
    
    func setNeedsConnect() {
        if self is PIXIn {
            if var pixInSingle = self as? PIXInSingle {
                if pixInSingle.inPix != nil {
                    connectSingle(pixInSingle.inPix! as! PIX & PIXOutIO)
                } else {
                    disconnectSingle()
                }
            } else if let pixInMerger = self as? PIXInMerger {
                if pixInMerger.inPixA != nil && pixInMerger.inPixB != nil {
                    connectMerger(pixInMerger.inPixA! as! PIX & PIXOutIO, pixInMerger.inPixB! as! PIX & PIXOutIO)
                } else {
                    // CHECK disconnect
                }
            } else if let pixInMulti = self as? PIXInMulti {
                connectMulti(pixInMulti.inPixs as! [PIX & PIXOutIO])
            }
        }
    }
    
    func connectSingle(_ pixOut: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { Logger.main.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOut]
        var pixOut = pixOut
        pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        Logger.main.log(pix: self, .info, .connection, "Connected Single: \(pixOut)")
        applyRes { self.setNeedsRender() }
    }
    
    func connectMerger(_ pixOutA: PIX & PIXOutIO, _ pixOutB: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { Logger.main.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOutA, pixOutB]
        var pixOutA = pixOutA
        var pixOutB = pixOutB
        pixOutA.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        pixOutB.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 1))
        Logger.main.log(pix: self, .info, .connection, "Connected Merger: \(pixOutA), \(pixOutB)")
        applyRes { self.setNeedsRender() }
    }
    
    func connectMulti(_ pixOuts: [PIX & PIXOutIO]) {
        guard var pixInIO = self as? PIX & PIXInIO else { Logger.main.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = pixOuts
        for (i, pixOut) in pixOuts.enumerated() {
            var pixOut = pixOut
            pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: i)) // CHECK override
        }
        Logger.main.log(pix: self, .info, .connection, "Connected Multi: \(pixOuts)")
        applyRes { self.setNeedsRender() }
    }
    
    // MARK: Diconnect
    
    func disconnectSingle() {
        guard var pixInIO = self as? PIX & PIXInIO else { Logger.main.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        var pixOut = pixInIO.pixInList.first! as! PIXOutIO
        for (i, pixOutPath) in pixOut.pixOutPathList.enumerated() {
            if pixOutPath.pixIn == pixInIO {
                pixOut.pixOutPathList.remove(at: i)
                break
            }
        }
        pixInIO.pixInList = []
        // CHECK Reset Res
//        view.setResolution(nil)
    }
    
    // MARK: - Other
    
    // MARK: Operator Overloading
    
    static func ==(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func !=(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id != rhs.id
    }
    
    // MARK: Clean
    
    deinit {
        // CHECK
        HxPxE.main.remove(pix: self)
        // Disconnect...
    }
    
}
