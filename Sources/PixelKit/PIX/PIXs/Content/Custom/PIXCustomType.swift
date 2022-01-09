
public enum PIXCustomType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case scene
    
    public var name: String {
        switch self {
        case .scene:
            return "Scene"
        }
    }
    
    public var typeName: String {
        "pix-content-custom-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
    }
    
    public var type: PIXCustom.Type {
        switch self {
        case .scene:
            return ScenePIX.self
        }
    }
    
}
