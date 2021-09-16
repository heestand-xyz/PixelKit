
public enum PIXSpriteType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case text
    
    public var name: String {
        switch self {
        case .text:
            return "Text"
        }
    }
    
    public var typeName: String {
        "pix-content-sprite-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
    }
    
    public var type: PIXSprite.Type {
        switch self {
        case .text:
            return TextPIX.self
        }
    }
    
}
