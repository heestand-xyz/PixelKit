//
//  Created by Anton Heestand on 2021-10-03.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
import RenderKit
import Resolution
import PixelColor
import MapKit
import CoreGraphics
import TextureMap

final public class EarthPIX: PIXResource, NODEResolution, PIXViewable {
    
    public override var information: String? {
        """
        Coordinate and span are in degrees.
        """
    }
    
    public typealias Model = EarthPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { return "contentResourcePIX" }
    
    private var rendering: Bool = false
    private var queued: Bool = false
    
    public enum MapType: String, Enumable {
        case standard
        case mutedStandard
        case satellite
        case satelliteFlyover
        case hybrid
        case hybridFlyover
        public var index: Int {
            switch self {
            case .standard:
                return 0
            case .mutedStandard:
                return 1
            case .satellite:
                return 2
            case .satelliteFlyover:
                return 3
            case .hybrid:
                return 4
            case .hybridFlyover:
                return 5
            }
        }
        public var name: String {
            switch self {
            case .standard:
                return "Standard"
            case .mutedStandard:
                return "Muted Standard"
            case .satellite:
                return "Satellite"
            case .satelliteFlyover:
                return "Satellite Flyover"
            case .hybrid:
                return "Hybrid"
            case .hybridFlyover:
                return "Hybrid Flyover"
            }
        }
        public var typeName: String {
            rawValue
        }
        var mapType: MKMapType {
            switch self {
            case .standard:
                return .standard
            case .mutedStandard:
                return .mutedStandard
            case .satellite:
                return .satellite
            case .satelliteFlyover:
                return .satelliteFlyover
            case .hybrid:
                return .hybrid
            case .hybridFlyover:
                return .hybridFlyover
            }
        }
    }
    
    // MARK: - Properties
    
    @LiveResolution("resolution") public var resolution: Resolution = ._128
    @LiveEnum("mapType") public var mapType: MapType = .standard
    @LivePoint("coordinate", range: -90...90, increment: 45) public var coordinate: CGPoint = .zero
    @LiveFloat("span", range: 0...180, increment: 45) public var span: CGFloat = 90
    @LiveBool("showsBuildings") public var showsBuildings: Bool = false
    @LiveBool("showsPointsOfInterest") public var showsPointsOfInterest: Bool = false
    @LiveBool("darkMode") public var darkMode: Bool = false

    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_resolution, _mapType, _coordinate, _span, _showsBuildings, _showsPointsOfInterest, _darkMode]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public init(at resolution: Resolution = .auto) {
        let model = Model(resolution: resolution)
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        
        setNeedsBuffer()
        
        PixelKit.main.render.listenToFrames { [weak self] in
            guard let self = self else { return }
            if self.queued {
                guard !self.rendering else { return }
                self.setNeedsBuffer()
                self.queued = false
            }
        }
        
    }
    
    // MARK: - Live Model
    
    public override func modelUpdateLive() {
        super.modelUpdateLive()
        
        resolution = model.resolution
        mapType = model.mapType
        coordinate = model.coordinate
        span = model.span
        showsBuildings = model.showsBuildings
        showsPointsOfInterest = model.showsPointsOfInterest
        darkMode = model.darkMode
        
        super.modelUpdateLiveDone()
    }
    
    public override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.resolution = resolution
        model.mapType = mapType
        model.coordinate = coordinate
        model.span = span
        model.showsBuildings = showsBuildings
        model.showsPointsOfInterest = showsPointsOfInterest
        model.darkMode = darkMode
        
        super.liveUpdateModelDone()
    }
    
    // MARK: Live
    
    public override func liveValueChanged() {
        super.liveValueChanged()
        
        if !rendering {
            setNeedsBuffer()
        } else {
            queued = true
        }
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        
        PixelKit.main.logger.log(node: self, .info, .resource, "Set Needs Buffer.")

        let mapSnapshotOptions = MKMapSnapshotter.Options()

        guard span > 0.0 else { return }
        let center = CLLocationCoordinate2D(latitude: coordinate.y, longitude: coordinate.x)
        let span = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        let region = MKCoordinateRegion(center: center, span: span)
        guard region.isValid else { return }
        mapSnapshotOptions.region = region

        mapSnapshotOptions.size = CGSize(width: resolution.width / Resolution.scale,
                                         height: resolution.height / Resolution.scale)

        mapSnapshotOptions.showsBuildings = showsBuildings
        
        mapSnapshotOptions.pointOfInterestFilter = showsPointsOfInterest ? .includingAll : .excludingAll
        
        mapSnapshotOptions.mapType = mapType.mapType
        
        if darkMode {
            #if os(macOS)
            mapSnapshotOptions.appearance = NSAppearance(named: .darkAqua)
            #else
            mapSnapshotOptions.traitCollection = UITraitCollection(userInterfaceStyle: .dark)
            #endif
        } else {
            #if os(macOS)
            mapSnapshotOptions.appearance = NSAppearance(named: .aqua)
            #else
            mapSnapshotOptions.traitCollection = UITraitCollection(userInterfaceStyle: .light)
            #endif
        }

        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        rendering = true

        snapShotter.start() { [weak self] snapshot, error in
            
            if let error = error {
                PixelKit.main.logger.log(node: self, .error, .resource, "Snapshot Failed.", e: error)
                self?.rendering = false
                return
            }
            
            guard let snapshot = snapshot else {
                PixelKit.main.logger.log(node: self, .error, .resource, "Snapshot Not Found.", e: error)
                self?.rendering = false
                return
            }
            
            var image: UINSImage = snapshot.image
            
            #if os(macOS)
            guard let data: Data = image.pngData() else {
                PixelKit.main.logger.log(node: self, .error, .resource, "Image Data Failed to Encode.")
                self?.rendering = false
                return
            }
            guard let dataImage = NSImage(data: data) else {
                PixelKit.main.logger.log(node: self, .error, .resource, "Image Data Failed to Decode.")
                self?.rendering = false
                return
            }
            image = dataImage
            #endif
            
            do {
                
                let texture: MTLTexture = try TextureMap.texture(image: image)
                
                self?.resourceTexture = texture
                
                self?.applyResolution { [weak self] in
                    self?.render()
                    self?.rendering = false
                }
                
            } catch {
                PixelKit.main.logger.log(node: self, .error, .resource, "Texture Load Failed.", e: error)
                self?.rendering = false
            }
        }
    }
}
