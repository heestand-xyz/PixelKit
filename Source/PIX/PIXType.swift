//
//  Created by Anton Heestand on 2021-11-16.
//

import Foundation
import RenderKit
import Resolution

public enum PIXType: Equatable, CaseIterable {
    
    public enum ContentType: Hashable {
        case generator(PIXGeneratorType)
        case resource(PIXResourceType)
        case sprite(PIXSpriteType)
    }
    case content(ContentType)
    
    public enum EffectType: Hashable {
        case single(PIXSingleEffectType)
        case merger(PIXMergerEffectType)
        case multi(PIXMultiEffectType)
    }
    case effect(EffectType)
    
    case output(PIXOutputType)
    
    // MARK: All Cases
    
    public static var allCases: [Self] {
        var allCases: [Self] = []
        allCases.append(contentsOf: PIXGeneratorType.allCases.map({ type in
            .content(.generator(type))
        }))
        allCases.append(contentsOf: PIXResourceType.allCases.map({ type in
            .content(.resource(type))
        }))
        allCases.append(contentsOf: PIXSpriteType.allCases.map({ type in
            .content(.sprite(type))
        }))
        allCases.append(contentsOf: PIXSingleEffectType.allCases.map({ type in
            .effect(.single(type))
        }))
        allCases.append(contentsOf: PIXMergerEffectType.allCases.map({ type in
            .effect(.merger(type))
        }))
        allCases.append(contentsOf: PIXMultiEffectType.allCases.map({ type in
            .effect(.multi(type))
        }))
        allCases.append(contentsOf: PIXOutputType.allCases.map({ type in
            .output(type)
        }))
        return allCases
    }
    
    // MARK: Path
    
    public var path: String {
        switch self {
        case .content(let content):
            switch content {
            case .generator(let generator):
                return "content/generator/\(generator.rawValue)"
            case .resource(let resource):
                return "content/resource/\(resource.rawValue)"
            case .sprite(let sprite):
                return "content/sprite/\(sprite.rawValue)"
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                return "effect/single/\(single.rawValue)"
            case .merger(let merger):
                return "effect/merger/\(merger.rawValue)"
            case .multi(let multi):
                return "effect/multi/\(multi.rawValue)"
            }
        case .output(let output):
            return "output/\(output.rawValue)"
        }
    }
    
    // MARK: Name
    
    public var name: String {
        switch self {
        case .content(let content):
            switch content {
            case .generator(let generator):
                return generator.name
            case .resource(let resource):
                return resource.name
            case .sprite(let sprite):
                return sprite.name
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                return single.name
            case .merger(let merger):
                return merger.name
            case .multi(let multi):
                return multi.name
            }
        case .output(let output):
            return output.name
        }
    }
    
    // MARK: Type Name
    
    public var typeName: String {
        switch self {
        case .content(let content):
            switch content {
            case .generator(let generator):
                return generator.typeName
            case .resource(let resource):
                return resource.typeName
            case .sprite(let sprite):
                return sprite.typeName
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                return single.typeName
            case .merger(let merger):
                return merger.typeName
            case .multi(let multi):
                return multi.typeName
            }
        case .output(let output):
            return output.typeName
        }
    }
    
    // MARK: Type
    
    public var pixType: PIX.Type? {
        switch self {
        case .content(let content):
            switch content {
            case .generator(let generator):
                return generator.type
            case .resource(let resource):
                return resource.type
            case .sprite(let sprite):
                return sprite.type
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                return single.type
            case .merger(let merger):
                return merger.type
            case .multi(let multi):
                return multi.type
            }
        case .output(let output):
            return output.type
        }
    }
    
