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
            print(self, "New Sample Mode: Interpolate:", interpolate)
            setNeedsRender()
        }
    }

    public var extend: MTLSamplerAddressMode = .clampToZero {
        didSet {
            sampler = HxPxE.main.makeSampler(interpolate: interpolate, extend: extend)
            print(self, "New Sample Mode: Extend:", extend)
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
    
    var needsRender = false
    
    // MARK: - Life Cycle
    
    init() {
    
        view = PIXView()
        
        if HxPxE.main.aLive {
            pipeline = HxPxE.main.makeShaderPipeline(shader)
            sampler = HxPxE.main.makeSampler(interpolate: interpolate, extend: extend)
            if allGood {
                HxPxE.main.add(pix: self)
            } else {
                print(self, "ERROR", "Not allGood...")
            }
        }
        
        view.newLayoutCallback = {
            print("CHECK view.newLayoutCallback...")
//            if self.view.superview != nil {
//                if self.wantsAutoRes {
//                    self.setNeedsRes()
//                }
//                self.setNeedsRender()
//            }
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
            if HxPxE.main.frameIndex < 10 { print(self, "WARNING", "Render:", "Already requested.") }
            return
        }
        guard resolution != nil else {
            if HxPxE.main.frameIndex < 10 { print(self, "WARNING", "Render:", "Resolution unknown.") }
            return
        }
        if let pixContent = self as? PIXContent {
            if pixContent.isResource {
                guard pixContent.contentPixelBuffer != nil else {
                    print(self, "WARNING", "Render:", "Content not loaded.")
                    return
                }
            }
        }
        if HxPxE.main.frameIndex < 10 {
            if HxPxE.main.frameIndex < 10 { print(self, "📡", "Requested Render.") }
        }
        needsRender = true
        delegate?.pixWillRender(self)
    }
    
    func didRender(texture: MTLTexture, force: Bool = false) {
        self.texture = texture
        delegate?.pixDidRender(self)
        if !force {
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
                    print("disconnect merger...") // CHECK
                }
            }
//            else if let pixInMulti = self as? PIXInMulti {
//
//            }
        }
//        if self is PIXOut {
//
//        }
    }
    
    func connectSingle(_ pixOut: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { print(self, "ERROR", "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOut]
        var pixOut = pixOut
        pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        print(self, "Connected", "Single", pixOut)
        applyRes {
            self.setNeedsRender()
        }
    }
    
    func connectMerger(_ pixOutA: PIX & PIXOutIO, _ pixOutB: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { print(self, "ERROR", "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOutA, pixOutB]
        var pixOutA = pixOutA
        var pixOutB = pixOutB
        pixOutA.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        pixOutB.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 1))
        print(self, "Connected", "Merger", pixOutA, pixOutB)
        applyRes {
            self.setNeedsRender()
        }
    }
    
    // MARK: Diconnect
    
    func disconnectSingle() {
        guard var pixInIO = self as? PIX & PIXInIO else { print(self, "ERROR", "PIXIn's Only"); return }
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
