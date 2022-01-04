
public enum PIXSingleEffectType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case average
    case blur
    case cache
    case channelMix
    case chromaKey
    case clamp
    case colorConvert
    case colorCorrect
    case colorShift
    case convert
    case cornerPin
    case crop
    case delay
    case distance
    case edge
    case feedback
    case flare
    case flipFlop
    case freeze
    case equalize
    case kaleidoscope
    case levels
    case metalEffect
    case metalScriptEffect
    case morph
    case `nil`
    case quantize
    case rainbowBlur
    case range
    case reduce
    case resolution
    case saliency
    case sepia
    case sharpen
    case slice
    case slope
    case threshold
    case tint
    case transform
    case twirl
    case opticalFlow
    case filter
    case warp
    case pixelate
    
    public var name: String {
        switch self {
        case .average:
            return "Average"
        case .blur:
            return "Blur"
        case .cache:
            return "Cache"
        case .channelMix:
            return "Channel Mix"
        case .chromaKey:
            return "Chroma Key"
        case .clamp:
            return "Clamp"
        case .colorConvert:
            return "Color Convert"
        case .colorCorrect:
            return "Color Correct"
        case .colorShift:
            return "Color Shift"
        case .convert:
            return "Convert"
        case .cornerPin:
            return "Corner Pin"
        case .crop:
            return "Crop"
        case .delay:
            return "Delay"
        case .distance:
            return "Distance"
        case .edge:
            return "Edge"
        case .feedback:
            return "Feedback"
        case .flare:
            return "Flare"
        case .flipFlop:
            return "Flip Flop"
        case .freeze:
            return "Freeze"
        case .equalize:
            return "Equalize"
        case .kaleidoscope:
            return "Kaleidoscope"
        case .levels:
            return "Levels"
        case .metalEffect:
            return "Metal (1FX)"
        case .metalScriptEffect:
            return "Metal Script (1FX)"
        case .morph:
            return "Morph"
        case .`nil`:
            return "Nil"
        case .quantize:
            return "Quantize"
        case .rainbowBlur:
            return "Rainbow Blur"
        case .range:
            return "Range"
        case .reduce:
            return "Reduce"
        case .resolution:
            return "Resolution"
        case .saliency:
            return "Saliency"
        case .sepia:
            return "Sepia"
        case .sharpen:
            return "Sharpen"
        case .slice:
            return "Slice"
        case .slope:
            return "Slope"
        case .threshold:
            return "Threshold"
        case .tint:
            return "Tint"
        case .transform:
            return "Transform"
        case .twirl:
            return "Twirl"
        case .opticalFlow:
            return "Optical Flow"
        case .filter:
            return "Filter"
        case .warp:
            return "Warp"
        case .pixelate:
            return "Pixelate"
        }
    }
    
    public var typeName: String {
        switch self {
        case .metalEffect:
            return "pix-effect-single-metal"
        case .metalScriptEffect:
            return "pix-effect-single-metal-script"
        default:
            return "pix-effect-single-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    public var type: PIXSingleEffect.Type? {
        switch self {
        case .average:
            return AveragePIX.self
        case .blur:
            return BlurPIX.self
        case .cache:
            return CachePIX.self
        case .channelMix:
            return ChannelMixPIX.self
        case .chromaKey:
            return ChromaKeyPIX.self
        case .clamp:
            return ClampPIX.self
        case .colorConvert:
            return ColorConvertPIX.self
        case .colorCorrect:
            return ColorCorrectPIX.self
        case .colorShift:
            return ColorShiftPIX.self
        case .convert:
            return ConvertPIX.self
        case .cornerPin:
            return CornerPinPIX.self
        case .crop:
            return CropPIX.self
        case .delay:
            return DelayPIX.self
        case .distance:
            return DistancePIX.self
        case .edge:
            return EdgePIX.self
        case .feedback:
            return FeedbackPIX.self
        case .flare:
            return FlarePIX.self
        case .flipFlop:
            return FlipFlopPIX.self
        case .freeze:
            return FreezePIX.self
        case .equalize:
            return EqualizePIX.self
        case .kaleidoscope:
            return KaleidoscopePIX.self
        case .levels:
            return LevelsPIX.self
        case .metalEffect:
            return MetalEffectPIX.self
        case .metalScriptEffect:
            return MetalScriptEffectPIX.self
        case .morph:
            return MorphPIX.self
        case .`nil`:
            return NilPIX.self
        case .quantize:
            return QuantizePIX.self
        case .rainbowBlur:
            return RainbowBlurPIX.self
        case .range:
            return RangePIX.self
        case .reduce:
            return ReducePIX.self
        case .resolution:
            return ResolutionPIX.self
        case .saliency:
            return SaliencyPIX.self
        case .sepia:
            return SepiaPIX.self
        case .sharpen:
            return SharpenPIX.self
        case .slice:
            return SlicePIX.self
        case .slope:
            return SlopePIX.self
        case .threshold:
            return ThresholdPIX.self
        case .tint:
            return TintPIX.self
        case .transform:
            return TransformPIX.self
        case .twirl:
            return TwirlPIX.self
        case .opticalFlow:
            if #available(iOS 14.0, tvOS 14.0, macOS 11.0, *) {
                return OpticalFlowPIX.self
            } else {
                return nil
            }
        case .filter:
            return FilterPIX.self
        case .warp:
            return WarpPIX.self
        case .pixelate:
            return PixelatePIX.self
        }
    }
    
}
