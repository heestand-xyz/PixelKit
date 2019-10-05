//
//  PIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-20.
//  Open Source - MIT License
//

import RenderKit
import LiveValues
import RenderKit
import CoreGraphics
import Metal
import simd

open class PIX: NODE {
    
    public var id = UUID()
    public var name: String?
    
    public weak var delegate: NODEDelegate?
    
    let pixelKit = PixelKit.main
    
    open var shaderName: String { return "" }
    
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
            } else if let liveRect = liveValue as? LiveRect {
                vals.append(contentsOf: liveRect.uniformList)
            } else if let liveVec = liveValue as? LiveVec {
                vals.append(contentsOf: liveVec.uniformList)
            }
        }
        vals.append(contentsOf: postUniforms)
        return vals
    }
    
    public var liveArray: [[LiveFloat]] { return [] }
    open var uniformArray: [[CGFloat]] {
        return liveArray.map({ liveFloats -> [CGFloat] in
            return liveFloats.map({ liveFloat -> CGFloat in
                return liveFloat.uniform
            })
        })
    }

    open var vertexUniforms: [CGFloat] { return [] }
    public var shaderNeedsAspect: Bool { return false }
    
    public var bypass: Bool = false {
        didSet {
            guard !bypass || self is PIXGenerator else { return }
            setNeedsRender()
        }
    }

    var _texture: MTLTexture?
    public var texture: MTLTexture? {
        get {
            guard !bypass else {
                guard let input = self as? NODEInIO else { return nil }
                return input.inputList.first?.texture
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
    
    public let pixView: PIXView
    public var view: NODEView { pixView }

    public var interpolate: InterpolateMode = .linear { didSet { updateSampler() } }
    public var extend: ExtendMode = .zero { didSet { updateSampler() } }
    public var mipmap: MTLSamplerMipFilter = .linear { didSet { updateSampler() } }
    var compare: MTLCompareFunction = .never
    
    public var pipeline: MTLRenderPipelineState!
    public var sampler: MTLSamplerState!
    var allGood: Bool {
        return pipeline != nil && sampler != nil
    }
    
    public var customRenderActive: Bool = false
    public var customRenderDelegate: CustomRenderDelegate?
    public var customMergerRenderActive: Bool = false
    public var customMergerRenderDelegate: CustomMergerRenderDelegate?
    public var customGeometryActive: Bool = false
    public var customGeometryDelegate: CustomGeometryDelegate?
    open var customMetalLibrary: MTLLibrary? { return nil }
    open var customVertexShaderName: String? { return nil }
    open var customVertexTextureActive: Bool { return false }
    open var customVertexNodeIn: (NODE & NODEOut)? { return nil }
//    open var customVertexNodeIn: (NODE & NODEOut)?
    open var customMatrices: [matrix_float4x4] { return [] }
    public var customLinkedNodes: [NODE] = []
    
    public var inRender = false
    public var rendering = false
    public var needsRender = false {
        didSet {
            guard needsRender else { return }
            guard pixelKit.render.engine.renderMode == .direct else { return }
            pixelKit.render.engine.renderNODE(self, done: { _ in })
        }
    }
    public var renderIndex: Int = 0
    public var contentLoaded: Bool?
    var inputTextureAvalible: Bool?
    var generatorNotBypassed: Bool?
    
    public var destroyed = false
    
    // MARK: - Life Cycle
    
    init() {
    
        pixView = PIXView(with: PixelKit.main.render)
        
        setupShader()
            
        pixelKit.render.add(node: self)
        
        pixelKit.logger.log(node: self, .detail, nil, "Linked with PixelKit.", clean: true)
    
    }
    
    // MARK: - Setup
    
    func setupShader() {
        guard shaderName != "" else {
            pixelKit.logger.log(node: self, .fatal, nil, "Shader not defined.")
            return
        }
        let template = contentLoaded == false || inputTextureAvalible == false || generatorNotBypassed == false
        let shaderName = template ? "templatePIX" : self.shaderName
        do {
            let frag = try pixelKit.render.makeFrag(shaderName, with: customMetalLibrary, from: self)
            let vtx: MTLFunction? = customVertexShaderName != nil ? try pixelKit.render.makeVertexShader(customVertexShaderName!, with: customMetalLibrary) : nil
            pipeline = try pixelKit.render.makeShaderPipeline(frag, with: vtx, addMode: additiveVertexBlending)
            #if !os(tvOS) || !targetEnvironment(simulator)
            sampler = try pixelKit.render.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl, mipFilter: mipmap)
            #endif
        } catch {
            pixelKit.logger.log(node: self, .fatal, nil, "Setup failed.", e: error)
        }
    }
    
    // MARK: - Sampler
    
    func updateSampler() {
        do {
            #if !os(tvOS) || !targetEnvironment(simulator)
            sampler = try pixelKit.render.makeSampler(interpolate: interpolate.mtl, extend: extend.mtl, mipFilter: mipmap)
            #endif
            pixelKit.logger.log(node: self, .info, nil, "New Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)")
            setNeedsRender()
        } catch {
            pixelKit.logger.log(node: self, .error, nil, "Error setting new Sample Mode. Interpolate: \(interpolate) & Extend: \(extend)", e: error)
        }
    }
    
    // MARK: - Render
    
    public func setNeedsRender() {
        guard !bypass || self is PIXGenerator else {
            renderOuts()
            return
        }
        checkSetup()
        guard !needsRender else {
//            pixelKit.logger.log(node: self, .warning, .render, "Already requested.", loop: true)
            return
        }
//        guard resolution != nil else {
//            pixelKit.logger.log(node: self, .warning, .render, "Resolution unknown.", loop: true)
//            return
//        }
        guard view.metalView.resolution != nil else {
            pixelKit.logger.log(node: self, .warning, .render, "Metal View res not set.", loop: true)
            pixelKit.logger.log(node: self, .debug, .render, "Auto applying Resolution...", loop: true)
            applyResolution {
                self.setNeedsRender()
            }
            return
        }
        pixelKit.logger.log(node: self, .detail, .render, "Requested.", loop: true)
//        delegate?.pixWillRender(self)
        needsRender = true
    }
    
    func checkSetup() {
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
                pixelKit.logger.log(node: self, .warning, .render, "Content not loaded.", loop: true)
            }
        }
        if let input = self as? NODEInIO {
            if input.inputList.first?.texture != nil {
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
        if self is PIXGenerator {
            if !bypass {
                let wasBad = generatorNotBypassed == false
                if generatorNotBypassed != true {
                    generatorNotBypassed = true
                    if wasBad {
                        setupShader()
                    }
                }
            } else {
                if generatorNotBypassed != false {
                    generatorNotBypassed = false
                    setupShader()
                }
            }
        }
    }
        
    func renderOuts() {
        if let pixOut = self as? NODEOutIO {
            for pixOutPath in pixOut.outputPathList {
//                guard let pix = pixOutPath?.pixIn else { continue }
                let pix = pixOutPath.nodeIn
                guard !pix.destroyed else { continue }
                guard pix.id != self.id else {
                    pixelKit.logger.log(node: self, .error, .render, "Connected to self.")
                    continue
                }
                pix.setNeedsRender()
            }
        }
    }
    
    open func didRender(texture: MTLTexture, force: Bool = false) {
        self.texture = texture
        renderIndex += 1
        delegate?.nodeDidRender(self)
        if pixelKit.render.engine.renderMode != .frameTree {
            for customLinkedPix in customLinkedNodes {
                customLinkedPix.setNeedsRender()
            }
            if !force { // CHECK the force!
                renderOuts()
                renderCustomVertexTexture()
            }
        }
    }
    
    func renderCustomVertexTexture() {
        for pix in pixelKit.render.linkedNodes {
            if pix.customVertexTextureActive {
                if let input = pix.customVertexNodeIn {
                    if input.id == self.id {
                        pix.setNeedsRender()
                    }
                }
            }
        }
    }
    
    // MARK: - Out Path

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
    
    func setNeedsConnectSingle(new newInPix: (NODE & NODEOut)?, old oldInPix: (NODE & NODEOut)?) {
        guard var pixInIO = self as? PIX & NODEInIO else { pixelKit.logger.log(node: self, .error, .connection, "NODEIn's Only"); return }
        if let oldPixOut = oldInPix {
            var pixOut = oldPixOut as! (PIX & NODEOutIO)
            for (i, pixOutPath) in pixOut.outputPathList.enumerated() {
                if pixOutPath.nodeIn.id == pixInIO.id {
                    pixOut.outputPathList.remove(at: i)
                    break
                }
            }
            pixInIO.inputList = []
            pixelKit.logger.log(node: self, .info, .connection, "Disonnected Single: \(pixOut)")
        }
        if let newPixOut = newInPix {
            guard newPixOut.id != self.id else {
                pixelKit.logger.log(node: self, .error, .connection, "Can't connect to self.")
                return
            }
            var pixOut = newPixOut as! (PIX & NODEOutIO)
            pixInIO.inputList = [pixOut]
            pixOut.outputPathList.append(NODEOutPath(nodeIn: pixInIO, inIndex: 0))
            applyResolution { self.setNeedsRender() }
            pixelKit.logger.log(node: self, .info, .connection, "Connected Single: \(pixOut)")
        } else {
            disconnected()
        }
    }
    
    func setNeedsConnectMerger(new newInPix: (NODE & NODEOut)?, old oldInPix: (NODE & NODEOut)?, second: Bool) {
        guard var pixInIO = self as? PIX & NODEInIO else { pixelKit.logger.log(node: self, .error, .connection, "NODEIn's Only"); return }
        guard let pixInMerger = self as? NODEInMerger else { return }
        if let oldPixOut = oldInPix {
            var pixOut = oldPixOut as! (PIX & NODEOutIO)
            for (i, pixOutPath) in pixOut.outputPathList.enumerated() {
                if pixOutPath.nodeIn.id == pixInIO.id {
                    pixOut.outputPathList.remove(at: i)
                    break
                }
            }
            pixInIO.inputList = []
            pixelKit.logger.log(node: self, .info, .connection, "Disonnected Merger: \(pixOut)")
        }
        if let newPixOut = newInPix {
            if var pixOutA = (!second ? newPixOut : pixInMerger.inputA) as? (PIX & NODEOutIO),
                var pixOutB = (second ? newPixOut : pixInMerger.inputB) as? (PIX & NODEOutIO) {
                pixInIO.inputList = [pixOutA, pixOutB]
                pixOutA.outputPathList.append(NODEOutPath(nodeIn: pixInIO, inIndex: 0))
                pixOutB.outputPathList.append(NODEOutPath(nodeIn: pixInIO, inIndex: 1))
                applyResolution { self.setNeedsRender() }
                pixelKit.logger.log(node: self, .info, .connection, "Connected Merger: \(pixOutA), \(pixOutB)")
            }
        } else {
            disconnected()
        }
    }
    
    func setNeedsConnectMulti(new newInPixs: [NODE & NODEOut], old oldInPixs: [NODE & NODEOut]) {
        guard var pixInIO = self as? PIX & NODEInIO else { pixelKit.logger.log(node: self, .error, .connection, "NODEIn's Only"); return }
        pixInIO.inputList = newInPixs
        for oldInPix in oldInPixs {
            if var input = oldInPix as? (PIX & NODEOutIO) {
                for (j, pixOutPath) in input.outputPathList.enumerated() {
                    if pixOutPath.nodeIn.id == pixInIO.id {
                        input.outputPathList.remove(at: j)
                        break
                    }
                }
            }
        }
        for (i, newInPix) in newInPixs.enumerated() {
            if var input = newInPix as? (PIX & NODEOutIO) {
                input.outputPathList.append(NODEOutPath(nodeIn: pixInIO, inIndex: i))
            }
        }
        if newInPixs.isEmpty {
            disconnected()
        }
        pixelKit.logger.log(node: self, .info, .connection, "Connected Multi: \(newInPixs)")
        applyResolution { self.setNeedsRender() }
    }
    
    func disconnected() {
        removeRes()
    }
    
    // MARK: - Other
    
    // MARL: Custom Linking
    
    public func customLink(to pix: PIX) {
        for customLinkedPix in customLinkedNodes {
            if customLinkedPix.id == pix.id {
                return
            }
        }
        customLinkedNodes.append(pix)
    }
    
    public func customDelink(from pix: PIX) {
        for (i, customLinkedPix) in customLinkedNodes.enumerated() {
            if customLinkedPix.id == pix.id {
                customLinkedNodes.remove(at: i)
                return
            }
        }
    }
    
    // MARK: Equals
    
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
    
    public func isEqual(to node: NODE) -> Bool {
        self.id == node.id
    }
    
    // MARK: Live
    
    public func checkLive() {
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
    
    public func destroy() {
        pixelKit.render.remove(node: self)
        texture = nil
        bypass = true
        destroyed = true
    }
    
}
