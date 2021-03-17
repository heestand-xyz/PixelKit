
public enum PIXResourceType: String, Codable, CaseIterable, Identifiable {
    
    public var id: String { rawValue }
    
    case camera
    case image
    case vector
    case video
    case view
    case web
    #if os(macOS)
    case screenCapture
    #endif
    #if os(iOS)
    case depthCamera
    case multiCamera
    case paint
    case streamIn
    #endif
    
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
        #if os(macOS)
        case .screenCapture:
            return "Screen Capture"
        #endif
        #if os(iOS)
        case .depthCamera:
            return "Depth Camera"
        case .multiCamera:
            return "Multi Camera"
        case .paint:
            return "Paint"
        case .streamIn:
            return "Stream In"
        #endif
        }
    }
    
    public var type: PIXResource.Type {
        switch self {
        case .camera:
            return CameraPIX.self
        case .image:
            return ImagePIX.self
        case .vector:
            return VectorPIX.self
        case .video:
            return VideoPIX.self
        case .view:
            return ViewPIX.self
        case .web:
            return WebPIX.self
        #if os(macOS)
        case .screenCapture:
            return ScreenCapturePIX.self
        #endif
        #if os(iOS)
        case .depthCamera:
            return DepthCameraPIX.self
        case .multiCamera:
            return MultiCameraPIX.self
        case .paint:
            return PaintPIX.self
        case .streamIn:
            return StreamInPIX.self
        #endif
        }
    }
    
}
