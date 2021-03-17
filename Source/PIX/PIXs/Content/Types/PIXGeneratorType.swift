
public enum PIXGeneratorType: String, Codable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case arc
    case circle
    case color
    case gradient
    case line
    case metal
    case noise
    case polygon
    case rectangle
    
    public var name: String {
        switch self {
        case .arc:
            return "Arc"
        case .circle:
            return "Circle"
        case .color:
            return "Color"
        case .gradient:
            return "Gradient"
        case .line:
            return "Line"
        case .metal:
            return "Metal"
        case .noise:
            return "Noise"
        case .polygon:
            return "Polygon"
        case .rectangle:
            return "Rectangle"
        }
    }
    
    public var type: PIXGenerator.Type {
        switch self {
        case .arc:
            return ArcPIX.self
        case .circle:
            return CirclePIX.self
        case .color:
            return ColorPIX.self
        case .gradient:
            return GradientPIX.self
        case .line:
            return LinePIX.self
        case .metal:
            return MetalPIX.self
        case .noise:
            return NoisePIX.self
        case .polygon:
            return PolygonPIX.self
        case .rectangle:
            return RectanglePIX.self
        }
    }
    
}
