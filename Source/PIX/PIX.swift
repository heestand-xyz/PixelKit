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
    
    var id = UUID()
    
    var shader: String { return "nilPIX" }
    var shaderUniforms: [CGFloat] { return [] }
    var shaderNeedsAspect: Bool { return false }
    
    public let view: PIXView
    
    var pixInList: [PIX & PIXOut]?
    var pixOutList: [PIX & PIXIn]?
    
    var texture: MTLTexture?
    public var renderedTexture: MTLTexture? { return texture } // CHECK copy?
    public var renderedImage: UIImage? {
        guard let texture = renderedTexture else { return nil }
        guard let ciImage = CIImage(mtlTexture: texture, options: nil) else { return nil }
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent, format: HxPxE.main.colorBits.ci, colorSpace: HxPxE.main.colorSpace.cg) else { return nil }
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .downMirrored)
        return uiImage
    }
    public var renderedPixels: Array<float4>? {
        guard let texture = renderedTexture else { return nil }
        return HxPxE.main.raw(texture: texture)
    }
    
    var resolution: CGSize? {
        if let pixContent = self as? PIXContent {
            return pixContent.res.isAuto ? view.autoRes : pixContent.res.size
        } else if let resPix = self as? ResPIX {
            return resPix.res.isAuto ? view.autoRes : resPix.res.size
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
    
    var needsRender = false
    
    init() {
    
        view = PIXView()
        
        if HxPxE.main.aLive {
            pipeline = HxPxE.main.makeShaderPipeline(shader)//, from: shaderSource!)
            sampler = HxPxE.main.makeSampler(with: sampleMode)
            if allGood {
                HxPxE.main.add(pix: self)
            }
        }
        
        if !allGood {
            print(self, "ERROR", "Not allGood...")
        }
        
    }
    
    // MARK: JSON

    public required init(from decoder: Decoder) throws {
        fatalError("PIX Decoder Initializer is not supported.") // CHECK
    }
    
    public func encode(to encoder: Encoder) throws {}
    
    // MARK: Resolution
    
    func setNeedsRes() {
        guard let resolution = resolution else {
            if !checkAutoRes(ready: {
                self.setNeedsRes()
            }) {
                print(self, "ERROR", "setNeedsRes():", "Resolution unknown.")
            }
            return
        }
        print(self, "Res:", resolution)
        view.setResolution(resolution)
        if self is PIX & PIXOut {
            for pixIn in pixOutList! {
                pixIn.setNeedsRes()
            }
        }
    }
    
//    func newResolution() {
//        guard resolution != nil else {
//            print(self, "ERROR", "New resolution is nil.")
//            return
//        }
//    }
    
    // MARK: Render
    
    func setNeedsRender() {
        guard resolution != nil else {
            if !checkAutoRes(ready: {
//                self.setNeedsRes()
                self.setNeedsRender()
            }) {
                print(self, "ERROR", "setNeedsRender():", "Resolution unknown.")
            }
            return
        }
        if self.texture == nil {
            print(self, "First render requested.")
        }
        needsRender = true
//        view.setNeedsDisplay()
    }
    
    internal func checkAutoRes(ready: @escaping () -> ()) -> Bool {
        var needsAutoRes = false
        if let pixContent = self as? PIXContent {
            if pixContent.res.isAuto {
                needsAutoRes = true
            }
        } else if let resPix = self as? ResPIX {
            if resPix.res.isAuto {
                needsAutoRes = true
            }
        }
        if needsAutoRes {
            print(self, "Auto Res requested.")
            view.autoResReadyCallback = {
                print(self, "Auto Res ready.")
                ready()
            }
        }
        return needsAutoRes
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
            print(self, "First render done!")
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
            setNeedsRes()
        } else {
            print("\(self):", "Waiting for res...")
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
    
    // MARK: Clean
    
    deinit {
        // CHECK
        HxPxE.main.remove(pix: self)
        // Disconnect...
    }
    
}
