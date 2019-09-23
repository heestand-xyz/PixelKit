//
//  PolygonPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-18.
//  Open Source - MIT License
//

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
public struct PolygonUIPIX: View, UIPIX {
    public let pix: PIX
    let polygonPix: PolygonPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }
    public init() {
        polygonPix = PolygonPIX()
        pix = polygonPix
    }
    public func radius(_ bind: Binding<CGFloat>) -> PolygonUIPIX {
        polygonPix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }
}
#endif

public class PolygonPIX: PIXGenerator, Layoutable, PIXAuto {
    
    override open var shader: String { return "contentGeneratorPolygonPIX" }
    
    // MARK: - Public Properties
    
    public var position: LivePoint = .zero
    public var radius: LiveFloat = LiveFloat(0.25, max: 0.5)
    public var rotation: LiveFloat = LiveFloat(0.0, min: -0.5, max: 0.5)
    public var vertexCount: LiveInt = LiveInt(6, min: 3, max: 12)
    public var cornerRadius: LiveFloat = LiveFloat(0.0, max: 0.25)
   
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [radius, position, rotation, vertexCount, super.color, super.bgColor, cornerRadius]
    }
    
    // MARK: - Life Cycle
    
    public required init(res: Res = .auto) {
        super.init(res: res)
        name = "polygon"
    }
    
    // MARK: Layout
    
    public var frame: LiveRect {
        get {
            return LiveRect(center: position, size: LiveSize(scale: radius * 2))
        }
        set {
            reFrame(to: frame)
        }
    }
    public var frameRotation: LiveFloat {
        get { return rotation }
        set { rotation = newValue }
    }
    
    public func reFrame(to frame: LiveRect) {
        position = frame.center
        radius = frame.h / 2
    }
    
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to sourceFrame: LiveRect, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, to: sourceFrame, sourceXAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, to layoutable: Layoutable, _ sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        anchorX(targetXAnchor, to: layoutable.frame, sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to sourceFrame: LiveRect, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, to: sourceFrame, sourceYAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, to layoutable: Layoutable, _ sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        anchorY(targetYAnchor, to: layoutable.frame, sourceYAnchor, constant: constant)
    }
    public func anchorX(_ targetXAnchor: LayoutXAnchor, toBoundAnchor sourceXAnchor: LayoutXAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorX(target: self, targetXAnchor, toBoundAnchor: sourceXAnchor, constant: constant)
    }
    public func anchorY(_ targetYAnchor: LayoutYAnchor, toBoundAnchor sourceYAnchor: LayoutYAnchor, constant: LiveFloat = 0.0) {
        Layout.anchorY(target: self, targetYAnchor, toBoundAnchor: sourceYAnchor, constant: constant)
    }
    
}
