//
//  WarpPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2021-10-05.
//

import Foundation
import RenderKit
import Resolution
import MetalKit
import PixelColor

final public class WarpPIX: PIXSingleEffect, PIXViewable {
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: Properties
    
    public enum Style: String, Enumable {
        
        case hole
        case tunnel
        case pinch
        case twirl
        case vortex
        case wrap
        
        public var index: Int {
            switch self {
            case .hole:
                return 0
            case .tunnel:
                return 1
            case .pinch:
                return 2
            case .twirl:
                return 3
            case .vortex:
                return 4
            case .wrap:
                return 5
            }
        }
        
        public var name: String {
            switch self {
            case .hole:
                return "Hole"
            case .tunnel:
                return "Tunnel"
            case .pinch:
                return "Pinch"
            case .twirl:
                return "Twirl"
            case .vortex:
                return "Vortex"
            case .wrap:
                return "Wrap"
            }
        }
        
        public var typeName: String {
            rawValue
        }
        
        var ciFilterName: String {
            switch self {
            case .hole:
                return "CIHoleDistortion"
            case .tunnel:
                return "CILightTunnel"
            case .pinch:
                return "CIPinchDistortion"
            case .twirl:
                return "CITwirlDistortion"
            case .vortex:
                return "CIVortexDistortion"
            case .wrap:
                return "CICircularWrap"
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
            case .hole:
                return [.position, .radius]
            case .tunnel:
                return [.position, .radius, .rotation]
            case .pinch:
                return [.position, .radius, .scale]
            case .twirl:
                return [.position, .radius, .angle]
            case .vortex:
                return [.position, .radius, .angle]
            case .wrap:
                return [.position, .radius, .angle]
            }
        }
        
    }
    
    @LiveEnum("style") public var style: Style = .hole
    @LivePoint("position") public var position: CGPoint = .zero
    @LiveFloat("radius") public var radius: CGFloat = 0.125
    @LiveFloat("scale") public var scale: CGFloat = 0.5
    @LiveFloat("rotation", range: -0.5...0.5) public var rotation: CGFloat = 0.0

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_style, _position, _radius, _scale, _rotation]
    }

    // MARK: - Life Cycle -
    
    public required init() {
        super.init(name: "Warp", typeName: "pix-effect-single-warp")
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        customRenderActive = true
        customRenderDelegate = self
    }
    
}

extension WarpPIX: CustomRenderDelegate {
    
    public func customRender(_ texture: MTLTexture, with commandBuffer: MTLCommandBuffer) -> MTLTexture? {
        
        let size: CGSize = texture.resolution.size
        
        guard let ciImage = Texture.ciImage(from: texture, colorSpace: PixelKit.main.render.colorSpace) else { return nil }
        
        var parameters: [String : Any] = [kCIInputImageKey : ciImage]
        if style.properties.contains(.position) {
            parameters["inputCenter"] = CIVector(x: size.width / 2 + position.x * size.height,
                                                 y: size.height / 2 + position.y * -1 * size.height)
        }
        if style.properties.contains(.radius) {
            parameters["inputRadius"] = NSNumber(value: radius * 1_000)
        }
        if style.properties.contains(.scale) {
            parameters["inputScale"] = NSNumber(value: scale)
        }
        if style.properties.contains(.rotation) {
            parameters["inputRotation"] = NSNumber(value: rotation * .pi * 2)
        }
        if style.properties.contains(.angle) {
            parameters["inputAngle"] = NSNumber(value: rotation * .pi * 2)
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
