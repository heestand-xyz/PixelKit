//
//  PIX.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-20.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

public class PIX {
    
    let id = UUID()
    
    let shader: String
//    let shaderSource: String?
    var shaderUniforms: [Double] { return [] }
    
    public let view: PIXView
    
    var pixInList: [PIX & PIXOut]?
    var pixOutList: [PIX & PIXIn]?
    
    var texture: MTLTexture? // lastDrawnTexture // public
    public var image: UIImage? {
        guard let texture = texture else { return nil }
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else { return nil }
        return UIImage(ciImage: ciImage)
    }
    public var rawData: Array<float4>? {
        guard let texture = texture else { return nil }
        return HxPxE.main.raw(texture: texture)
    }
    
    public var resolution: CGSize? {
        if self is PIXContent {
            return (self as! PIXContent).contentResolution
        } else if let resPix = self as? ResPIX {
            return resPix.res
        } else if let pixIn = self as? PIX & PIXIn {
            return pixIn.pixInList!.first?.resolution
        } else {
            return nil
        }
    }

    var sampleMode: MTLSamplerAddressMode = .clampToZero {
        didSet {
            sampler = HxPxE.main.makeSampler(with: sampleMode)
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
    
//    var inputTextures: [MTLTexture?]?
//    var buffer: CVPixelBuffer? {
//        didSet {
//            view.setNeedsDisplay()
//        }
//    }
    
    var needsRender = false
    
//    let drawCallback: (MTLTexture) -> ()
    
    public init(shader: String) {
        
        self.shader = shader
        
//        shaderSource = HxPxE.main.loadMetalShaderSource(named: shader)
        
        view = PIXView()
        
//        if shaderSource != nil {
        if HxPxE.main.aLive {
            pipeline = HxPxE.main.makeShaderPipeline(shader)//, from: shaderSource!)
            sampler = HxPxE.main.makeSampler(with: sampleMode)
            if allGood {
                HxPxE.main.add(pix: self)
            }
        }
//        } else {
//            print("HxPxE ERROR:", "PIX Shader Source not loaded:", self)
//        }
        
        if !allGood {
            print("HxPxE PIX ERROR:", "Not allGood...", "PIX:", self)
        }
        
    }
    
    deinit {
        // CHECK
        HxPxE.main.remove(pix: self)
        // Disconnect...
    }
    
    // MARK: Resolution
    
    func newResolution() {
        guard resolution != nil else {
            print("HxPxE PIX ERROR:", "New resolution is nil.", "PIX:", self)
            return
        }
        view.setResolution(resolution!)
        if let pixOut = self as? PIX & PIXOut {
            for pixIn in pixOut.pixOutList! {
                pixIn.newResolution()
            }
        }
    }
    
    // MARK: Render
    
    func setNeedsRender() {
        needsRender = true
//        view.setNeedsDisplay()
    }
    
//    func render() {
//        if allGood {
////            print("HxPxE -", String(describing: self).replacingOccurrences(of: "HxPxE.", with: "") ,"- Will Render")
//            view.setNeedsDisplay() // CHECK
//        }
//        updatedAndNeedsRender = false
////        view.renderDone = {
////
////        }
//    }
    
    func didRender(texture: MTLTexture) {
        if self.texture == nil {
            print("HxPxE PIX:", "First render successful!", "PIX:", self)
        }
        self.texture = texture
//        print("HxPxE -", String(describing: self).replacingOccurrences(of: "HxPxE.", with: "") ,"- Did Render")
        if self is PIXOut {
//            print("B:", self, " - ", pixOutList!)
            for pixIn in pixOutList! {
                pixIn.setNeedsRender() // CHECK
            }
        }
    }
    
    // MARK: Connect
    
    func setNeedsConnect() {
        if self is PIXIn {
            if var pixInSingle = self as? PIXInSingle {
                if pixInSingle.inPix != nil {
                    connectSingle(pixInSingle.inPix!)
                } else {
                    disconnectSingle()
                }
            }
//            else if let pixInMerger = self as? PIXInMerger {
//                
//            } else if let pixInMulti = self as? PIXInMulti {
//                
//            }
        }
        if self is PIXOut {
            
        }
//        setNeedsRender()
    }
    
    func connectSingle(_ pixOut: PIX & PIXOut) {
        pixInList!.append(pixOut)
        pixOut.pixOutList!.append(self as! PIX & PIXIn)
        if pixOut.resolution != nil {
            newResolution()
        }
    }
    
    func disconnectSingle() {
        let pixOut = pixInList!.first!
        for (i, i_pixIn) in pixOut.pixOutList!.enumerated() {
            if i_pixIn == self {
                pixOut.pixOutList!.remove(at: i)
                break
            }
        }
        pixInList = []
        view.setResolution(.zero) // CHECK
    }
    
    // MARK: Operator Overloading
    
    static func ==(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func !=(lhs: PIX, rhs: PIX) -> Bool {
        return lhs.id != rhs.id
    }
    
}
