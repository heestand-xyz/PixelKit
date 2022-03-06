
public enum PIXResourceType: String, Codable, Hashable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case camera
    case image
    case vector
    case video
    case view
    case web
    case screenCapture
    case depthCamera
    case multiCamera
    case paint
    case streamIn
    case maps
    case p5js
    
    public var name: String {
        switch self {
        case .camera:
            return "Camera"
        case .image:
            return "Image"
        case .vector:
            return "Vector"
        case .video:
            return "Video"
        case .view:
            return "View"
        case .web:
            return "Web"
        case .screenCapture:
            return "Screen Capture"
        case .depthCamera:
            return "Depth Camera"
        case .multiCamera:
            return "Multi Camera"
        case .paint:
            return "Paint"
        case .streamIn:
            return "Stream In"
        case .maps:
            return "Earth"
        case .p5js:
            return "p5.js"
        }
    }
    
    public var typeName: String {
        switch self {
        case .maps:
            return "pix-content-resource-maps"
        case .p5js:
            return "pix-content-resource-p5js"
        default:
            return "pix-content-resource-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"
        }
    }
    
    public var type: PIXResource.Type? {
        switch self {
        case .image:
            return ImagePIX.self
        #if !os(tvOS)
        case .camera:
            return CameraPIX.self
        case .vector:
            return VectorPIX.self
        case .web:
            return WebPIX.self
        #endif
        case .video:
            return VideoPIX.self
        case .view:
            return ViewPIX.self
        #if os(macOS)
        case .screenCapture:
            return ScreenCapturePIX.self
        #endif
        #if os(iOS)
        case .depthCamera:
            return DepthCameraPIX.self
        case .multiCamera:
            return MultiCameraPIX.self
        #if !targetEnvironment(simulator)
        case .paint:
            return PaintPIX.self
        #endif
        case .streamIn:
            return StreamInPIX.self
        #endif
        case .maps:
            return EarthPIX.self
        #if !os(tvOS)
        case .p5js:
            return P5JSPIX.self
        #endif
        default:
            return nil
        }
    }
    
}
