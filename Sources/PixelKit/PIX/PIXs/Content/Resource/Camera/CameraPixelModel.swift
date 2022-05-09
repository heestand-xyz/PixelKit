//
//  Created by Anton Heestand on 2021-12-21.
//

#if !os(tvOS)

import Foundation
import CoreGraphics
import RenderKit
import Resolution
import PixelColor

public struct CameraPixelModel: PixelResourceModel {
    
    // MARK: Global
    
    public var id: UUID = UUID()
    public var name: String = "Camera"
    public var typeName: String = "pix-content-resource-camera"
    public var bypass: Bool = false
    
    public var outputNodeReferences: [NodeReference] = []

    public var viewInterpolation: ViewInterpolation = .linear
    public var interpolation: PixelInterpolation = .linear
    public var extend: ExtendMode = .zero
    
    // MARK: Local
    
    public var active: Bool = true
    public var cameraResolution: CameraPIX.CameraResolution = ._1080p
    public var camera: CameraPIX.Camera = .default
    public var autoDetect: Bool = true
    public var depth: Bool = false
    public var filterDepth: Bool = true
    public var multi: Bool = false
    public var manualExposure: Bool = false
    public var exposure: CGFloat = 0.05
    public var iso: CGFloat = 300
    public var torch: CGFloat = 0.0
    public var manualFocus: Bool = false
    public var focus: CGFloat = 1.0
    public var manualWhiteBalance: Bool = false
    public var whiteBalance: PixelColor = .white
    public var centerStage: Bool = false
}

extension CameraPixelModel {
    
    enum LocalCodingKeys: String, CodingKey, CaseIterable {
        case active
        case cameraResolution
        case camera
        case autoDetect
        case depth
        case filterDepth
        case multi
        case manualExposure
        case exposure
        case iso
        case torch
        case manualFocus
        case focus
        case manualWhiteBalance
        case whiteBalance
        case centerStage
    }
    
    public init(from decoder: Decoder) throws {
        
        self = try PixelResourceModelDecoder.decode(from: decoder, model: self) as! Self
        
        let container = try decoder.container(keyedBy: LocalCodingKeys.self)
        
        active = try container.decode(Bool.self, forKey: .active)
        cameraResolution = try container.decode(CameraPIX.CameraResolution.self, forKey: .cameraResolution)
        camera = (try? container.decode(CameraPIX.Camera.self, forKey: .camera)) ?? CameraPIX.Camera.default
        autoDetect = try container.decode(Bool.self, forKey: .autoDetect)
        
        if try PixelModelDecoder.isLiveListCodable(decoder: decoder) {
            return
        }
        
        depth = try container.decode(Bool.self, forKey: .depth)
        filterDepth = try container.decode(Bool.self, forKey: .filterDepth)
        multi = try container.decode(Bool.self, forKey: .multi)
        manualExposure = try container.decode(Bool.self, forKey: .manualExposure)
        exposure = try container.decode(CGFloat.self, forKey: .exposure)
        iso = try container.decode(CGFloat.self, forKey: .iso)
        torch = try container.decode(CGFloat.self, forKey: .torch)
        manualFocus = try container.decode(Bool.self, forKey: .manualFocus)
        focus = try container.decode(CGFloat.self, forKey: .focus)
        manualWhiteBalance = try container.decode(Bool.self, forKey: .manualWhiteBalance)
        whiteBalance = try container.decode(PixelColor.self, forKey: .whiteBalance)
        centerStage = try container.decode(Bool.self, forKey: .centerStage)
    }
}

extension CameraPixelModel {
    
    public func isEqual(to nodeModel: NodeModel) -> Bool {
        guard let pixelModel = nodeModel as? Self else { return false }
        guard isPixelResourceEqual(to: pixelModel) else { return false }
        guard active == pixelModel.active else { return false }
        guard cameraResolution == pixelModel.cameraResolution else { return false }
        guard camera == pixelModel.camera else { return false }
        guard autoDetect == pixelModel.autoDetect else { return false }
        guard depth == pixelModel.depth else { return false }
        guard filterDepth == pixelModel.filterDepth else { return false }
        guard multi == pixelModel.multi else { return false }
        guard manualExposure == pixelModel.manualExposure else { return false }
        guard exposure == pixelModel.exposure else { return false }
        guard iso == pixelModel.iso else { return false }
        guard torch == pixelModel.torch else { return false }
        guard manualFocus == pixelModel.manualFocus else { return false }
        guard focus == pixelModel.focus else { return false }
        guard manualWhiteBalance == pixelModel.manualWhiteBalance else { return false }
        guard whiteBalance == pixelModel.whiteBalance else { return false }
        guard centerStage == pixelModel.centerStage else { return false }
        return true
    }
}

#endif
