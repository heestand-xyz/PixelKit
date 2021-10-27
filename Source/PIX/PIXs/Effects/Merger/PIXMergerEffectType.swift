
public enum PIXMergerEffectType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case blend
    case cross
    case displace
    case lookup
    case lumaBlur
    case lumaColorShift
    case lumaLevels
    case lumaRainbowBlur
    case lumaTransform
    case metalMergerEffect
    case metalScriptMergerEffect
    case remap
    case reorder
    case timeMachine
    
    public var name: String {
        switch self {
        case .blend:
            return "Blend"
        case .cross:
            return "Cross"
        case .displace:
            return "Displace"
        case .lookup:
            return "Lookup"
        case .lumaBlur:
            return "Luma Blur"
        case .lumaColorShift:
            return "Luma Color Shift"
        case .lumaLevels:
            return "Luma Levels"
        case .lumaRainbowBlur:
            return "Luma Rainbow Blur"
        case .lumaTransform:
            return "Luma Transform"
        case .metalMergerEffect:
            return "Metal (2FX)"
        case .metalScriptMergerEffect:
            return "Metal Script (2FX)"
        case .remap:
            return "Remap"
        case .reorder:
            return "Reorder"
        case .timeMachine:
            return "Time Machine"
        }
    }
    
    public var typeName: String {
        switch self {
        case .metalMergerEffect:
            return "pix-effect-merger-metal"
        case .metalScriptMergerEffect:
            return "pix-effect-merger-metal-script"
        default:
            return "pix-effect-merger-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    public var type: PIXMergerEffect.Type {
        switch self {
        case .blend:
            return BlendPIX.self
        case .cross:
            return CrossPIX.self
        case .displace:
            return DisplacePIX.self
        case .lookup:
            return LookupPIX.self
        case .lumaBlur:
            return LumaBlurPIX.self
        case .lumaColorShift:
            return LumaColorShiftPIX.self
        case .lumaLevels:
            return LumaLevelsPIX.self
        case .lumaRainbowBlur:
            return LumaRainbowBlurPIX.self
        case .lumaTransform:
            return LumaTransformPIX.self
        case .metalMergerEffect:
            return MetalMergerEffectPIX.self
        case .metalScriptMergerEffect:
            return MetalScriptMergerEffectPIX.self
        case .remap:
            return RemapPIX.self
        case .reorder:
            return ReorderPIX.self
        case .timeMachine:
            return TimeMachinePIX.self
        }
    }
    
}
