//
//  DeepLabPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2020-01-23.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
import Vision
import CoreMedia

/// TODO: - Process .deep() on GPU

@available(iOS 12.0, *)
@available(OSX 10.14, *)
@available(tvOS 12.0, *)
public class DeepLabPIX: PIXSingleEffect, CustomRenderDelegate, PIXAuto {
    
    override open var shaderName: String { return "nilPIX" }
    
    override var staticResolution: Resolution? { .square(513) }
    
    let deepLab: DeepLabV3Int8LUT
    
    // MARK: - Public Properties
    
    public enum DeepLabTarget: String, CaseIterable {
        case background
        case aeroplane
        case bicycle
        case bird
        case boat
        case bottle
        case bus
        case car
        case cat
        case chair
        case cow
        case diningTable
        case dog
        case horse
        case motorbike
        case person
        case pottedPlant
        case sheep
        case sofa
        case train
        case tv
        var index: Int {
            DeepLabTarget.allCases.firstIndex(of: self)!
        }
    }
    public var deepLabTarget: DeepLabTarget = .person { didSet { setNeedsRender() } }
    
    // MARK: - Life Cycle
    
    public required init() {
        deepLab = DeepLabV3Int8LUT()
        super.init()
        name = "deepLab"
        customRenderDelegate = self
        customRenderActive = true
    }
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//        print(">>>")
//        let globalRenderTime = CFAbsoluteTimeGetCurrent()
        let size: CGSize = DeepLabPIX.deepLabResolution.size.cg
        do {
            let pixelBuffer: CVPixelBuffer = try Texture.pixelBuffer(from: texture, at: size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits)
            let output: DeepLabV3Int8LUTOutput = try deepLab.prediction(image: pixelBuffer)
            guard let deepCGImage: CGImage = deep(output) else {
                pixelKit.logger.log(node: self, .error, .effect, "Deep fail.")
                return nil
            }
            let deepTexture: MTLTexture = try Texture.makeTexture(from: deepCGImage, with: commandBuffer, on: pixelKit.render.metalDevice)
//            let renderTime = CFAbsoluteTimeGetCurrent() - globalRenderTime
//            let renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//            print("Total Render Time: [\(renderTimeMs)ms]")
//            print("<<<")
            return deepTexture
        } catch {
            pixelKit.logger.log(node: self, .error, .effect, "Lab fail.", e: error)
            return nil
        }
    }
    
    func deep(_ output: DeepLabV3Int8LUTOutput) -> CGImage? {
//        print("DEEP > > >")

//        // Render Time
//        var localRenderTime = CFAbsoluteTimeGetCurrent()
//        var renderTime: Double = -1
//        var renderTimeMs: Double = -1
//        print("Render Time: Started")
        
        let shape: [NSNumber] = output.semanticPredictions.shape
        let d: Int = 1
        let (w,h) = (Int(truncating: shape[0]), Int(truncating: shape[1]))
        let pageSize = w*h
        var res:Array<Int> = []
        
//        // Render Time
//        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
//        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//        print("Render Time: [\(renderTimeMs)ms] A")
//        localRenderTime = CFAbsoluteTimeGetCurrent()
        
//        func argmax(arr:Array<Int>) -> Int{
//            precondition(arr.count > 0)
//            var maxValue = arr[0]
//            var maxValueIndex = 0
//            for i in 1..<arr.count {
//                if arr[i] > maxValue {
//                    maxValue = arr[i]
//                    maxValueIndex = i
//                }
//            }
//            return maxValueIndex
//        }
        
        for i in 0..<w {
            for j in 0..<h {
                let pageOffset = i * w + j
                let thing: Int = Int(truncating: output.semanticPredictions[pageOffset])
                res.append(thing)
            }
        }
        
//        // Render Time
//        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
//        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//        print("Render Time: [\(renderTimeMs)ms] B")
//        localRenderTime = CFAbsoluteTimeGetCurrent()
        
        let bytesPerComponent = MemoryLayout<UInt8>.size
        let bytesPerPixel = bytesPerComponent * 4
        let length = pageSize * bytesPerPixel
        
        var data = Data(count: length)
        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
            var pointer = bytes
            for pix in res {
                let v: UInt8 = deepLabTarget.index == pix ? 255 : 0
                for _ in 0..<3 {
                    pointer.pointee = v
                    pointer += 1
                }
                pointer.pointee = 255
                pointer += 1
            }
        }
        
//        // Render Time
//        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
//        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//        print("Render Time: [\(renderTimeMs)ms] C")
//        localRenderTime = CFAbsoluteTimeGetCurrent()
        
        let provider: CGDataProvider = CGDataProvider(data: data as CFData)!
        let cgimg = CGImage(
            width: w,
            height: h,
            bitsPerComponent: bytesPerComponent * 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerPixel * w,
            space: pixelKit.render.colorSpace.cg, //CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
//        // Render Time
//        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
//        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//        print("Render Time: [\(renderTimeMs)ms] D")
//        localRenderTime = CFAbsoluteTimeGetCurrent()
        
//        print("DEEP < < <")
        
        return cgimg
        
    }
    
}
