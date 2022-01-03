//
//  PixelatePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-10-05.
//

import Foundation
import RenderKit
import Resolution
import MetalKit
import PixelColor

final public class PixelatePIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: Properties
    
    public enum Style: String, Enumable {
        
        case pixel
        case crystal
        case hexagon
        case point
        
        public var index: Int {
            switch self {
            case .pixel:
                return 0
            case .crystal:
                return 1
            case .hexagon:
                return 2
            case .point:
                return 3
            }
        }
        
        public var name: String {
            switch self {
            case .pixel:
                return "Pixel"
            case .crystal:
                return "Crystal"
            case .hexagon:
                return "Hexagon"
            case .point:
                return "Point"
            }
        }
        
        public var typeName: String {
            rawValue
        }
        
        var ciFilterName: String {
            switch self {
            case .pixel:
                return "CIPixellate"
            case .crystal:
                return "CICrystallize"
            case .hexagon:
                return "CIHexagonalPixellate"
            case .point:
                return "CIPointillize"
            }
        }
        
        enum Property {
            case position
            case radius
            case scale
            case rotation
            case angle
        }
        var properties: Set<Property> {
            switch self {
            case .pixel:
                return [.position, .scale]
            case .crystal:
                return [.position, .radius]
            case .hexagon:
                return [.position, .scale]
            case .point:
                return [.position, .radius]
            }
        }
        
    }
    
    @LiveEnum("style") public var style: Style = .pixel
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("radius") public var radius: CGFloat = 0.5

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _position, _radius]
    }

    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Pixelate", typeName: "pix-effect-single-pixelate")
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
    }
    
}

extension PixelatePIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        let size: CGSize = texture.resolution.size
        
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        var parameters: [String : Any] = [kCIInputImageKey : ciImage]
        if style.properties.contains(.position) {
            parameters["inputCenter"] = CIVector(x: size.width / 2 + position.x * size.height,
                                                 y: size.height / 2 + position.y * -1 * size.height)
        }
        if style.properties.contains(.radius) {
            parameters["inputRadius"] = NSNumber(value: radius * 10)
        }
        if style.properties.contains(.scale) {
            parameters["inputScale"] = NSNumber(value: radius * 10)
        }
            
        guard let filter: CIFilter = CIFilter(name: style.ciFilterName, parameters: parameters) else { return nil }
        guard let finalImage: CIImage = filter.outputImage else { return nil }
        
        let croppedImage: CIImage = finalImage.cropped(to: ciImage.extent)
        
        do {
            let finalTexture: MTLTexture = try Texture.makeTexture(from: croppedImage,
                                                                   at: texture.resolution.size,
                                                                   colorSpace: PixelKit.main.render.colorSpace,
                                                                   bits: PixelKit.main.render.bits,
                                                                   with: commandBuffer,
                                                                   on: PixelKit.main.render.metalDevice)
            return finalTexture
        } catch {
            PixelKit.main.logger.log(node: self, .error, .resource, "CI Filter Failed", e: error)
            return nil
        }
        
    }
    
}
