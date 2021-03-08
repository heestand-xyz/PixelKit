
public enum PIXOutputType: String, Codable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case record
    #if os(iOS)
    case airPlay
    case streamOut
    #endif
    
    public var name: String {
        switch self {
        case .record:
            return "Record"
        #if os(iOS)
        case .airPlay:
            return "AirPlay"
        case .streamOut:
            return "Stream Out"
        #endif
        }
    }
    
    public var type: PIXOutput.Type {
        switch self {
        case .record:
            return RecordPIX.self
        #if os(iOS)
        case .airPlay:
            return AirPlayPIX.self
        case .streamOut:
            return StreamOutPIX.self
        #endif
        }
    }
    
}
