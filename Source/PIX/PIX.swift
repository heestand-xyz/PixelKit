//
//  PIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

open class PIX: Codable {
    
    public var id = UUID()
    public var name: String?
    
    public weak var delegate: PIXDelegate?
    
    let pixels = Pixels.main
    
    open var shader: String { return "" }
    open var uniforms: [CGFloat] { return [] }
    open var vertexUniforms: [CGFloat] { return [] }
    var shaderNeedsAspect: Bool { return false }
    
    public var bypass: Bool = false

    var _texture: MTLTexture?
    var texture: MTLTexture? {
        get {
            guard !bypass else {
                guard let inPix = self as? PIXInIO else { return nil }
                return inPix.pixInList.first?.texture
            }
            return _texture
        }
        set {
            _texture = newValue
        }
    }
    public var didRenderTexture: Bool {
        return _texture != nil
    }
    
    public let view: PIXView
    
    public var interpolate: InterpolateMode = .linear { didSet { updateSampler() } }
    public var extend: ExtendMode = .zero { didSet { updateSampler() } }
    var compare: MTLCompareFunction = .never
    
    var pipeline: MTLRenderPipelineState!
    var sampler: MTLSamplerState!
    var allGood: Bool {
        return pipeline != nil && sampler != nil
    }
    
    public var customRenderActive: Bool = false
    public var customRenderDelegate: PixelsCustomRenderDelegate?
    public var customGeometryActive: Bool = false
    public var customGeometryDelegate: PixelsCustomGeometryDelegate?
    open var customMetalLibrary: MTLLibrary? { return nil }
    open var customVertexShaderName: String? { return nil }
    open var customVertexTextureActive: Bool { return false }
    open var customVertexPixIn: (PIX & PIXOut)? { return nil }
    public var customLinkedPixs: [PIX] = []

    var rendering = false
    var needsRender = false {
        didSet {
            guard needsRender else { return }
            guard pixels.renderMode == .direct else { return }
            pixels.renderPIX(self)
        }
    }
    
    // MARK: - Life Cycle
    
    init() {
    
        view = PIXView()
        
        guard shader != "" else {
            pixels.log(pix: self, .fatal, nil, "Shader not defined.")
            return
        }
        do {
            let frag = try pixels.makeFrag(shader, with: customMetalLibrary, from: self)
            let vtx: MTLFunction? = customVertexShaderName != nil ? try pixels.makeVertexShader(customVertexShaderName!, with: customMetalLibrary) : nil
            pipeline = try pixels.makeShaderPipeline(frag, with: vtx)
            sampler = try pixels.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl)
        } catch {
            pixels.log(pix: self, .fatal, nil, "Initialization faled.", e: error)
        }
            
        pixels.add(pix: self)
        
        pixels.log(pix: self, .info, nil, "Linked with Pixels.", clean: true)
    
    }
    
    // MARK: - JSON

    public required init(from decoder: Decoder) throws {
        fatalError("PIX Decoder Initializer is not supported.") // CHECK
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    // MARK: Sampler
    
    func updateSampler() {
        do {
            sampler = try pixels.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl)
            pixels.log(pix: self, .info, nil, "New Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)")
            setNeedsRender()
        } catch {
            pixels.log(pix: self, .error, nil, "Error setting new Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)", e: error)
        }
    }
    
    // MARK: - Render
    
    public func setNeedsRender() {
        guard !bypass else {
            renderOuts()
            return
        }
        guard !needsRender else {
            pixels.log(pix: self, .warning, .render, "Already requested.", loop: true)
            return
        }
        guard resolution != nil else {
            pixels.log(pix: self, .warning, .render, "Resolution unknown.", loop: true)
            return
        }
        guard view.metalView.res != nil else {
            pixels.log(pix: self, .warning, .render, "Metal View res not set.", loop: true)
            pixels.log(pix: self, .debug, .render, "Auto applying Res...", loop: true)
            applyRes {
                self.setNeedsRender()
            }
            return
        }
        if let pixResource = self as? PIXResource {
            guard pixResource.pixelBuffer != nil else {
                pixels.log(pix: self, .warning, .render, "Content not loaded.", loop: true)
                return
            }
        }
        pixels.log(pix: self, .info, .render, "Requested.", loop: true)
//        delegate?.pixWillRender(self)
        needsRender = true
    }
    
    open func didRender(texture: MTLTexture, force: Bool = false) {
        self.texture = texture
        delegate?.pixDidRender(self)
        for customLinkedPix in customLinkedPixs {
            customLinkedPix.setNeedsRender()
        }
        if !force { // CHECK the force!
            renderOuts()
        }
    }
    
    func renderOuts() {
        if let pixOut = self as? PIXOutIO {
            for pixOutPath in pixOut.pixOutPathList {
                let pix = pixOutPath.pixIn
                guard !pix.destroyed else { continue }
                pix.setNeedsRender()
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
                    // CHECK DISCONNECT
                }
            } else if let pixInMulti = self as? PIXInMulti {
                connectMulti(pixInMulti.inPixs as! [PIX & PIXOutIO])
            }
        }
    }
    
    func connectSingle(_ pixOut: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixels.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOut]
        var pixOut = pixOut
        pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        pixels.log(pix: self, .info, .connection, "Connected Single: \(pixOut)")
        applyRes { self.setNeedsRender() }
    }
    
    func connectMerger(_ pixOutA: PIX & PIXOutIO, _ pixOutB: PIX & PIXOutIO) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixels.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = [pixOutA, pixOutB]
        var pixOutA = pixOutA
        var pixOutB = pixOutB
        pixOutA.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
        pixOutB.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 1))
        pixels.log(pix: self, .info, .connection, "Connected Merger: \(pixOutA), \(pixOutB)")
        applyRes { self.setNeedsRender() }
    }
    
    func connectMulti(_ pixOuts: [PIX & PIXOutIO]) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixels.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = pixOuts
        for (i, pixOut) in pixOuts.enumerated() {
            var pixOut = pixOut
            pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: i)) // CHECK override
        }
        pixels.log(pix: self, .info, .connection, "Connected Multi: \(pixOuts)")
        applyRes { self.setNeedsRender() }
    }
    
    // MARK: Diconnect
    
    func disconnectSingle() {
        guard var pixInIO = self as? PIX & PIXInIO else { pixels.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        var pixOut = pixInIO.pixInList.first! as! PIXOutIO
        for (i, pixOutPath) in pixOut.pixOutPathList.enumerated() {
            if pixOutPath.pixIn == pixInIO {
                pixOut.pixOutPathList.remove(at: i)
                break
            }
        }
        pixInIO.pixInList = []
//        view.setResolution(nil)
    }
    
    // MARK: - Other
    
    // MARL: Custom Linking
    
    public func customLink(to pix: PIX) {
        for customLinkedPix in customLinkedPixs {
            if customLinkedPix == pix {
                return
            }
        }
        customLinkedPixs.append(pix)
    }
    
    public func customDelink(from pix: PIX) {
        for (i, customLinkedPix) in customLinkedPixs.enumerated() {
            if customLinkedPix == pix {
                customLinkedPixs.remove(at: i)
                return
            }
        }
    }
    
    // MARK: Operator Overloading
    
    public static func ==(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func !=(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id != rhs.id
    }
    
    // MARK: Clean
    
    var destroyed = false
    public func destroy() {
        pixels.remove(pix: self)
        texture = nil
        destroyed = true
    }
    
    deinit {
        // CHECK retain count...
        pixels.remove(pix: self)
        // Disconnect...
    }
    
}