    public var isHidden: Bool {
        switch self {
        case .content(let content):
            switch content {
            case .generator:
                return false
            case .resource(let resource):
                switch resource {
                case .streamIn:
                    return true
                case .vector:
                    return true
                case .view:
                    return true
                case .web:
                    return true
                default:
                    return false
                }
            case .sprite:
                return true
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                switch single {
                case .average:
                    return true
                case .cache:
                    return true
                case .deepLab:
                    return true
                case .slice:
                    return true
                case .reduce:
                    return true
                case .distance:
                    return true
                default:
                    return false
                }
            case .merger:
                return false
            case .multi:
                return false
            }
        case .output(let output):
            switch output {
            case .streamOut:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: PIX
    
    public func pix(at resolution: Resolution) -> PIX? {
        switch self {
        case .content(let content):
            switch content {
            case .generator(let generator):
                return generator.type.init(at: resolution)
            case .resource(let resource):
                if resource == .web {
                    return WebPIX(at: resolution)
                }
                if resource == .maps {
                    return EarthPIX(at: resolution)
                }
                #if os(iOS) && !targetEnvironment(simulator)
                if resource == .paint {
                    return PaintPIX(at: resolution)
                }
                #endif
                guard let pix = resource.type?.init() else { return nil }
                precondition(pix is NODEResolution == false)
                return pix
            case .sprite(let sprite):
                return sprite.type.init(at: resolution)
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                if single == .resolution {
                    return ResolutionPIX(at: resolution)
                }
                guard let pix = single.type?.init() else { return nil }
                precondition(pix is NODEResolution == false)
                return pix
            case .merger(let merger):
                let pix = merger.type.init()
                precondition(pix is NODEResolution == false)
                return pix
            case .multi(let multi):
                if multi == .stack {
                    return StackPIX(at: resolution)
                } else if multi == .textureParticles {
                    return TextureParticlesPIX(at: resolution)
                } else if multi == .instancer {
                    return InstancerPIX(at: resolution)
                }
                let pix = multi.type.init()
                precondition(pix is NODEResolution == false)
                return pix
            }
        case .output(let output):
            guard let pix = output.type?.init() else { return nil }
            precondition(pix is NODEResolution == false)
            return pix
        }
    }
    
    // MARK: Resolution
    
    @discardableResult
    public func set(resolution: Resolution, pix: PIX) -> Bool {
        switch self {
        case .content(let content):
            switch content {
            case .generator:
                guard let pixGenerator = pix as? PIXGenerator else { return false }
                pixGenerator.resolution = resolution
                return true
            case .resource(let resource):
                if resource == .web {
                    guard let webPix = pix as? WebPIX else { return false }
                    webPix.resolution = resolution
                    return true
                }
                #if os(iOS) && !targetEnvironment(simulator)
                if resource == .web {
                    guard let paintPix = pix as? PaintPIX else { return false }
                    paintPix.resolution = resolution
                    return true
                }
                #endif
                if resource == .camera {
                    guard let cameraPix = pix as? CameraPIX else { return false }
                    guard let cameraResolution = CameraPIX.CameraResolution(resolution: resolution) else { return false }
                    cameraPix.cameraResolution = cameraResolution
                    return true
                }
                return false
            case .sprite:
                guard let spritePix = pix as? PIXSprite else { return false }
                spritePix.resolution = resolution
                return true
            }
        case .effect(let effect):
            switch effect {
            case .single(let single):
                if single == .resolution {
                    guard let resolutionPix = pix as? ResolutionPIX else { return false }
                    resolutionPix.resolution = resolution
                    return true
                }
                return false
            case .merger:
                return false
            case .multi(let multi):
                if multi == .stack {
                    guard let stackPix = pix as? StackPIX else { return false }
                    stackPix.resolution = resolution
                    return true
                } else if multi == .textureParticles {
                    guard let textureParticlesPix = pix as? TextureParticlesPIX else { return false }
                    textureParticlesPix.resolution = resolution
                    return true
                } else if multi == .instancer {
                    guard let instancerPix = pix as? InstancerPIX else { return false }
                    instancerPix.resolution = resolution
                    return true
                }
                return false
            }
        case .output:
            return false
        }
    }
    
    // MARK: Camera
    
    public var isCamera: Bool {
        if self == .content(.resource(.camera)) { return true }
        if self == .content(.resource(.depthCamera)) { return true }
        if self == .content(.resource(.multiCamera)) { return true }
        return false
    }
    
    // MARK: Codable
    
    private enum NodeCodingKeys: CodingKey {
        case path
    }

    public enum CodingError: LocalizedError {
        case badPath(String)
        case unknownPath(String)
        case badRawValue(String)
        public var errorDescription: String? {
            switch self {
            case .badPath(let path):
                return "Pixel Type - Coding Error - Bad Path: \(path)"
            case .unknownPath(let path):
                return "Pixel Type - Coding Error - Unknown Path: \(path)"
            case .badRawValue(let rawValue):
                return "Pixel Type - Coding Error - Bad Raw Value: \(rawValue)"
            }
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NodeCodingKeys.self)
        
        let path: String = try container.decode(String.self, forKey: .path)
        
        let parts: [String] = path.split(separator: "/").map(String.init)
        
        guard let rawValue: String = parts.last else {
            throw CodingError.badPath(path)
        }
        
        switch path {
        case _ where path.starts(with: "content/generator"):
            guard let type: PIXGeneratorType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .content(.generator(type))
        case _ where path.starts(with: "content/resource"):
            guard let type: PIXResourceType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .content(.resource(type))
        case _ where path.starts(with: "content/sprite"):
            guard let type: PIXSpriteType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .content(.sprite(type))
        case _ where path.starts(with: "effect/single"):
            guard let type: PIXSingleEffectType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .effect(.single(type))
        case _ where path.starts(with: "effect/merger"):
            guard let type: PIXMergerEffectType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .effect(.merger(type))
        case _ where path.starts(with: "effect/multi"):
            guard let type: PIXMultiEffectType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .effect(.multi(type))
        case _ where path.starts(with: "output"):
            guard let type: PIXOutputType = .init(rawValue: rawValue) else {
                throw CodingError.badRawValue(rawValue)
            }
            self = .output(type)
        default:
            throw CodingError.unknownPath(path)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: NodeCodingKeys.self)
        try container.encode(path, forKey: .path)
    }
}
