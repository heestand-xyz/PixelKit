//
//  PIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import CoreGraphics
//#if os(iOS) && targetEnvironment(simulator)
//import MetalPerformanceShadersProxy
//#else
//import Metal
//#endif
import Metal
import simd

open class PIX: Equatable {
    
    public var id = UUID()
    public var name: String?
    
    public weak var delegate: PIXDelegate?
    
    let pixelKit = PixelKit.main
    
    open var shader: String { return "" }
    
    open var liveValues: [LiveValue] { return [] }
    open var preUniforms: [CGFloat] { return [] }
    open var postUniforms: [CGFloat] { return [] }
    open var uniforms: [CGFloat] {
        var vals: [CGFloat] = []
        vals.append(contentsOf: preUniforms)
        for liveValue in liveValues {
            if let liveFloat = liveValue as? LiveFloat {
                vals.append(liveFloat.uniform)
            } else if let liveInt = liveValue as? LiveInt {
                vals.append(CGFloat(liveInt.uniform))
            } else if let liveBool = liveValue as? LiveBool {
                vals.append(liveBool.uniform ? 1.0 : 0.0)
            } else if let liveColor = liveValue as? LiveColor {
                vals.append(contentsOf: liveColor.colorCorrect.uniformList)
            } else if let livePoint = liveValue as? LivePoint {
                vals.append(contentsOf: livePoint.uniformList)
            } else if let liveSize = liveValue as? LiveSize {
                vals.append(contentsOf: liveSize.uniformList)
            }
        }
        vals.append(contentsOf: postUniforms)
        return vals
    }
    
    var liveArray: [[LiveFloat]] { return [] }
    open var uniformArray: [[CGFloat]] {
        return liveArray.map({ liveFloats -> [CGFloat] in
            return liveFloats.map({ liveFloat -> CGFloat in
                return liveFloat.uniform
            })
        })
    }

    open var vertexUniforms: [CGFloat] { return [] }
    var shaderNeedsAspect: Bool { return false }
    
