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
    
    var wantsAutoRes: Bool {
        if let pixContent = self as? PIXContent {
            if pixContent.res.isAuto {
                return true
            }
        } else if let resPix = self as? ResPIX {
            if resPix.res.isAuto {
                return true
            }
        }
        return false
    }

    var sampleMode: MTLSamplerAddressMode = .clampToZero {
        didSet {
            sampler = HxPxE.main.makeSampler(with: sampleMode)
            print(self, "Sample Mode")
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
        
        view.newLayoutCallback = {
            if self.wantsAutoRes {
                self.setNeedsRes()
                self.setNeedsRender()
            }
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
                print(self, "ERROR", "Res:", "Resolution unknown.")
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
    
    internal func checkAutoRes(ready: @escaping () -> ()) -> Bool {
        if wantsAutoRes {
            print(self, "Auto Res requested.")
            view.autoResReadyCallback = {
                print(self, "Auto Res ready.")
                ready()
            }
        }
        return wantsAutoRes
    }
    
    // MARK: Render
    
    func setNeedsRender() {
        guard resolution != nil else {
//            if !checkAutoRes(ready: {
////                self.setNeedsRes()
//                self.setNeedsRender()
//            }) {
//                print(self, "ERROR", "Render:", "Resolution unknown.")
//            }
            print(self, "ERROR", "Render:", "Resolution is nil.")
            return
        }
        if self is PIXIn {
            let pixOut = self.pixInList!.first!
            if pixOut.texture == nil {
                print(self, "FORCE RENDER", pixOut)
                HxPxE.main.render(pixOut, force: true)
            }
        }
        if self.texture == nil {
            print(self, "First render requested.")
        }
        needsRender = true
//        view.setNeedsDisplay()
    }
    
    func didRender(texture: MTLTexture, force: Bool = false) {
        if self.texture == nil {
            print(self, "First render done!")
        }
        self.texture = texture
        if !force {
            if self is PIXOut {
                for pixIn in pixOutList! {
                    pixIn.setNeedsRender()
                }
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
            } else if let pixInMerger = self as? PIXInMerger {
                if pixInMerger.inPixA != nil && pixInMerger.inPixB != nil {
                    connectMerger(pixInMerger.inPixA!, pixInMerger.inPixB!)
                } else {
                    print("disconnect merger...") // CHECK
                }
            }
//            else if let pixInMulti = self as? PIXInMulti {
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
        print(self, "Connected", pixOut)
        setNeedsRes() // CHECK
        setNeedsRender() // CHECK
    }
    
    func connectMerger(_ pixOutA: PIX & PIXOut, _ pixOutB: PIX & PIXOut) {
        pixInList!.append(pixOutA)
        pixInList!.append(pixOutB)
        pixOutA.pixOutList!.append(self as! PIX & PIXIn) // CHECK Index
        pixOutB.pixOutList!.append(self as! PIX & PIXIn) // CHECK Index
        print(self, "Connected", pixOutA, pixOutB)
        setNeedsRes() // CHECK
        setNeedsRender() // CHECK
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
