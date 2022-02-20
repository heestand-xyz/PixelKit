
public enum PIXOutputType: String, Codable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case record
    case airPlay
    case streamOut
//    case syphonOut
    
    public var name: String {
        switch self {
        case .record:
            return "Record"
        case .airPlay:
            return "AirPlay"
        case .streamOut:
            return "Stream Out"
//        case .syphonOut:
//            return "Syphon Out"
        }
    }
    
    public var typeName: String {
        switch self {
        case .airPlay:
            return "pix-output-air-play"
        default:
            return "pix-output-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    public var type: PIXOutput.Type? {
        switch self {
        case .record:
            return RecordPIX.self
        #if os(iOS)
        case .airPlay:
            return AirPlayPIX.self
        case .streamOut:
            return StreamOutPIX.self
//        default:
//            return nil
//        #elseif os(macOS)
//        case .syphonOut:
//            return SyphonOutPIX.self
//        default:
//            return nil
        #else
        default:
            return nil
        #endif
        }
    }
    
}