    public var bypass: Bool = false {
        didSet {
            guard !bypass else { return }
            setNeedsRender()
        }
    }

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
            nextTextureAvalibleCallback?()
        }
    }
    public var didRenderTexture: Bool {
        return _texture != nil
    }
    var nextTextureAvalibleCallback: (() -> ())?
    public func nextTextureAvalible(_ callback: @escaping () -> ()) {
        nextTextureAvalibleCallback = {
            callback()
            self.nextTextureAvalibleCallback = nil
        }
    }
    
    open var additiveVertexBlending: Bool { return false }
    
    public let view: PIXView
    
    public var interpolate: InterpolateMode = .linear { didSet { updateSampler() } }
    public var extend: ExtendMode = .zero { didSet { updateSampler() } }
    public var mipmap: MTLSamplerMipFilter = .linear { didSet { updateSampler() } }
    var compare: MTLCompareFunction = .never
    
    var pipeline: MTLRenderPipelineState!
    var sampler: MTLSamplerState!
    var allGood: Bool {
        return pipeline != nil && sampler != nil
    }
    
    public var customRenderActive: Bool = false
    public var customRenderDelegate: PixelCustomRenderDelegate?
    public var customMergerRenderActive: Bool = false
    public var customMergerRenderDelegate: PixelCustomMergerRenderDelegate?
    public var customGeometryActive: Bool = false
    public var customGeometryDelegate: PixelCustomGeometryDelegate?
    open var customMetalLibrary: MTLLibrary? { return nil }
    open var customVertexShaderName: String? { return nil }
    open var customVertexTextureActive: Bool { return false }
    open var customVertexPixIn: (PIX & PIXOut)? { return nil }
    open var customMatrices: [matrix_float4x4] { return [] }
    public var customlinkedPixs: [PIX] = []

    var rendering = false
    var needsRender = false {
        didSet {
            guard needsRender else { return }
            guard pixelKit.renderMode == .direct else { return }
            pixelKit.renderPIX(self, done: { _ in })
        }
    }
    var renderIndex: Int = 0
    var contentLoaded: Bool?
    var inputTextureAvalible: Bool?

    // MARK: - Life Cycle
    
    init() {
    
        view = PIXView()
        
        setupShader()
            
        pixelKit.add(pix: self)
        
        pixelKit.log(pix: self, .detail, nil, "Linked with PixelKit.", clean: true)
    
    }
    
    func setupShader() {
        guard shader != "" else {
            pixelKit.log(pix: self, .fatal, nil, "Shader not defined.")
            return
        }
        let shaderName = contentLoaded == false || inputTextureAvalible == false ? "templatePIX" : shader
        do {
            let frag = try pixelKit.makeFrag(shaderName, with: customMetalLibrary, from: self)
            let vtx: MTLFunction? = customVertexShaderName != nil ? try pixelKit.makeVertexShader(customVertexShaderName!, with: customMetalLibrary) : nil
            pipeline = try pixelKit.makeShaderPipeline(frag, with: vtx, addMode: additiveVertexBlending)
            sampler = try pixelKit.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl, mipFilter: mipmap)
        } catch {
            pixelKit.log(pix: self, .fatal, nil, "Setup failed.", e: error)
        }
    }
    
    // MARK: Sampler
    
    func updateSampler() {
        do {
            sampler = try pixelKit.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl, mipFilter: mipmap)
            pixelKit.log(pix: self, .info, nil, "New Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)")
            setNeedsRender()
        } catch {
            pixelKit.log(pix: self, .error, nil, "Error setting new Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)", e: error)
        }
    }
    
    // MARK: - Render
    
    public func setNeedsRender() {
        guard !bypass else {
            renderOuts()
            return
        }
        guard !needsRender else {
//            pixelKit.log(pix: self, .warning, .render, "Already requested.", loop: true)
            return
        }
//        guard resolution != nil else {
//            pixelKit.log(pix: self, .warning, .render, "Resolution unknown.", loop: true)
//            return
//        }
        guard view.metalView.res != nil else {
            pixelKit.log(pix: self, .warning, .render, "Metal View res not set.", loop: true)
            pixelKit.log(pix: self, .debug, .render, "Auto applying Res...", loop: true)
            applyRes {
                self.setNeedsRender()
            }
            return
        }
        if let pixResource = self as? PIXResource {
            if pixResource.pixelBuffer != nil {
                if contentLoaded != true {
                    let wasBad = contentLoaded == false
                    contentLoaded = true
                    if wasBad {
                        setupShader()
                    }
                }
            } else {
                if contentLoaded != false {
                    contentLoaded = false
                    setupShader()
                }
                contentLoaded = false
                pixelKit.log(pix: self, .warning, .render, "Content not loaded.", loop: true)
            }
        }
        if let inPix = self as? PIXInIO {
            if inPix.pixInList.first?.texture != nil {
                let wasBad = inputTextureAvalible == false
                if inputTextureAvalible != true {
                    inputTextureAvalible = true
                    if wasBad {
                        setupShader()
                    }
                }
            } else {
                if inputTextureAvalible != false {
                    inputTextureAvalible = false
                    setupShader()
                }
            }
        }
        pixelKit.log(pix: self, .detail, .render, "Requested.", loop: true)
//        delegate?.pixWillRender(self)
        needsRender = true
    }
    
    open func didRender(texture: MTLTexture, force: Bool = false) {
        self.texture = texture
        renderIndex += 1
        delegate?.pixDidRender(self)
        if pixelKit.renderMode != .frameTree {
            for customLinkedPix in customlinkedPixs {
                customLinkedPix.setNeedsRender()
            }
            if !force { // CHECK the force!
                renderOuts()
                renderCustomVertexTexture()
            }
        }
    }
    
    func renderOuts() {
        if let pixOut = self as? PIXOutIO {
            for pixOutPath in pixOut.pixOutPathList {
//                guard let pix = pixOutPath?.pixIn else { continue }
                let pix = pixOutPath.pixIn
                guard !pix.destroyed else { continue }
                guard pix != self else {
                    pixelKit.log(.error, .render, "Connected to self.")
                    continue
                }
                pix.setNeedsRender()
            }
        }
    }
    
    func renderCustomVertexTexture() {
        for pix in pixelKit.linkedPixs {
            if pix.customVertexTextureActive {
                if let inPix = pix.customVertexPixIn {
                    if inPix == self {
                        pix.setNeedsRender()
                    }
                }
            }
        }
    }
    
    // MARK: - Out Path

    
    struct OutPath {
        var pixIn: PIX & PIXIn
        let inIndex: Int
//        init(pixIn: PIX & PIXIn, inIndex: Int) {
//            self.pixIn = pixIn
//            self.inIndex = inIndex
//        }
    }
