//
//  DeepLabPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2020-01-23.
//  Open Source - MIT License
//


import RenderKit
import Vision
import CoreMedia

// TODO: - Process .deep() on GPU

// DeepLabV3Int8LUT
// https://github.com/hexagons/PixelKit/blob/master/Resources/Models/DeepLabV3Int8LUT.mlmodel

@available(iOS 12.0, *)
@available(OSX 10.14, *)
@available(tvOS 12.0, *)
final public class DeepLabPIX: PIXSingleEffect, CustomRenderDelegate, BodyViewRepresentable {
    
    override public var shaderName: String { return "nilPIX" }
    
    public var bodyView: UINSView { pixView }
    
    override var customResolution: Resolution? { .square(513) }
    
//    let deepLabModel: DeepLabV3Int8LUT
        
    public typealias DeepPack = (size: CGSize, data: [Int])
    public var externalDeepLab: ((CVPixelBuffer, @escaping (Result<DeepPack, Error>) -> ()) -> ())?
    var lastDeepCGImage: CGImage?
    
    var processing: Bool = false
    
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
//        deepLabModel = DeepLabV3Int8LUT()
        super.init(name: "Deep Lab", typeName: "pix-effect-single-deep-lab")
        customRenderDelegate = self
        customRenderActive = true
    }

    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? { return nil }

//    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
//        pixelKit.logger.log(node: self, .info, .effect, "Custom Render Start")
//        let size: CGSize = customResolution!.size
//        do {
//            let pixelBuffer: CVPixelBuffer = try Texture.pixelBuffer(from: texture, at: size, colorSpace: pixelKit.render.colorSpace, bits: pixelKit.render.bits)
//            if !processing {
//                processing = true
//                deepLab(pixelBuffer: pixelBuffer) { result in
//                    switch result {
//                    case .success(let image):
//                        self.pixelKit.logger.log(node: self, .info, .effect, "Custom Render Done")
//                        self.lastDeepCGImage = image
//                        self.setNeedsRender() // loop?
//                        self.processing = false
//                    case .failure(let error):
//                        self.pixelKit.logger.log(node: self, .error, .effect, "Deep Fail", e: error)
//                    }
//                }
//            }
//            guard let deepCGImage: CGImage = lastDeepCGImage else { return nil }
////            lastDeepCGImage = nil
//            print(">>>")
//            let globalRenderTime = CFAbsoluteTimeGetCurrent()
//            let deepTexture: MTLTexture = try Texture.makeTexture(from: deepCGImage, with: commandBuffer, on: pixelKit.render.metalDevice)
//            let renderTime = CFAbsoluteTimeGetCurrent() - globalRenderTime
//            let renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
//            print("Deep Lab V3 - CGImage to MTLTexture - Render Time: [\(renderTimeMs)ms]")
//            print("<<<")
//            pixelKit.logger.log(node: self, .info, .effect, "Custom Render Return")
//            return deepTexture
//        } catch {
//            pixelKit.logger.log(node: self, .error, .effect, "Lab fail.", e: error)
//            return nil
//        }
//    }
//
//    // MARK: - Deep Lab
//
//    enum DeepError: Error {
//        case deepFailed
//        case externalNotSet
//    }
//
//    func deepLab(pixelBuffer: CVPixelBuffer, completion: @escaping (Result<CGImage, Error>) -> ()) {
////        let output: DeepLabV3Int8LUTOutput = try deepLabModel.prediction(image: pixelBuffer)
////        guard let deepCGImage: CGImage = deep(output) else {
////            throw DeepError.deepFailed
////        }
////        return deepCGImage
//        guard externalDeepLab != nil else {
//            completion(.failure(DeepError.externalNotSet))
//            return
//        }
//        externalDeepLab!(pixelBuffer) { result in
//            switch result {
//            case .success(let deepPack):
//                DispatchQueue.global(qos: .userInteractive).async {
//                    guard let deepCGImage: CGImage = self.deep(size: deepPack.size,
//                                                               data: deepPack.data) else {
//                        DispatchQueue.main.async {
//                            completion(.failure(DeepError.deepFailed))
//                        }
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        completion(.success(deepCGImage))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
////    func deep(_ output: DeepLabV3Int8LUTOutput) -> CGImage? {
////        let shape: [Int] = output.semanticPredictions.shape.map({ Int(truncating: $0) })
////        let size: CGSize = CGSize(width: shape[0], height: shape[1])
////        let data: [Int] = output.semanticPredictions.map({ Int(truncating: $0) })
////        return deep(size: size, data: data)
////    }
//
//    func deep(size: CGSize, data: [Int]) -> CGImage? {
////        print("DEEP > > >")
//
////        // Render Time
////        var localRenderTime = CFAbsoluteTimeGetCurrent()
////        var renderTime: Double = -1
////        var renderTimeMs: Double = -1
////        print("Render Time: Started")
//
////        let d: Int = 1
//        let (w,h) = (Int(size.width), Int(size.height))
//        let pageSize = w*h
//        let res:Array<Int> = data
//
////        // Render Time
////        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
////        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
////        print("Render Time: [\(renderTimeMs)ms] A")
////        localRenderTime = CFAbsoluteTimeGetCurrent()
//
////        func argmax(arr:Array<Int>) -> Int{
////            precondition(arr.count > 0)
////            var maxValue = arr[0]
////            var maxValueIndex = 0
////            for i in 1..<arr.count {
////                if arr[i] > maxValue {
////                    maxValue = arr[i]
////                    maxValueIndex = i
////                }
////            }
////            return maxValueIndex
////        }
//
////        for i in 0..<w {
////            for j in 0..<h {
////                let pageOffset = i * w + j
////                let thing: Int = data[pageOffset]
////                res.append(thing)
////            }
////        }
//
////        // Render Time
////        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
////        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
////        print("Render Time: [\(renderTimeMs)ms] B")
////        localRenderTime = CFAbsoluteTimeGetCurrent()
//
//        let bytesPerComponent = MemoryLayout<UInt8>.size
//        let bytesPerPixel = bytesPerComponent * 4
//        let length = pageSize * bytesPerPixel
//
//        var data = Data(count: length)
//        data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) -> Void in
//            var pointer = bytes
//            for pix in res {
//                let v: UInt8 = deepLabTarget.index == pix ? 255 : 0
//                for _ in 0..<3 {
//                    pointer.pointee = v
//                    pointer += 1
//                }
//                pointer.pointee = 255
//                pointer += 1
//            }
//        }
//
////        // Render Time
////        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
////        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
////        print("Render Time: [\(renderTimeMs)ms] C")
////        localRenderTime = CFAbsoluteTimeGetCurrent()
//
//        let provider: CGDataProvider = CGDataProvider(data: data as CFData)!
//        let cgimg = CGImage(
//            width: w,
//            height: h,
//            bitsPerComponent: bytesPerComponent * 8,
//            bitsPerPixel: bytesPerPixel * 8,
//            bytesPerRow: bytesPerPixel * w,
//            space: pixelKit.render.colorSpace, //CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue),
//            provider: provider,
//            decode: nil,
//            shouldInterpolate: false,
//            intent: CGColorRenderingIntent.defaultIntent
//        )
//
////        // Render Time
////        renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
////        renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
////        print("Render Time: [\(renderTimeMs)ms] D")
////        localRenderTime = CFAbsoluteTimeGetCurrent()
//
////        print("DEEP < < <")
//
//        return cgimg
//
//    }
    
}
