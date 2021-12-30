
public enum PIXMultiEffectType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case array
    case blends
    case metalMultiEffect
    case metalScriptMultiEffect
    case stack
    case textureParticles
    case instancer
    
    public var name: String {
        switch self {
        case .array:
            return "Array"
        case .blends:
            return "Blends"
        case .metalMultiEffect:
            return "Metal (NFX)"
        case .metalScriptMultiEffect:
            return "Metal Script (NFX)"
        case .stack:
            return "Stack"
        case .textureParticles:
            return "Texture Particles"
        case .instancer:
            return "Instancer"
        }
    }
    
    public var typeName: String {
        switch self {
        case .metalMultiEffect:
            return "pix-effect-multi-metal"
        case .metalScriptMultiEffect:
            return "pix-effect-multi-metal-script"
        default:
            return "pix-effect-multi-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    public var type: PIXMultiEffect.Type {
        switch self {
        case .array:
            return ArrayPIX.self
        case .blends:
            return BlendsPIX.self
        case .metalMultiEffect:
            return MetalMultiEffectPIX.self
        case .metalScriptMultiEffect:
            return MetalScriptMultiEffectPIX.self
        case .stack:
            return StackPIX.self
        case .textureParticles:
            return TextureParticlesPIX.self
        case .instancer:
            return InstancerPIX.self
        }
    }
    
}