//    class WeakOutPath {
//        weak var outPath: OutPath?
//        init(_ outPath: OutPath) {
//            self.outPath = outPath
//        }
//    }
//    struct WeakOutPaths: Collection {
//        private var weakOutPaths: [WeakOutPath] = []
//        init(_ outPaths: [OutPath]) {
//            weakOutPaths = outPaths.map { WeakOutPath($0) }
//        }
//        var startIndex: Int { return weakOutPaths.startIndex }
//        var endIndex: Int { return weakOutPaths.endIndex }
//        subscript(_ index: Int) -> OutPath? {
//            return weakOutPaths[index].outPath
//        }
//        func index(after idx: Int) -> Int {
//            return weakOutPaths.index(after: idx)
//        }
//        mutating func append(_ outPath: OutPath) {
//            weakOutPaths.append(WeakOutPath(outPath))
//        }
//        mutating func remove(_ outPath: OutPath) {
//            for (i, weakOutPath) in weakOutPaths.enumerated() {
//                if weakOutPath.outPath != nil && weakOutPath.outPath!.pixIn == outPath.pixIn {
//                    weakOutPaths.remove(at: i)
//                    break
//                }
//            }
//        }
//        mutating func remove(at index: Int) {
//            weakOutPaths.remove(at: index)
//        }
//    }
    
    // MARK: - Connect
    
    func setNeedsConnectSingle(new newInPix: (PIX & PIXOut)?, old oldInPix: (PIX & PIXOut)?) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixelKit.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        if let oldPixOut = oldInPix {
            var pixOut = oldPixOut as! (PIX & PIXOutIO)
            for (i, pixOutPath) in pixOut.pixOutPathList.enumerated() {
                if pixOutPath.pixIn == pixInIO {
                    pixOut.pixOutPathList.remove(at: i)
                    break
                }
            }
            pixInIO.pixInList = []
            pixelKit.log(pix: self, .info, .connection, "Disonnected Single: \(pixOut)")
        }
        if let newPixOut = newInPix {
            guard newPixOut != self else {
                pixelKit.log(.error, .connection, "Can't connect to self.")
                return
            }
            var pixOut = newPixOut as! (PIX & PIXOutIO)
            pixInIO.pixInList = [pixOut]
            pixOut.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
            applyRes { self.setNeedsRender() }
            pixelKit.log(pix: self, .info, .connection, "Connected Single: \(pixOut)")
        } else {
            disconnected()
        }
    }
    
    func setNeedsConnectMerger(new newInPix: (PIX & PIXOut)?, old oldInPix: (PIX & PIXOut)?, second: Bool) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixelKit.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        guard let pixInMerger = self as? PIXInMerger else { return }
        if let oldPixOut = oldInPix {
            var pixOut = oldPixOut as! (PIX & PIXOutIO)
            for (i, pixOutPath) in pixOut.pixOutPathList.enumerated() {
                if pixOutPath.pixIn == pixInIO {
                    pixOut.pixOutPathList.remove(at: i)
                    break
                }
            }
            pixInIO.pixInList = []
            pixelKit.log(pix: self, .info, .connection, "Disonnected Merger: \(pixOut)")
        }
        if let newPixOut = newInPix {
            if var pixOutA = (!second ? newPixOut : pixInMerger.inPixA) as? (PIX & PIXOutIO),
                var pixOutB = (second ? newPixOut : pixInMerger.inPixB) as? (PIX & PIXOutIO) {
                pixInIO.pixInList = [pixOutA, pixOutB]
                pixOutA.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 0))
                pixOutB.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: 1))
                applyRes { self.setNeedsRender() }
                pixelKit.log(pix: self, .info, .connection, "Connected Merger: \(pixOutA), \(pixOutB)")
            }
        } else {
            disconnected()
        }
    }
    
    func setNeedsConnectMulti(new newInPixs: [PIX & PIXOut], old oldInPixs: [PIX & PIXOut]) {
        guard var pixInIO = self as? PIX & PIXInIO else { pixelKit.log(pix: self, .error, .connection, "PIXIn's Only"); return }
        pixInIO.pixInList = newInPixs
        for oldInPix in oldInPixs {
            if var inPix = oldInPix as? (PIX & PIXOutIO) {
                for (j, pixOutPath) in inPix.pixOutPathList.enumerated() {
                    if pixOutPath.pixIn == pixInIO {
                        inPix.pixOutPathList.remove(at: j)
                        break
                    }
                }
            }
        }
        for (i, newInPix) in newInPixs.enumerated() {
            if var inPix = newInPix as? (PIX & PIXOutIO) {
                inPix.pixOutPathList.append(OutPath(pixIn: pixInIO, inIndex: i))
            }
        }
        if newInPixs.isEmpty {
            disconnected()
        }
        pixelKit.log(pix: self, .info, .connection, "Connected Multi: \(newInPixs)")
        applyRes { self.setNeedsRender() }
    }
    
    func disconnected() {
        removeRes()
    }
    
    // MARK: - Other
    
    // MARL: Custom Linking
    
    public func customLink(to pix: PIX) {
        for customLinkedPix in customlinkedPixs {
            if customLinkedPix == pix {
                return
            }
        }
        customlinkedPixs.append(pix)
    }
    
    public func customDelink(from pix: PIX) {
        for (i, customLinkedPix) in customlinkedPixs.enumerated() {
            if customLinkedPix == pix {
                customlinkedPixs.remove(at: i)
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
    
    public static func ==(lhs: PIX?, rhs: PIX) -> Bool {
        guard lhs != nil else { return false }
        return lhs!.id == rhs.id
    }
    
    public static func !=(lhs: PIX?, rhs: PIX) -> Bool {
        guard lhs != nil else { return false }
        return lhs!.id != rhs.id
    }
    
    public static func ==(lhs: PIX, rhs: PIX?) -> Bool {
        guard rhs != nil else { return false }
        return lhs.id == rhs!.id
    }
    
    public static func !=(lhs: PIX, rhs: PIX?) -> Bool {
        guard rhs != nil else { return false }
        return lhs.id != rhs!.id
    }
    
    // MARK: Live
    
    func checkLive() {
        for liveValue in liveValues {
            if liveValue.uniformIsNew {
                setNeedsRender()
                break
            }
        }
        for liveValues in liveArray {
            for liveValue in liveValues {
                if liveValue.uniformIsNew {
                    setNeedsRender()
                    break
                }
            }
        }
    }
    
    // MARK: Clean
    
    var destroyed = false
    public func destroy() {
        pixelKit.remove(pix: self)
        texture = nil
        bypass = true
        destroyed = true
    }
    
}
