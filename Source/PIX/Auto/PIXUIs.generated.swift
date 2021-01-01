// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(SwiftUI)

import LiveValues
import RenderKit
import SwiftUI


// MARK: - PIXGenerator


// MARK: ArcPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ArcPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let arcpix: ArcPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        arcpix = ArcPIX(at: resolution)
        pix = arcpix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> ArcPIXUI {
        arcpix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> ArcPIXUI {
        arcpix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> ArcPIXUI {
        arcpix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> ArcPIXUI {
        arcpix.color = color
        return self
    }
    // General Property Funcs
    public func fillColor(_ fillColor: Binding<_Color>) -> ArcPIXUI {
        arcpix.fillColor = LiveColor({ fillColor.wrappedValue })
        return self
    }
    public func fillColor(_ fillColor: LiveColor) -> ArcPIXUI {
        arcpix.fillColor = fillColor
        return self
    }
    public func radius(_ radius: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.radius = CGFloat({ radius.wrappedValue })
        return self
    }
    public func radius(_ radius: CGFloat) -> ArcPIXUI {
        arcpix.radius = radius
        return self
    }
    public func angleFrom(_ angleFrom: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleFrom = CGFloat({ angleFrom.wrappedValue })
        return self
    }
    public func angleFrom(_ angleFrom: CGFloat) -> ArcPIXUI {
        arcpix.angleFrom = angleFrom
        return self
    }
    public func angleTo(_ angleTo: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleTo = CGFloat({ angleTo.wrappedValue })
        return self
    }
    public func angleTo(_ angleTo: CGFloat) -> ArcPIXUI {
        arcpix.angleTo = angleTo
        return self
    }
    public func angleOffset(_ angleOffset: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleOffset = CGFloat({ angleOffset.wrappedValue })
        return self
    }
    public func angleOffset(_ angleOffset: CGFloat) -> ArcPIXUI {
        arcpix.angleOffset = angleOffset
        return self
    }
    public func edgeRadius(_ edgeRadius: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.edgeRadius = CGFloat({ edgeRadius.wrappedValue })
        return self
    }
    public func edgeRadius(_ edgeRadius: CGFloat) -> ArcPIXUI {
        arcpix.edgeRadius = edgeRadius
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> ArcPIXUI {
        arcpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> ArcPIXUI {
        arcpix.position = position
        return self
    }
    // Enum Property Funcs
}


// MARK: CirclePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CirclePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let circlepix: CirclePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        circlepix = CirclePIX(at: resolution)
        pix = circlepix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> CirclePIXUI {
        circlepix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> CirclePIXUI {
        circlepix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> CirclePIXUI {
        circlepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> CirclePIXUI {
        circlepix.color = color
        return self
    }
    // General Property Funcs
    public func edgeColor(_ edgeColor: Binding<_Color>) -> CirclePIXUI {
        circlepix.edgeColor = LiveColor({ edgeColor.wrappedValue })
        return self
    }
    public func edgeColor(_ edgeColor: LiveColor) -> CirclePIXUI {
        circlepix.edgeColor = edgeColor
        return self
    }
    public func radius(_ radius: Binding<CGFloat>) -> CirclePIXUI {
        circlepix.radius = CGFloat({ radius.wrappedValue })
        return self
    }
    public func radius(_ radius: CGFloat) -> CirclePIXUI {
        circlepix.radius = radius
        return self
    }
    public func edgeRadius(_ edgeRadius: Binding<CGFloat>) -> CirclePIXUI {
        circlepix.edgeRadius = CGFloat({ edgeRadius.wrappedValue })
        return self
    }
    public func edgeRadius(_ edgeRadius: CGFloat) -> CirclePIXUI {
        circlepix.edgeRadius = edgeRadius
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> CirclePIXUI {
        circlepix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> CirclePIXUI {
        circlepix.position = position
        return self
    }
    // Enum Property Funcs
}


// MARK: ColorPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ColorPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let colorpix: ColorPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        colorpix = ColorPIX(at: resolution)
        pix = colorpix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> ColorPIXUI {
        colorpix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> ColorPIXUI {
        colorpix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> ColorPIXUI {
        colorpix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> ColorPIXUI {
        colorpix.color = color
        return self
    }
    // General Property Funcs
    // Enum Property Funcs
}


// MARK: GradientPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct GradientPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let gradientpix: GradientPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        gradientpix = GradientPIX(at: resolution)
        pix = gradientpix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> GradientPIXUI {
        gradientpix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> GradientPIXUI {
        gradientpix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> GradientPIXUI {
        gradientpix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> GradientPIXUI {
        gradientpix.color = color
        return self
    }
    // General Property Funcs
    public func scale(_ scale: Binding<CGFloat>) -> GradientPIXUI {
        gradientpix.scale = CGFloat({ scale.wrappedValue })
        return self
    }
    public func scale(_ scale: CGFloat) -> GradientPIXUI {
        gradientpix.scale = scale
        return self
    }
    public func offset(_ offset: Binding<CGFloat>) -> GradientPIXUI {
        gradientpix.offset = CGFloat({ offset.wrappedValue })
        return self
    }
    public func offset(_ offset: CGFloat) -> GradientPIXUI {
        gradientpix.offset = offset
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> GradientPIXUI {
        gradientpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> GradientPIXUI {
        gradientpix.position = position
        return self
    }
    // Enum Property Funcs
    public func direction(_ direction: GradientPIX.Direction) -> GradientPIXUI {
        gradientpix.direction = direction
        return self
    }
}


// MARK: LinePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LinePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let linepix: LinePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        linepix = LinePIX(at: resolution)
        pix = linepix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> LinePIXUI {
        linepix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> LinePIXUI {
        linepix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> LinePIXUI {
        linepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> LinePIXUI {
        linepix.color = color
        return self
    }
    // General Property Funcs
    public func scale(_ scale: Binding<CGFloat>) -> LinePIXUI {
        linepix.scale = CGFloat({ scale.wrappedValue })
        return self
    }
    public func scale(_ scale: CGFloat) -> LinePIXUI {
        linepix.scale = scale
        return self
    }
    public func positionFrom(_ positionFrom: Binding<CGPoint>) -> LinePIXUI {
        linepix.positionFrom = CGPoint({ positionFrom.wrappedValue })
        return self
    }
    public func positionFrom(_ positionFrom: CGPoint) -> LinePIXUI {
        linepix.positionFrom = positionFrom
        return self
    }
    public func positionTo(_ positionTo: Binding<CGPoint>) -> LinePIXUI {
        linepix.positionTo = CGPoint({ positionTo.wrappedValue })
        return self
    }
    public func positionTo(_ positionTo: CGPoint) -> LinePIXUI {
        linepix.positionTo = positionTo
        return self
    }
    // Enum Property Funcs
}


// MARK: NoisePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct NoisePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let noisepix: NoisePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        noisepix = NoisePIX(at: resolution)
        pix = noisepix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> NoisePIXUI {
        noisepix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> NoisePIXUI {
        noisepix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> NoisePIXUI {
        noisepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> NoisePIXUI {
        noisepix.color = color
        return self
    }
    // General Property Funcs
    public func colored(_ colored: Binding<Bool>) -> NoisePIXUI {
        noisepix.colored = LiveBool({ colored.wrappedValue })
        return self
    }
    public func colored(_ colored: LiveBool) -> NoisePIXUI {
        noisepix.colored = colored
        return self
    }
    public func random(_ random: Binding<Bool>) -> NoisePIXUI {
        noisepix.random = LiveBool({ random.wrappedValue })
        return self
    }
    public func random(_ random: LiveBool) -> NoisePIXUI {
        noisepix.random = random
        return self
    }
    public func includeAlpha(_ includeAlpha: Binding<Bool>) -> NoisePIXUI {
        noisepix.includeAlpha = LiveBool({ includeAlpha.wrappedValue })
        return self
    }
    public func includeAlpha(_ includeAlpha: LiveBool) -> NoisePIXUI {
        noisepix.includeAlpha = includeAlpha
        return self
    }
    public func zPosition(_ zPosition: Binding<CGFloat>) -> NoisePIXUI {
        noisepix.zPosition = CGFloat({ zPosition.wrappedValue })
        return self
    }
    public func zPosition(_ zPosition: CGFloat) -> NoisePIXUI {
        noisepix.zPosition = zPosition
        return self
    }
    public func zoom(_ zoom: Binding<CGFloat>) -> NoisePIXUI {
        noisepix.zoom = CGFloat({ zoom.wrappedValue })
        return self
    }
    public func zoom(_ zoom: CGFloat) -> NoisePIXUI {
        noisepix.zoom = zoom
        return self
    }
    public func seed(_ seed: Binding<Int>) -> NoisePIXUI {
        noisepix.seed = LiveInt({ seed.wrappedValue })
        return self
    }
    public func seed(_ seed: LiveInt) -> NoisePIXUI {
        noisepix.seed = seed
        return self
    }
    public func octaves(_ octaves: Binding<Int>) -> NoisePIXUI {
        noisepix.octaves = LiveInt({ octaves.wrappedValue })
        return self
    }
    public func octaves(_ octaves: LiveInt) -> NoisePIXUI {
        noisepix.octaves = octaves
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> NoisePIXUI {
        noisepix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> NoisePIXUI {
        noisepix.position = position
        return self
    }
    // Enum Property Funcs
}


// MARK: PolygonPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct PolygonPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let polygonpix: PolygonPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        polygonpix = PolygonPIX(at: resolution)
        pix = polygonpix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> PolygonPIXUI {
        polygonpix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> PolygonPIXUI {
        polygonpix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> PolygonPIXUI {
        polygonpix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> PolygonPIXUI {
        polygonpix.color = color
        return self
    }
    // General Property Funcs
    public func radius(_ radius: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.radius = CGFloat({ radius.wrappedValue })
        return self
    }
    public func radius(_ radius: CGFloat) -> PolygonPIXUI {
        polygonpix.radius = radius
        return self
    }
    public func rotation(_ rotation: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.rotation = CGFloat({ rotation.wrappedValue })
        return self
    }
    public func rotation(_ rotation: CGFloat) -> PolygonPIXUI {
        polygonpix.rotation = rotation
        return self
    }
    public func cornerRadius(_ cornerRadius: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.cornerRadius = CGFloat({ cornerRadius.wrappedValue })
        return self
    }
    public func cornerRadius(_ cornerRadius: CGFloat) -> PolygonPIXUI {
        polygonpix.cornerRadius = cornerRadius
        return self
    }
    public func vertexCount(_ vertexCount: Binding<Int>) -> PolygonPIXUI {
        polygonpix.vertexCount = LiveInt({ vertexCount.wrappedValue })
        return self
    }
    public func vertexCount(_ vertexCount: LiveInt) -> PolygonPIXUI {
        polygonpix.vertexCount = vertexCount
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> PolygonPIXUI {
        polygonpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> PolygonPIXUI {
        polygonpix.position = position
        return self
    }
    // Enum Property Funcs
}


// MARK: RectanglePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RectanglePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let rectanglepix: RectanglePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        rectanglepix = RectanglePIX(at: resolution)
        pix = rectanglepix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> RectanglePIXUI {
        rectanglepix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> RectanglePIXUI {
        rectanglepix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> RectanglePIXUI {
        rectanglepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> RectanglePIXUI {
        rectanglepix.color = color
        return self
    }
    // General Property Funcs
    public func cornerRadius(_ cornerRadius: Binding<CGFloat>) -> RectanglePIXUI {
        rectanglepix.cornerRadius = CGFloat({ cornerRadius.wrappedValue })
        return self
    }
    public func cornerRadius(_ cornerRadius: CGFloat) -> RectanglePIXUI {
        rectanglepix.cornerRadius = cornerRadius
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> RectanglePIXUI {
        rectanglepix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> RectanglePIXUI {
        rectanglepix.position = position
        return self
    }
    public func size(_ size: Binding<CGSize>) -> RectanglePIXUI {
        rectanglepix.size = LiveSize({ size.wrappedValue })
        return self
    }
    public func size(_ size: LiveSize) -> RectanglePIXUI {
        rectanglepix.size = size
        return self
    }
    // Enum Property Funcs
}




// MARK: - PIXMergerEffect


// MARK: BlendPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlendPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let blendpix: BlendPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        blendpix = BlendPIX()
        pix = blendpix
        blendpix.inputA = uiPixA().pix as? (PIX & NODEOut)
        blendpix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    public func bypassTransform(_ bypassTransform: Binding<Bool>) -> BlendPIXUI {
        blendpix.bypassTransform = LiveBool({ bypassTransform.wrappedValue })
        return self
    }
    public func bypassTransform(_ bypassTransform: LiveBool) -> BlendPIXUI {
        blendpix.bypassTransform = bypassTransform
        return self
    }
    public func rotation(_ rotation: Binding<CGFloat>) -> BlendPIXUI {
        blendpix.rotation = CGFloat({ rotation.wrappedValue })
        return self
    }
    public func rotation(_ rotation: CGFloat) -> BlendPIXUI {
        blendpix.rotation = rotation
        return self
    }
    public func scale(_ scale: Binding<CGFloat>) -> BlendPIXUI {
        blendpix.scale = CGFloat({ scale.wrappedValue })
        return self
    }
    public func scale(_ scale: CGFloat) -> BlendPIXUI {
        blendpix.scale = scale
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> BlendPIXUI {
        blendpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> BlendPIXUI {
        blendpix.position = position
        return self
    }
    public func size(_ size: Binding<CGSize>) -> BlendPIXUI {
        blendpix.size = LiveSize({ size.wrappedValue })
        return self
    }
    public func size(_ size: LiveSize) -> BlendPIXUI {
        blendpix.size = size
        return self
    }
    // Enum Property Funcs
}


// MARK: CrossPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CrossPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let crosspix: CrossPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        crosspix = CrossPIX()
        pix = crosspix
        crosspix.inputA = uiPixA().pix as? (PIX & NODEOut)
        crosspix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    public func fraction(_ fraction: Binding<CGFloat>) -> CrossPIXUI {
        crosspix.fraction = CGFloat({ fraction.wrappedValue })
        return self
    }
    public func fraction(_ fraction: CGFloat) -> CrossPIXUI {
        crosspix.fraction = fraction
        return self
    }
    // Enum Property Funcs
}


// MARK: DisplacePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct DisplacePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let displacepix: DisplacePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        displacepix = DisplacePIX()
        pix = displacepix
        displacepix.inputA = uiPixA().pix as? (PIX & NODEOut)
        displacepix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    public func distance(_ distance: Binding<CGFloat>) -> DisplacePIXUI {
        displacepix.distance = CGFloat({ distance.wrappedValue })
        return self
    }
    public func distance(_ distance: CGFloat) -> DisplacePIXUI {
        displacepix.distance = distance
        return self
    }
    public func origin(_ origin: Binding<CGFloat>) -> DisplacePIXUI {
        displacepix.origin = CGFloat({ origin.wrappedValue })
        return self
    }
    public func origin(_ origin: CGFloat) -> DisplacePIXUI {
        displacepix.origin = origin
        return self
    }
    // Enum Property Funcs
}


// MARK: LookupPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LookupPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let lookuppix: LookupPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        lookuppix = LookupPIX()
        pix = lookuppix
        lookuppix.inputA = uiPixA().pix as? (PIX & NODEOut)
        lookuppix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
    public func axis(_ axis: LookupPIX.Axis) -> LookupPIXUI {
        lookuppix.axis = axis
        return self
    }
}


// MARK: LumaBlurPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LumaBlurPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let lumablurpix: LumaBlurPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        lumablurpix = LumaBlurPIX()
        pix = lumablurpix
        lumablurpix.inputA = uiPixA().pix as? (PIX & NODEOut)
        lumablurpix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    public func radius(_ radius: Binding<CGFloat>) -> LumaBlurPIXUI {
        lumablurpix.radius = CGFloat({ radius.wrappedValue })
        return self
    }
    public func radius(_ radius: CGFloat) -> LumaBlurPIXUI {
        lumablurpix.radius = radius
        return self
    }
    public func angle(_ angle: Binding<CGFloat>) -> LumaBlurPIXUI {
        lumablurpix.angle = CGFloat({ angle.wrappedValue })
        return self
    }
    public func angle(_ angle: CGFloat) -> LumaBlurPIXUI {
        lumablurpix.angle = angle
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> LumaBlurPIXUI {
        lumablurpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> LumaBlurPIXUI {
        lumablurpix.position = position
        return self
    }
    // Enum Property Funcs
    public func style(_ style: LumaBlurPIX.LumaBlurStyle) -> LumaBlurPIXUI {
        lumablurpix.style = style
        return self
    }
}


// MARK: LumaLevelsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LumaLevelsPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let lumalevelspix: LumaLevelsPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        lumalevelspix = LumaLevelsPIX()
        pix = lumalevelspix
        lumalevelspix.inputA = uiPixA().pix as? (PIX & NODEOut)
        lumalevelspix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    public func brightness(_ brightness: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.brightness = CGFloat({ brightness.wrappedValue })
        return self
    }
    public func brightness(_ brightness: CGFloat) -> LumaLevelsPIXUI {
        lumalevelspix.brightness = brightness
        return self
    }
    public func darkness(_ darkness: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.darkness = CGFloat({ darkness.wrappedValue })
        return self
    }
    public func darkness(_ darkness: CGFloat) -> LumaLevelsPIXUI {
        lumalevelspix.darkness = darkness
        return self
    }
    public func contrast(_ contrast: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.contrast = CGFloat({ contrast.wrappedValue })
        return self
    }
    public func contrast(_ contrast: CGFloat) -> LumaLevelsPIXUI {
        lumalevelspix.contrast = contrast
        return self
    }
    public func gamma(_ gamma: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.gamma = CGFloat({ gamma.wrappedValue })
        return self
    }
    public func gamma(_ gamma: CGFloat) -> LumaLevelsPIXUI {
        lumalevelspix.gamma = gamma
        return self
    }
    public func opacity(_ opacity: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.opacity = CGFloat({ opacity.wrappedValue })
        return self
    }
    public func opacity(_ opacity: CGFloat) -> LumaLevelsPIXUI {
        lumalevelspix.opacity = opacity
        return self
    }
    // Enum Property Funcs
}


// MARK: RemapPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RemapPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let remappix: RemapPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        remappix = RemapPIX()
        pix = remappix
        remappix.inputA = uiPixA().pix as? (PIX & NODEOut)
        remappix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
}


// MARK: ReorderPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ReorderPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let reorderpix: ReorderPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPixA: () -> (PIXUI), with uiPixB: () -> (PIXUI)) {
        reorderpix = ReorderPIX()
        pix = reorderpix
        reorderpix.inputA = uiPixA().pix as? (PIX & NODEOut)
        reorderpix.inputB = uiPixB().pix as? (PIX & NODEOut)
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
    public func redInput(_ redInput: ReorderPIX.Input) -> ReorderPIXUI {
        reorderpix.redInput = redInput
        return self
    }
    public func redChannel(_ redChannel: ReorderPIX.Channel) -> ReorderPIXUI {
        reorderpix.redChannel = redChannel
        return self
    }
    public func greenInput(_ greenInput: ReorderPIX.Input) -> ReorderPIXUI {
        reorderpix.greenInput = greenInput
        return self
    }
    public func greenChannel(_ greenChannel: ReorderPIX.Channel) -> ReorderPIXUI {
        reorderpix.greenChannel = greenChannel
        return self
    }
    public func blueInput(_ blueInput: ReorderPIX.Input) -> ReorderPIXUI {
        reorderpix.blueInput = blueInput
        return self
    }
    public func blueChannel(_ blueChannel: ReorderPIX.Channel) -> ReorderPIXUI {
        reorderpix.blueChannel = blueChannel
        return self
    }
    public func alphaInput(_ alphaInput: ReorderPIX.Input) -> ReorderPIXUI {
        reorderpix.alphaInput = alphaInput
        return self
    }
    public func alphaChannel(_ alphaChannel: ReorderPIX.Channel) -> ReorderPIXUI {
        reorderpix.alphaChannel = alphaChannel
        return self
    }
}




// MARK: - PIXMultiEffect


// MARK: ArrayPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ArrayPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let arraypix: ArrayPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(@NODEUIMultiEffectBuilder _ uiPixs: () -> ([PIX & NODEOut])) {
        arraypix = ArrayPIX()
        pix = arraypix
        arraypix.inputs = uiPixs()
    }
    // Parent Property Funcs
    // General Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> ArrayPIXUI {
        arraypix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> ArrayPIXUI {
        arraypix.bgColor = bgColor
        return self
    }
    // Enum Property Funcs
}


// MARK: BlendsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlendsPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let blendspix: BlendsPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(@NODEUIMultiEffectBuilder _ uiPixs: () -> ([PIX & NODEOut])) {
        blendspix = BlendsPIX()
        pix = blendspix
        blendspix.inputs = uiPixs()
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
}




// MARK: - PIXSingleEffect


// MARK: BlurPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlurPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let blurpix: BlurPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        blurpix = BlurPIX()
        blurpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = blurpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func radius(_ radius: Binding<CGFloat>) -> BlurPIXUI {
        blurpix.radius = CGFloat({ radius.wrappedValue })
        return self
    }
    public func radius(_ radius: CGFloat) -> BlurPIXUI {
        blurpix.radius = radius
        return self
    }
    public func angle(_ angle: Binding<CGFloat>) -> BlurPIXUI {
        blurpix.angle = CGFloat({ angle.wrappedValue })
        return self
    }
    public func angle(_ angle: CGFloat) -> BlurPIXUI {
        blurpix.angle = angle
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> BlurPIXUI {
        blurpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> BlurPIXUI {
        blurpix.position = position
        return self
    }
    // Enum Property Funcs
    public func style(_ style: BlurPIX.BlurStyle) -> BlurPIXUI {
        blurpix.style = style
        return self
    }
}


// MARK: ChannelMixPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChannelMixPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let channelmixpix: ChannelMixPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        channelmixpix = ChannelMixPIX()
        channelmixpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = channelmixpix
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
}


// MARK: ChromaKeyPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChromaKeyPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let chromakeypix: ChromaKeyPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        chromakeypix = ChromaKeyPIX()
        chromakeypix.input = uiPix().pix as? (PIX & NODEOut)
        pix = chromakeypix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func premultiply(_ premultiply: Binding<Bool>) -> ChromaKeyPIXUI {
        chromakeypix.premultiply = LiveBool({ premultiply.wrappedValue })
        return self
    }
    public func premultiply(_ premultiply: LiveBool) -> ChromaKeyPIXUI {
        chromakeypix.premultiply = premultiply
        return self
    }
    public func keyColor(_ keyColor: Binding<_Color>) -> ChromaKeyPIXUI {
        chromakeypix.keyColor = LiveColor({ keyColor.wrappedValue })
        return self
    }
    public func keyColor(_ keyColor: LiveColor) -> ChromaKeyPIXUI {
        chromakeypix.keyColor = keyColor
        return self
    }
    public func range(_ range: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.range = CGFloat({ range.wrappedValue })
        return self
    }
    public func range(_ range: CGFloat) -> ChromaKeyPIXUI {
        chromakeypix.range = range
        return self
    }
    public func softness(_ softness: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.softness = CGFloat({ softness.wrappedValue })
        return self
    }
    public func softness(_ softness: CGFloat) -> ChromaKeyPIXUI {
        chromakeypix.softness = softness
        return self
    }
    public func edgeDesaturation(_ edgeDesaturation: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.edgeDesaturation = CGFloat({ edgeDesaturation.wrappedValue })
        return self
    }
    public func edgeDesaturation(_ edgeDesaturation: CGFloat) -> ChromaKeyPIXUI {
        chromakeypix.edgeDesaturation = edgeDesaturation
        return self
    }
    // Enum Property Funcs
}


// MARK: ClampPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ClampPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let clamppix: ClampPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        clamppix = ClampPIX()
        clamppix.input = uiPix().pix as? (PIX & NODEOut)
        pix = clamppix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func clampAlpha(_ clampAlpha: Binding<Bool>) -> ClampPIXUI {
        clamppix.clampAlpha = LiveBool({ clampAlpha.wrappedValue })
        return self
    }
    public func clampAlpha(_ clampAlpha: LiveBool) -> ClampPIXUI {
        clamppix.clampAlpha = clampAlpha
        return self
    }
    public func low(_ low: Binding<CGFloat>) -> ClampPIXUI {
        clamppix.low = CGFloat({ low.wrappedValue })
        return self
    }
    public func low(_ low: CGFloat) -> ClampPIXUI {
        clamppix.low = low
        return self
    }
    public func high(_ high: Binding<CGFloat>) -> ClampPIXUI {
        clamppix.high = CGFloat({ high.wrappedValue })
        return self
    }
    public func high(_ high: CGFloat) -> ClampPIXUI {
        clamppix.high = high
        return self
    }
    // Enum Property Funcs
}


// MARK: CornerPinPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CornerPinPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let cornerpinpix: CornerPinPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        cornerpinpix = CornerPinPIX()
        cornerpinpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = cornerpinpix
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
}


// MARK: EdgePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct EdgePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let edgepix: EdgePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        edgepix = EdgePIX()
        edgepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = edgepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func strength(_ strength: Binding<CGFloat>) -> EdgePIXUI {
        edgepix.strength = CGFloat({ strength.wrappedValue })
        return self
    }
    public func strength(_ strength: CGFloat) -> EdgePIXUI {
        edgepix.strength = strength
        return self
    }
    public func distance(_ distance: Binding<CGFloat>) -> EdgePIXUI {
        edgepix.distance = CGFloat({ distance.wrappedValue })
        return self
    }
    public func distance(_ distance: CGFloat) -> EdgePIXUI {
        edgepix.distance = distance
        return self
    }
    // Enum Property Funcs
}


// MARK: FlarePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlarePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let flarepix: FlarePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        flarepix = FlarePIX()
        flarepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = flarepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func color(_ color: Binding<_Color>) -> FlarePIXUI {
        flarepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> FlarePIXUI {
        flarepix.color = color
        return self
    }
    public func scale(_ scale: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.scale = CGFloat({ scale.wrappedValue })
        return self
    }
    public func scale(_ scale: CGFloat) -> FlarePIXUI {
        flarepix.scale = scale
        return self
    }
    public func angle(_ angle: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.angle = CGFloat({ angle.wrappedValue })
        return self
    }
    public func angle(_ angle: CGFloat) -> FlarePIXUI {
        flarepix.angle = angle
        return self
    }
    public func threshold(_ threshold: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.threshold = CGFloat({ threshold.wrappedValue })
        return self
    }
    public func threshold(_ threshold: CGFloat) -> FlarePIXUI {
        flarepix.threshold = threshold
        return self
    }
    public func brightness(_ brightness: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.brightness = CGFloat({ brightness.wrappedValue })
        return self
    }
    public func brightness(_ brightness: CGFloat) -> FlarePIXUI {
        flarepix.brightness = brightness
        return self
    }
    public func gamma(_ gamma: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.gamma = CGFloat({ gamma.wrappedValue })
        return self
    }
    public func gamma(_ gamma: CGFloat) -> FlarePIXUI {
        flarepix.gamma = gamma
        return self
    }
    public func count(_ count: Binding<Int>) -> FlarePIXUI {
        flarepix.count = LiveInt({ count.wrappedValue })
        return self
    }
    public func count(_ count: LiveInt) -> FlarePIXUI {
        flarepix.count = count
        return self
    }
    public func rayRes(_ rayRes: Binding<Int>) -> FlarePIXUI {
        flarepix.rayRes = LiveInt({ rayRes.wrappedValue })
        return self
    }
    public func rayRes(_ rayRes: LiveInt) -> FlarePIXUI {
        flarepix.rayRes = rayRes
        return self
    }
    // Enum Property Funcs
}


// MARK: FlipFlopPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlipFlopPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let flipfloppix: FlipFlopPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        flipfloppix = FlipFlopPIX()
        flipfloppix.input = uiPix().pix as? (PIX & NODEOut)
        pix = flipfloppix
    }
    // Parent Property Funcs
    // General Property Funcs
    // Enum Property Funcs
    public func flip(_ flip: FlipFlopPIX.Flip) -> FlipFlopPIXUI {
        flipfloppix.flip = flip
        return self
    }
    public func flop(_ flop: FlipFlopPIX.Flop) -> FlipFlopPIXUI {
        flipfloppix.flop = flop
        return self
    }
}


// MARK: ColorShiftPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ColorShiftPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let colorshiftpix: ColorShiftPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        colorshiftpix = ColorShiftPIX()
        colorshiftpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = colorshiftpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func hue(_ hue: Binding<CGFloat>) -> ColorShiftPIXUI {
        colorshiftpix.hue = CGFloat({ hue.wrappedValue })
        return self
    }
    public func hue(_ hue: CGFloat) -> ColorShiftPIXUI {
        colorshiftpix.hue = hue
        return self
    }
    public func saturation(_ saturation: Binding<CGFloat>) -> ColorShiftPIXUI {
        colorshiftpix.saturation = CGFloat({ saturation.wrappedValue })
        return self
    }
    public func saturation(_ saturation: CGFloat) -> ColorShiftPIXUI {
        colorshiftpix.saturation = saturation
        return self
    }
    // Enum Property Funcs
}


// MARK: KaleidoscopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct KaleidoscopePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let kaleidoscopepix: KaleidoscopePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        kaleidoscopepix = KaleidoscopePIX()
        kaleidoscopepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = kaleidoscopepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func mirror(_ mirror: Binding<Bool>) -> KaleidoscopePIXUI {
        kaleidoscopepix.mirror = LiveBool({ mirror.wrappedValue })
        return self
    }
    public func mirror(_ mirror: LiveBool) -> KaleidoscopePIXUI {
        kaleidoscopepix.mirror = mirror
        return self
    }
    public func rotation(_ rotation: Binding<CGFloat>) -> KaleidoscopePIXUI {
        kaleidoscopepix.rotation = CGFloat({ rotation.wrappedValue })
        return self
    }
    public func rotation(_ rotation: CGFloat) -> KaleidoscopePIXUI {
        kaleidoscopepix.rotation = rotation
        return self
    }
    public func divisions(_ divisions: Binding<Int>) -> KaleidoscopePIXUI {
        kaleidoscopepix.divisions = LiveInt({ divisions.wrappedValue })
        return self
    }
    public func divisions(_ divisions: LiveInt) -> KaleidoscopePIXUI {
        kaleidoscopepix.divisions = divisions
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> KaleidoscopePIXUI {
        kaleidoscopepix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> KaleidoscopePIXUI {
        kaleidoscopepix.position = position
        return self
    }
    // Enum Property Funcs
}


// MARK: LevelsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LevelsPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let levelspix: LevelsPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        levelspix = LevelsPIX()
        levelspix.input = uiPix().pix as? (PIX & NODEOut)
        pix = levelspix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func inverted(_ inverted: Binding<Bool>) -> LevelsPIXUI {
        levelspix.inverted = LiveBool({ inverted.wrappedValue })
        return self
    }
    public func inverted(_ inverted: LiveBool) -> LevelsPIXUI {
        levelspix.inverted = inverted
        return self
    }
    public func brightness(_ brightness: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.brightness = CGFloat({ brightness.wrappedValue })
        return self
    }
    public func brightness(_ brightness: CGFloat) -> LevelsPIXUI {
        levelspix.brightness = brightness
        return self
    }
    public func darkness(_ darkness: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.darkness = CGFloat({ darkness.wrappedValue })
        return self
    }
    public func darkness(_ darkness: CGFloat) -> LevelsPIXUI {
        levelspix.darkness = darkness
        return self
    }
    public func contrast(_ contrast: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.contrast = CGFloat({ contrast.wrappedValue })
        return self
    }
    public func contrast(_ contrast: CGFloat) -> LevelsPIXUI {
        levelspix.contrast = contrast
        return self
    }
    public func gamma(_ gamma: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.gamma = CGFloat({ gamma.wrappedValue })
        return self
    }
    public func gamma(_ gamma: CGFloat) -> LevelsPIXUI {
        levelspix.gamma = gamma
        return self
    }
    public func opacity(_ opacity: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.opacity = CGFloat({ opacity.wrappedValue })
        return self
    }
    public func opacity(_ opacity: CGFloat) -> LevelsPIXUI {
        levelspix.opacity = opacity
        return self
    }
    // Enum Property Funcs
}


// MARK: QuantizePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct QuantizePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let quantizepix: QuantizePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        quantizepix = QuantizePIX()
        quantizepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = quantizepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func fraction(_ fraction: Binding<CGFloat>) -> QuantizePIXUI {
        quantizepix.fraction = CGFloat({ fraction.wrappedValue })
        return self
    }
    public func fraction(_ fraction: CGFloat) -> QuantizePIXUI {
        quantizepix.fraction = fraction
        return self
    }
    // Enum Property Funcs
}


// MARK: RangePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RangePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let rangepix: RangePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        rangepix = RangePIX()
        rangepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = rangepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func ignoreAlpha(_ ignoreAlpha: Binding<Bool>) -> RangePIXUI {
        rangepix.ignoreAlpha = LiveBool({ ignoreAlpha.wrappedValue })
        return self
    }
    public func ignoreAlpha(_ ignoreAlpha: LiveBool) -> RangePIXUI {
        rangepix.ignoreAlpha = ignoreAlpha
        return self
    }
    public func inLowColor(_ inLowColor: Binding<_Color>) -> RangePIXUI {
        rangepix.inLowColor = LiveColor({ inLowColor.wrappedValue })
        return self
    }
    public func inLowColor(_ inLowColor: LiveColor) -> RangePIXUI {
        rangepix.inLowColor = inLowColor
        return self
    }
    public func inHighColor(_ inHighColor: Binding<_Color>) -> RangePIXUI {
        rangepix.inHighColor = LiveColor({ inHighColor.wrappedValue })
        return self
    }
    public func inHighColor(_ inHighColor: LiveColor) -> RangePIXUI {
        rangepix.inHighColor = inHighColor
        return self
    }
    public func outLowColor(_ outLowColor: Binding<_Color>) -> RangePIXUI {
        rangepix.outLowColor = LiveColor({ outLowColor.wrappedValue })
        return self
    }
    public func outLowColor(_ outLowColor: LiveColor) -> RangePIXUI {
        rangepix.outLowColor = outLowColor
        return self
    }
    public func outHighColor(_ outHighColor: Binding<_Color>) -> RangePIXUI {
        rangepix.outHighColor = LiveColor({ outHighColor.wrappedValue })
        return self
    }
    public func outHighColor(_ outHighColor: LiveColor) -> RangePIXUI {
        rangepix.outHighColor = outHighColor
        return self
    }
    public func inLow(_ inLow: Binding<CGFloat>) -> RangePIXUI {
        rangepix.inLow = CGFloat({ inLow.wrappedValue })
        return self
    }
    public func inLow(_ inLow: CGFloat) -> RangePIXUI {
        rangepix.inLow = inLow
        return self
    }
    public func inHigh(_ inHigh: Binding<CGFloat>) -> RangePIXUI {
        rangepix.inHigh = CGFloat({ inHigh.wrappedValue })
        return self
    }
    public func inHigh(_ inHigh: CGFloat) -> RangePIXUI {
        rangepix.inHigh = inHigh
        return self
    }
    public func outLow(_ outLow: Binding<CGFloat>) -> RangePIXUI {
        rangepix.outLow = CGFloat({ outLow.wrappedValue })
        return self
    }
    public func outLow(_ outLow: CGFloat) -> RangePIXUI {
        rangepix.outLow = outLow
        return self
    }
    public func outHigh(_ outHigh: Binding<CGFloat>) -> RangePIXUI {
        rangepix.outHigh = CGFloat({ outHigh.wrappedValue })
        return self
    }
    public func outHigh(_ outHigh: CGFloat) -> RangePIXUI {
        rangepix.outHigh = outHigh
        return self
    }
    // Enum Property Funcs
}


// MARK: SepiaPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SepiaPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let sepiapix: SepiaPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        sepiapix = SepiaPIX()
        sepiapix.input = uiPix().pix as? (PIX & NODEOut)
        pix = sepiapix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func color(_ color: Binding<_Color>) -> SepiaPIXUI {
        sepiapix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> SepiaPIXUI {
        sepiapix.color = color
        return self
    }
    // Enum Property Funcs
}


// MARK: SharpenPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SharpenPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let sharpenpix: SharpenPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        sharpenpix = SharpenPIX()
        sharpenpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = sharpenpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func contrast(_ contrast: Binding<CGFloat>) -> SharpenPIXUI {
        sharpenpix.contrast = CGFloat({ contrast.wrappedValue })
        return self
    }
    public func contrast(_ contrast: CGFloat) -> SharpenPIXUI {
        sharpenpix.contrast = contrast
        return self
    }
    // Enum Property Funcs
}


// MARK: SlopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SlopePIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let slopepix: SlopePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        slopepix = SlopePIX()
        slopepix.input = uiPix().pix as? (PIX & NODEOut)
        pix = slopepix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func amplitude(_ amplitude: Binding<CGFloat>) -> SlopePIXUI {
        slopepix.amplitude = CGFloat({ amplitude.wrappedValue })
        return self
    }
    public func amplitude(_ amplitude: CGFloat) -> SlopePIXUI {
        slopepix.amplitude = amplitude
        return self
    }
    // Enum Property Funcs
}


// MARK: ThresholdPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ThresholdPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let thresholdpix: ThresholdPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        thresholdpix = ThresholdPIX()
        thresholdpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = thresholdpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func threshold(_ threshold: Binding<CGFloat>) -> ThresholdPIXUI {
        thresholdpix.threshold = CGFloat({ threshold.wrappedValue })
        return self
    }
    public func threshold(_ threshold: CGFloat) -> ThresholdPIXUI {
        thresholdpix.threshold = threshold
        return self
    }
    // Enum Property Funcs
}


// MARK: TransformPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TransformPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let transformpix: TransformPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        transformpix = TransformPIX()
        transformpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = transformpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func rotation(_ rotation: Binding<CGFloat>) -> TransformPIXUI {
        transformpix.rotation = CGFloat({ rotation.wrappedValue })
        return self
    }
    public func rotation(_ rotation: CGFloat) -> TransformPIXUI {
        transformpix.rotation = rotation
        return self
    }
    public func scale(_ scale: Binding<CGFloat>) -> TransformPIXUI {
        transformpix.scale = CGFloat({ scale.wrappedValue })
        return self
    }
    public func scale(_ scale: CGFloat) -> TransformPIXUI {
        transformpix.scale = scale
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> TransformPIXUI {
        transformpix.position = CGPoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: CGPoint) -> TransformPIXUI {
        transformpix.position = position
        return self
    }
    public func size(_ size: Binding<CGSize>) -> TransformPIXUI {
        transformpix.size = LiveSize({ size.wrappedValue })
        return self
    }
    public func size(_ size: LiveSize) -> TransformPIXUI {
        transformpix.size = size
        return self
    }
    // Enum Property Funcs
}


// MARK: TwirlPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TwirlPIXUI: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let twirlpix: TwirlPIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        twirlpix = TwirlPIX()
        twirlpix.input = uiPix().pix as? (PIX & NODEOut)
        pix = twirlpix
    }
    // Parent Property Funcs
    // General Property Funcs
    public func strength(_ strength: Binding<CGFloat>) -> TwirlPIXUI {
        twirlpix.strength = CGFloat({ strength.wrappedValue })
        return self
    }
    public func strength(_ strength: CGFloat) -> TwirlPIXUI {
        twirlpix.strength = strength
        return self
    }
    // Enum Property Funcs
}




#endif
