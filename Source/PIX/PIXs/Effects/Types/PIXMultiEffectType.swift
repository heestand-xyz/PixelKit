
public enum PIXMultiEffectType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case array
    case blends
    case metalMultiEffect
    case stack
    
    public var name: String {
        switch self {
        case .array:
            return "Array"
        case .blends:
            return "Blends"
        case .metalMultiEffect:
            return "Metal Multi Effect"
        case .stack:
            return "Stack"
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
        case .stack:
            return StackPIX.self
        }
    }
    
}
