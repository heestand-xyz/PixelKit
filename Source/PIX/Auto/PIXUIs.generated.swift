// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(SwiftUI)

import SwiftUI


// MARK: - PIXGenerator


// MARK: ArcPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ArcPIXUI: View, PIXUI {

    public let pix: PIX
    let arcpix: ArcPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        arcpix = ArcPIX(res: res)
        pix = arcpix
    }
    public func bgColor(_ binding: Binding<_Color>) -> ArcPIXUI {
        arcpix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> ArcPIXUI {
        arcpix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> ArcPIXUI {
        arcpix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> ArcPIXUI {
        arcpix.color = liveValue
        return self
    }
    public func fillColor(_ binding: Binding<_Color>) -> ArcPIXUI {
        arcpix.fillColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func fillColor(_ liveValue: LiveColor) -> ArcPIXUI {
        arcpix.fillColor = liveValue
        return self
    }
    public func radius(_ binding: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.radius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func radius(_ liveValue: LiveFloat) -> ArcPIXUI {
        arcpix.radius = liveValue
        return self
    }
    public func angleFrom(_ binding: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleFrom = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angleFrom(_ liveValue: LiveFloat) -> ArcPIXUI {
        arcpix.angleFrom = liveValue
        return self
    }
    public func angleTo(_ binding: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleTo = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angleTo(_ liveValue: LiveFloat) -> ArcPIXUI {
        arcpix.angleTo = liveValue
        return self
    }
    public func angleOffset(_ binding: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.angleOffset = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angleOffset(_ liveValue: LiveFloat) -> ArcPIXUI {
        arcpix.angleOffset = liveValue
        return self
    }
    public func edgeRadius(_ binding: Binding<CGFloat>) -> ArcPIXUI {
        arcpix.edgeRadius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func edgeRadius(_ liveValue: LiveFloat) -> ArcPIXUI {
        arcpix.edgeRadius = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> ArcPIXUI {
        arcpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> ArcPIXUI {
        arcpix.position = liveValue
        return self
    }
}


// MARK: CirclePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CirclePIXUI: View, PIXUI {

    public let pix: PIX
    let circlepix: CirclePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        circlepix = CirclePIX(res: res)
        pix = circlepix
    }
    public func bgColor(_ binding: Binding<_Color>) -> CirclePIXUI {
        circlepix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> CirclePIXUI {
        circlepix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> CirclePIXUI {
        circlepix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> CirclePIXUI {
        circlepix.color = liveValue
        return self
    }
    public func edgeColor(_ binding: Binding<_Color>) -> CirclePIXUI {
        circlepix.edgeColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func edgeColor(_ liveValue: LiveColor) -> CirclePIXUI {
        circlepix.edgeColor = liveValue
        return self
    }
    public func radius(_ binding: Binding<CGFloat>) -> CirclePIXUI {
        circlepix.radius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func radius(_ liveValue: LiveFloat) -> CirclePIXUI {
        circlepix.radius = liveValue
        return self
    }
    public func edgeRadius(_ binding: Binding<CGFloat>) -> CirclePIXUI {
        circlepix.edgeRadius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func edgeRadius(_ liveValue: LiveFloat) -> CirclePIXUI {
        circlepix.edgeRadius = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> CirclePIXUI {
        circlepix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> CirclePIXUI {
        circlepix.position = liveValue
        return self
    }
}


// MARK: ColorPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ColorPIXUI: View, PIXUI {

    public let pix: PIX
    let colorpix: ColorPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        colorpix = ColorPIX(res: res)
        pix = colorpix
    }
    public func bgColor(_ binding: Binding<_Color>) -> ColorPIXUI {
        colorpix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> ColorPIXUI {
        colorpix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> ColorPIXUI {
        colorpix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> ColorPIXUI {
        colorpix.color = liveValue
        return self
    }
}


// MARK: GradientPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct GradientPIXUI: View, PIXUI {

    public let pix: PIX
    let gradientpix: GradientPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        gradientpix = GradientPIX(res: res)
        pix = gradientpix
    }
    public func bgColor(_ binding: Binding<_Color>) -> GradientPIXUI {
        gradientpix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> GradientPIXUI {
        gradientpix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> GradientPIXUI {
        gradientpix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> GradientPIXUI {
        gradientpix.color = liveValue
        return self
    }
    public func scale(_ binding: Binding<CGFloat>) -> GradientPIXUI {
        gradientpix.scale = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func scale(_ liveValue: LiveFloat) -> GradientPIXUI {
        gradientpix.scale = liveValue
        return self
    }
    public func offset(_ binding: Binding<CGFloat>) -> GradientPIXUI {
        gradientpix.offset = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func offset(_ liveValue: LiveFloat) -> GradientPIXUI {
        gradientpix.offset = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> GradientPIXUI {
        gradientpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> GradientPIXUI {
        gradientpix.position = liveValue
        return self
    }
}


// MARK: LinePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LinePIXUI: View, PIXUI {

    public let pix: PIX
    let linepix: LinePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        linepix = LinePIX(res: res)
        pix = linepix
    }
    public func bgColor(_ binding: Binding<_Color>) -> LinePIXUI {
        linepix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> LinePIXUI {
        linepix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> LinePIXUI {
        linepix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> LinePIXUI {
        linepix.color = liveValue
        return self
    }
    public func scale(_ binding: Binding<CGFloat>) -> LinePIXUI {
        linepix.scale = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func scale(_ liveValue: LiveFloat) -> LinePIXUI {
        linepix.scale = liveValue
        return self
    }
    public func positionFrom(_ binding: Binding<CGPoint>) -> LinePIXUI {
        linepix.positionFrom = LivePoint({ binding.wrappedValue })
        return self
    }
    public func positionFrom(_ liveValue: LivePoint) -> LinePIXUI {
        linepix.positionFrom = liveValue
        return self
    }
    public func positionTo(_ binding: Binding<CGPoint>) -> LinePIXUI {
        linepix.positionTo = LivePoint({ binding.wrappedValue })
        return self
    }
    public func positionTo(_ liveValue: LivePoint) -> LinePIXUI {
        linepix.positionTo = liveValue
        return self
    }
}


// MARK: NoisePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct NoisePIXUI: View, PIXUI {

    public let pix: PIX
    let noisepix: NoisePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        noisepix = NoisePIX(res: res)
        pix = noisepix
    }
    public func bgColor(_ binding: Binding<_Color>) -> NoisePIXUI {
        noisepix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> NoisePIXUI {
        noisepix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> NoisePIXUI {
        noisepix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> NoisePIXUI {
        noisepix.color = liveValue
        return self
    }
    public func colored(_ binding: Binding<Bool>) -> NoisePIXUI {
        noisepix.colored = LiveBool({ binding.wrappedValue })
        return self
    }
    public func colored(_ liveValue: LiveBool) -> NoisePIXUI {
        noisepix.colored = liveValue
        return self
    }
    public func random(_ binding: Binding<Bool>) -> NoisePIXUI {
        noisepix.random = LiveBool({ binding.wrappedValue })
        return self
    }
    public func random(_ liveValue: LiveBool) -> NoisePIXUI {
        noisepix.random = liveValue
        return self
    }
    public func includeAlpha(_ binding: Binding<Bool>) -> NoisePIXUI {
        noisepix.includeAlpha = LiveBool({ binding.wrappedValue })
        return self
    }
    public func includeAlpha(_ liveValue: LiveBool) -> NoisePIXUI {
        noisepix.includeAlpha = liveValue
        return self
    }
    public func zPosition(_ binding: Binding<CGFloat>) -> NoisePIXUI {
        noisepix.zPosition = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func zPosition(_ liveValue: LiveFloat) -> NoisePIXUI {
        noisepix.zPosition = liveValue
        return self
    }
    public func zoom(_ binding: Binding<CGFloat>) -> NoisePIXUI {
        noisepix.zoom = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func zoom(_ liveValue: LiveFloat) -> NoisePIXUI {
        noisepix.zoom = liveValue
        return self
    }
    public func seed(_ binding: Binding<Int>) -> NoisePIXUI {
        noisepix.seed = LiveInt({ binding.wrappedValue })
        return self
    }
    public func seed(_ liveValue: LiveInt) -> NoisePIXUI {
        noisepix.seed = liveValue
        return self
    }
    public func octaves(_ binding: Binding<Int>) -> NoisePIXUI {
        noisepix.octaves = LiveInt({ binding.wrappedValue })
        return self
    }
    public func octaves(_ liveValue: LiveInt) -> NoisePIXUI {
        noisepix.octaves = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> NoisePIXUI {
        noisepix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> NoisePIXUI {
        noisepix.position = liveValue
        return self
    }
}


// MARK: PolygonPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct PolygonPIXUI: View, PIXUI {

    public let pix: PIX
    let polygonpix: PolygonPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        polygonpix = PolygonPIX(res: res)
        pix = polygonpix
    }
    public func bgColor(_ binding: Binding<_Color>) -> PolygonPIXUI {
        polygonpix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> PolygonPIXUI {
        polygonpix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> PolygonPIXUI {
        polygonpix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> PolygonPIXUI {
        polygonpix.color = liveValue
        return self
    }
    public func radius(_ binding: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.radius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func radius(_ liveValue: LiveFloat) -> PolygonPIXUI {
        polygonpix.radius = liveValue
        return self
    }
    public func rotation(_ binding: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.rotation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func rotation(_ liveValue: LiveFloat) -> PolygonPIXUI {
        polygonpix.rotation = liveValue
        return self
    }
    public func cornerRadius(_ binding: Binding<CGFloat>) -> PolygonPIXUI {
        polygonpix.cornerRadius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func cornerRadius(_ liveValue: LiveFloat) -> PolygonPIXUI {
        polygonpix.cornerRadius = liveValue
        return self
    }
    public func vertexCount(_ binding: Binding<Int>) -> PolygonPIXUI {
        polygonpix.vertexCount = LiveInt({ binding.wrappedValue })
        return self
    }
    public func vertexCount(_ liveValue: LiveInt) -> PolygonPIXUI {
        polygonpix.vertexCount = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> PolygonPIXUI {
        polygonpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> PolygonPIXUI {
        polygonpix.position = liveValue
        return self
    }
}


// MARK: RectanglePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RectanglePIXUI: View, PIXUI {

    public let pix: PIX
    let rectanglepix: RectanglePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(res: PIX.Res = .auto) {
        rectanglepix = RectanglePIX(res: res)
        pix = rectanglepix
    }
    public func bgColor(_ binding: Binding<_Color>) -> RectanglePIXUI {
        rectanglepix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> RectanglePIXUI {
        rectanglepix.bgColor = liveValue
        return self
    }
    public func color(_ binding: Binding<_Color>) -> RectanglePIXUI {
        rectanglepix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> RectanglePIXUI {
        rectanglepix.color = liveValue
        return self
    }
    public func cornerRadius(_ binding: Binding<CGFloat>) -> RectanglePIXUI {
        rectanglepix.cornerRadius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func cornerRadius(_ liveValue: LiveFloat) -> RectanglePIXUI {
        rectanglepix.cornerRadius = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> RectanglePIXUI {
        rectanglepix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> RectanglePIXUI {
        rectanglepix.position = liveValue
        return self
    }
    public func size(_ binding: Binding<CGSize>) -> RectanglePIXUI {
        rectanglepix.size = LiveSize({ binding.wrappedValue })
        return self
    }
    public func size(_ liveValue: LiveSize) -> RectanglePIXUI {
        rectanglepix.size = liveValue
        return self
    }
}




// MARK: - PIXMergerEffect


// MARK: BlendPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlendPIXUI: View, PIXUI {

    public let pix: PIX
    let blendpix: BlendPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        blendpix = BlendPIX()
        pix = blendpix
        let uiPixAB = uiPixAB()
        blendpix.inPixA = uiPixAB.0
        blendpix.inPixB = uiPixAB.1
    }
    public func bypassTransform(_ binding: Binding<Bool>) -> BlendPIXUI {
        blendpix.bypassTransform = LiveBool({ binding.wrappedValue })
        return self
    }
    public func bypassTransform(_ liveValue: LiveBool) -> BlendPIXUI {
        blendpix.bypassTransform = liveValue
        return self
    }
    public func rotation(_ binding: Binding<CGFloat>) -> BlendPIXUI {
        blendpix.rotation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func rotation(_ liveValue: LiveFloat) -> BlendPIXUI {
        blendpix.rotation = liveValue
        return self
    }
    public func scale(_ binding: Binding<CGFloat>) -> BlendPIXUI {
        blendpix.scale = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func scale(_ liveValue: LiveFloat) -> BlendPIXUI {
        blendpix.scale = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> BlendPIXUI {
        blendpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> BlendPIXUI {
        blendpix.position = liveValue
        return self
    }
    public func size(_ binding: Binding<CGSize>) -> BlendPIXUI {
        blendpix.size = LiveSize({ binding.wrappedValue })
        return self
    }
    public func size(_ liveValue: LiveSize) -> BlendPIXUI {
        blendpix.size = liveValue
        return self
    }
}


// MARK: CrossPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CrossPIXUI: View, PIXUI {

    public let pix: PIX
    let crosspix: CrossPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        crosspix = CrossPIX()
        pix = crosspix
        let uiPixAB = uiPixAB()
        crosspix.inPixA = uiPixAB.0
        crosspix.inPixB = uiPixAB.1
    }
    public func fraction(_ binding: Binding<CGFloat>) -> CrossPIXUI {
        crosspix.fraction = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func fraction(_ liveValue: LiveFloat) -> CrossPIXUI {
        crosspix.fraction = liveValue
        return self
    }
}


// MARK: DisplacePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct DisplacePIXUI: View, PIXUI {

    public let pix: PIX
    let displacepix: DisplacePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        displacepix = DisplacePIX()
        pix = displacepix
        let uiPixAB = uiPixAB()
        displacepix.inPixA = uiPixAB.0
        displacepix.inPixB = uiPixAB.1
    }
    public func distance(_ binding: Binding<CGFloat>) -> DisplacePIXUI {
        displacepix.distance = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func distance(_ liveValue: LiveFloat) -> DisplacePIXUI {
        displacepix.distance = liveValue
        return self
    }
    public func origin(_ binding: Binding<CGFloat>) -> DisplacePIXUI {
        displacepix.origin = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func origin(_ liveValue: LiveFloat) -> DisplacePIXUI {
        displacepix.origin = liveValue
        return self
    }
}


// MARK: LookupPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LookupPIXUI: View, PIXUI {

    public let pix: PIX
    let lookuppix: LookupPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        lookuppix = LookupPIX()
        pix = lookuppix
        let uiPixAB = uiPixAB()
        lookuppix.inPixA = uiPixAB.0
        lookuppix.inPixB = uiPixAB.1
    }
}


// MARK: LumaBlurPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LumaBlurPIXUI: View, PIXUI {

    public let pix: PIX
    let lumablurpix: LumaBlurPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        lumablurpix = LumaBlurPIX()
        pix = lumablurpix
        let uiPixAB = uiPixAB()
        lumablurpix.inPixA = uiPixAB.0
        lumablurpix.inPixB = uiPixAB.1
    }
    public func radius(_ binding: Binding<CGFloat>) -> LumaBlurPIXUI {
        lumablurpix.radius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func radius(_ liveValue: LiveFloat) -> LumaBlurPIXUI {
        lumablurpix.radius = liveValue
        return self
    }
    public func angle(_ binding: Binding<CGFloat>) -> LumaBlurPIXUI {
        lumablurpix.angle = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angle(_ liveValue: LiveFloat) -> LumaBlurPIXUI {
        lumablurpix.angle = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> LumaBlurPIXUI {
        lumablurpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> LumaBlurPIXUI {
        lumablurpix.position = liveValue
        return self
    }
}


// MARK: LumaLevelsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LumaLevelsPIXUI: View, PIXUI {

    public let pix: PIX
    let lumalevelspix: LumaLevelsPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        lumalevelspix = LumaLevelsPIX()
        pix = lumalevelspix
        let uiPixAB = uiPixAB()
        lumalevelspix.inPixA = uiPixAB.0
        lumalevelspix.inPixB = uiPixAB.1
    }
    public func brightness(_ binding: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.brightness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func brightness(_ liveValue: LiveFloat) -> LumaLevelsPIXUI {
        lumalevelspix.brightness = liveValue
        return self
    }
    public func darkness(_ binding: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.darkness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func darkness(_ liveValue: LiveFloat) -> LumaLevelsPIXUI {
        lumalevelspix.darkness = liveValue
        return self
    }
    public func contrast(_ binding: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.contrast = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func contrast(_ liveValue: LiveFloat) -> LumaLevelsPIXUI {
        lumalevelspix.contrast = liveValue
        return self
    }
    public func gamma(_ binding: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.gamma = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func gamma(_ liveValue: LiveFloat) -> LumaLevelsPIXUI {
        lumalevelspix.gamma = liveValue
        return self
    }
    public func opacity(_ binding: Binding<CGFloat>) -> LumaLevelsPIXUI {
        lumalevelspix.opacity = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func opacity(_ liveValue: LiveFloat) -> LumaLevelsPIXUI {
        lumalevelspix.opacity = liveValue
        return self
    }
}


// MARK: RemapPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RemapPIXUI: View, PIXUI {

    public let pix: PIX
    let remappix: RemapPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        remappix = RemapPIX()
        pix = remappix
        let uiPixAB = uiPixAB()
        remappix.inPixA = uiPixAB.0
        remappix.inPixB = uiPixAB.1
    }
}


// MARK: ReorderPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ReorderPIXUI: View, PIXUI {

    public let pix: PIX
    let reorderpix: ReorderPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMergerEffectBuilder _ uiPixAB: () -> ((PIX & PIXOut)?, (PIX & PIXOut)?)) {
        reorderpix = ReorderPIX()
        pix = reorderpix
        let uiPixAB = uiPixAB()
        reorderpix.inPixA = uiPixAB.0
        reorderpix.inPixB = uiPixAB.1
    }
}




// MARK: - PIXMultiEffect


// MARK: ArrayPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ArrayPIXUI: View, PIXUI {

    public let pix: PIX
    let arraypix: ArrayPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMultiEffectBuilder _ uiPixs: () -> ([PIX & PIXOut])) {
        arraypix = ArrayPIX()
        pix = arraypix
        arraypix.inPixs = uiPixs()
    }
    public func bgColor(_ binding: Binding<_Color>) -> ArrayPIXUI {
        arraypix.bgColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func bgColor(_ liveValue: LiveColor) -> ArrayPIXUI {
        arraypix.bgColor = liveValue
        return self
    }
}


// MARK: BlendsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlendsPIXUI: View, PIXUI {

    public let pix: PIX
    let blendspix: BlendsPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(@PIXUIMultiEffectBuilder _ uiPixs: () -> ([PIX & PIXOut])) {
        blendspix = BlendsPIX()
        pix = blendspix
        blendspix.inPixs = uiPixs()
    }
}




// MARK: - PIXSingleEffect


// MARK: BlurPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlurPIXUI: View, PIXUI {

    public let pix: PIX
    let blurpix: BlurPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        blurpix = BlurPIX()
        blurpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = blurpix
    }
    public func radius(_ binding: Binding<CGFloat>) -> BlurPIXUI {
        blurpix.radius = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func radius(_ liveValue: LiveFloat) -> BlurPIXUI {
        blurpix.radius = liveValue
        return self
    }
    public func angle(_ binding: Binding<CGFloat>) -> BlurPIXUI {
        blurpix.angle = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angle(_ liveValue: LiveFloat) -> BlurPIXUI {
        blurpix.angle = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> BlurPIXUI {
        blurpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> BlurPIXUI {
        blurpix.position = liveValue
        return self
    }
}


// MARK: ChannelMixPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChannelMixPIXUI: View, PIXUI {

    public let pix: PIX
    let channelmixpix: ChannelMixPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        channelmixpix = ChannelMixPIX()
        channelmixpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = channelmixpix
    }
}


// MARK: ChromaKeyPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChromaKeyPIXUI: View, PIXUI {

    public let pix: PIX
    let chromakeypix: ChromaKeyPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        chromakeypix = ChromaKeyPIX()
        chromakeypix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = chromakeypix
    }
    public func premultiply(_ binding: Binding<Bool>) -> ChromaKeyPIXUI {
        chromakeypix.premultiply = LiveBool({ binding.wrappedValue })
        return self
    }
    public func premultiply(_ liveValue: LiveBool) -> ChromaKeyPIXUI {
        chromakeypix.premultiply = liveValue
        return self
    }
    public func keyColor(_ binding: Binding<_Color>) -> ChromaKeyPIXUI {
        chromakeypix.keyColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func keyColor(_ liveValue: LiveColor) -> ChromaKeyPIXUI {
        chromakeypix.keyColor = liveValue
        return self
    }
    public func range(_ binding: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.range = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func range(_ liveValue: LiveFloat) -> ChromaKeyPIXUI {
        chromakeypix.range = liveValue
        return self
    }
    public func softness(_ binding: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.softness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func softness(_ liveValue: LiveFloat) -> ChromaKeyPIXUI {
        chromakeypix.softness = liveValue
        return self
    }
    public func edgeDesaturation(_ binding: Binding<CGFloat>) -> ChromaKeyPIXUI {
        chromakeypix.edgeDesaturation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func edgeDesaturation(_ liveValue: LiveFloat) -> ChromaKeyPIXUI {
        chromakeypix.edgeDesaturation = liveValue
        return self
    }
}


// MARK: ClampPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ClampPIXUI: View, PIXUI {

    public let pix: PIX
    let clamppix: ClampPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        clamppix = ClampPIX()
        clamppix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = clamppix
    }
    public func clampAlpha(_ binding: Binding<Bool>) -> ClampPIXUI {
        clamppix.clampAlpha = LiveBool({ binding.wrappedValue })
        return self
    }
    public func clampAlpha(_ liveValue: LiveBool) -> ClampPIXUI {
        clamppix.clampAlpha = liveValue
        return self
    }
    public func low(_ binding: Binding<CGFloat>) -> ClampPIXUI {
        clamppix.low = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func low(_ liveValue: LiveFloat) -> ClampPIXUI {
        clamppix.low = liveValue
        return self
    }
    public func high(_ binding: Binding<CGFloat>) -> ClampPIXUI {
        clamppix.high = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func high(_ liveValue: LiveFloat) -> ClampPIXUI {
        clamppix.high = liveValue
        return self
    }
}


// MARK: CornerPinPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CornerPinPIXUI: View, PIXUI {

    public let pix: PIX
    let cornerpinpix: CornerPinPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        cornerpinpix = CornerPinPIX()
        cornerpinpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = cornerpinpix
    }
}


// MARK: EdgePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct EdgePIXUI: View, PIXUI {

    public let pix: PIX
    let edgepix: EdgePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        edgepix = EdgePIX()
        edgepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = edgepix
    }
    public func strength(_ binding: Binding<CGFloat>) -> EdgePIXUI {
        edgepix.strength = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func strength(_ liveValue: LiveFloat) -> EdgePIXUI {
        edgepix.strength = liveValue
        return self
    }
    public func distance(_ binding: Binding<CGFloat>) -> EdgePIXUI {
        edgepix.distance = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func distance(_ liveValue: LiveFloat) -> EdgePIXUI {
        edgepix.distance = liveValue
        return self
    }
}


// MARK: FlarePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlarePIXUI: View, PIXUI {

    public let pix: PIX
    let flarepix: FlarePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        flarepix = FlarePIX()
        flarepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = flarepix
    }
    public func color(_ binding: Binding<_Color>) -> FlarePIXUI {
        flarepix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> FlarePIXUI {
        flarepix.color = liveValue
        return self
    }
    public func scale(_ binding: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.scale = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func scale(_ liveValue: LiveFloat) -> FlarePIXUI {
        flarepix.scale = liveValue
        return self
    }
    public func angle(_ binding: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.angle = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func angle(_ liveValue: LiveFloat) -> FlarePIXUI {
        flarepix.angle = liveValue
        return self
    }
    public func threshold(_ binding: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.threshold = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func threshold(_ liveValue: LiveFloat) -> FlarePIXUI {
        flarepix.threshold = liveValue
        return self
    }
    public func brightness(_ binding: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.brightness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func brightness(_ liveValue: LiveFloat) -> FlarePIXUI {
        flarepix.brightness = liveValue
        return self
    }
    public func gamma(_ binding: Binding<CGFloat>) -> FlarePIXUI {
        flarepix.gamma = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func gamma(_ liveValue: LiveFloat) -> FlarePIXUI {
        flarepix.gamma = liveValue
        return self
    }
    public func count(_ binding: Binding<Int>) -> FlarePIXUI {
        flarepix.count = LiveInt({ binding.wrappedValue })
        return self
    }
    public func count(_ liveValue: LiveInt) -> FlarePIXUI {
        flarepix.count = liveValue
        return self
    }
    public func rayRes(_ binding: Binding<Int>) -> FlarePIXUI {
        flarepix.rayRes = LiveInt({ binding.wrappedValue })
        return self
    }
    public func rayRes(_ liveValue: LiveInt) -> FlarePIXUI {
        flarepix.rayRes = liveValue
        return self
    }
}


// MARK: FlipFlopPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlipFlopPIXUI: View, PIXUI {

    public let pix: PIX
    let flipfloppix: FlipFlopPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        flipfloppix = FlipFlopPIX()
        flipfloppix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = flipfloppix
    }
}


// MARK: HueSaturationPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct HueSaturationPIXUI: View, PIXUI {

    public let pix: PIX
    let huesaturationpix: HueSaturationPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        huesaturationpix = HueSaturationPIX()
        huesaturationpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = huesaturationpix
    }
    public func hue(_ binding: Binding<CGFloat>) -> HueSaturationPIXUI {
        huesaturationpix.hue = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func hue(_ liveValue: LiveFloat) -> HueSaturationPIXUI {
        huesaturationpix.hue = liveValue
        return self
    }
    public func saturation(_ binding: Binding<CGFloat>) -> HueSaturationPIXUI {
        huesaturationpix.saturation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func saturation(_ liveValue: LiveFloat) -> HueSaturationPIXUI {
        huesaturationpix.saturation = liveValue
        return self
    }
}


// MARK: KaleidoscopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct KaleidoscopePIXUI: View, PIXUI {

    public let pix: PIX
    let kaleidoscopepix: KaleidoscopePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        kaleidoscopepix = KaleidoscopePIX()
        kaleidoscopepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = kaleidoscopepix
    }
    public func mirror(_ binding: Binding<Bool>) -> KaleidoscopePIXUI {
        kaleidoscopepix.mirror = LiveBool({ binding.wrappedValue })
        return self
    }
    public func mirror(_ liveValue: LiveBool) -> KaleidoscopePIXUI {
        kaleidoscopepix.mirror = liveValue
        return self
    }
    public func rotation(_ binding: Binding<CGFloat>) -> KaleidoscopePIXUI {
        kaleidoscopepix.rotation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func rotation(_ liveValue: LiveFloat) -> KaleidoscopePIXUI {
        kaleidoscopepix.rotation = liveValue
        return self
    }
    public func divisions(_ binding: Binding<Int>) -> KaleidoscopePIXUI {
        kaleidoscopepix.divisions = LiveInt({ binding.wrappedValue })
        return self
    }
    public func divisions(_ liveValue: LiveInt) -> KaleidoscopePIXUI {
        kaleidoscopepix.divisions = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> KaleidoscopePIXUI {
        kaleidoscopepix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> KaleidoscopePIXUI {
        kaleidoscopepix.position = liveValue
        return self
    }
}


// MARK: LevelsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LevelsPIXUI: View, PIXUI {

    public let pix: PIX
    let levelspix: LevelsPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        levelspix = LevelsPIX()
        levelspix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = levelspix
    }
    public func inverted(_ binding: Binding<Bool>) -> LevelsPIXUI {
        levelspix.inverted = LiveBool({ binding.wrappedValue })
        return self
    }
    public func inverted(_ liveValue: LiveBool) -> LevelsPIXUI {
        levelspix.inverted = liveValue
        return self
    }
    public func brightness(_ binding: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.brightness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func brightness(_ liveValue: LiveFloat) -> LevelsPIXUI {
        levelspix.brightness = liveValue
        return self
    }
    public func darkness(_ binding: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.darkness = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func darkness(_ liveValue: LiveFloat) -> LevelsPIXUI {
        levelspix.darkness = liveValue
        return self
    }
    public func contrast(_ binding: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.contrast = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func contrast(_ liveValue: LiveFloat) -> LevelsPIXUI {
        levelspix.contrast = liveValue
        return self
    }
    public func gamma(_ binding: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.gamma = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func gamma(_ liveValue: LiveFloat) -> LevelsPIXUI {
        levelspix.gamma = liveValue
        return self
    }
    public func opacity(_ binding: Binding<CGFloat>) -> LevelsPIXUI {
        levelspix.opacity = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func opacity(_ liveValue: LiveFloat) -> LevelsPIXUI {
        levelspix.opacity = liveValue
        return self
    }
}


// MARK: QuantizePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct QuantizePIXUI: View, PIXUI {

    public let pix: PIX
    let quantizepix: QuantizePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        quantizepix = QuantizePIX()
        quantizepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = quantizepix
    }
    public func fraction(_ binding: Binding<CGFloat>) -> QuantizePIXUI {
        quantizepix.fraction = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func fraction(_ liveValue: LiveFloat) -> QuantizePIXUI {
        quantizepix.fraction = liveValue
        return self
    }
}


// MARK: RangePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RangePIXUI: View, PIXUI {

    public let pix: PIX
    let rangepix: RangePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        rangepix = RangePIX()
        rangepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = rangepix
    }
    public func ignoreAlpha(_ binding: Binding<Bool>) -> RangePIXUI {
        rangepix.ignoreAlpha = LiveBool({ binding.wrappedValue })
        return self
    }
    public func ignoreAlpha(_ liveValue: LiveBool) -> RangePIXUI {
        rangepix.ignoreAlpha = liveValue
        return self
    }
    public func inLowColor(_ binding: Binding<_Color>) -> RangePIXUI {
        rangepix.inLowColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func inLowColor(_ liveValue: LiveColor) -> RangePIXUI {
        rangepix.inLowColor = liveValue
        return self
    }
    public func inHighColor(_ binding: Binding<_Color>) -> RangePIXUI {
        rangepix.inHighColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func inHighColor(_ liveValue: LiveColor) -> RangePIXUI {
        rangepix.inHighColor = liveValue
        return self
    }
    public func outLowColor(_ binding: Binding<_Color>) -> RangePIXUI {
        rangepix.outLowColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func outLowColor(_ liveValue: LiveColor) -> RangePIXUI {
        rangepix.outLowColor = liveValue
        return self
    }
    public func outHighColor(_ binding: Binding<_Color>) -> RangePIXUI {
        rangepix.outHighColor = LiveColor({ binding.wrappedValue })
        return self
    }
    public func outHighColor(_ liveValue: LiveColor) -> RangePIXUI {
        rangepix.outHighColor = liveValue
        return self
    }
    public func inLow(_ binding: Binding<CGFloat>) -> RangePIXUI {
        rangepix.inLow = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func inLow(_ liveValue: LiveFloat) -> RangePIXUI {
        rangepix.inLow = liveValue
        return self
    }
    public func inHigh(_ binding: Binding<CGFloat>) -> RangePIXUI {
        rangepix.inHigh = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func inHigh(_ liveValue: LiveFloat) -> RangePIXUI {
        rangepix.inHigh = liveValue
        return self
    }
    public func outLow(_ binding: Binding<CGFloat>) -> RangePIXUI {
        rangepix.outLow = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func outLow(_ liveValue: LiveFloat) -> RangePIXUI {
        rangepix.outLow = liveValue
        return self
    }
    public func outHigh(_ binding: Binding<CGFloat>) -> RangePIXUI {
        rangepix.outHigh = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func outHigh(_ liveValue: LiveFloat) -> RangePIXUI {
        rangepix.outHigh = liveValue
        return self
    }
}


// MARK: SepiaPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SepiaPIXUI: View, PIXUI {

    public let pix: PIX
    let sepiapix: SepiaPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        sepiapix = SepiaPIX()
        sepiapix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = sepiapix
    }
    public func color(_ binding: Binding<_Color>) -> SepiaPIXUI {
        sepiapix.color = LiveColor({ binding.wrappedValue })
        return self
    }
    public func color(_ liveValue: LiveColor) -> SepiaPIXUI {
        sepiapix.color = liveValue
        return self
    }
}


// MARK: SharpenPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SharpenPIXUI: View, PIXUI {

    public let pix: PIX
    let sharpenpix: SharpenPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        sharpenpix = SharpenPIX()
        sharpenpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = sharpenpix
    }
    public func contrast(_ binding: Binding<CGFloat>) -> SharpenPIXUI {
        sharpenpix.contrast = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func contrast(_ liveValue: LiveFloat) -> SharpenPIXUI {
        sharpenpix.contrast = liveValue
        return self
    }
}


// MARK: SlopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SlopePIXUI: View, PIXUI {

    public let pix: PIX
    let slopepix: SlopePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        slopepix = SlopePIX()
        slopepix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = slopepix
    }
    public func amplitude(_ binding: Binding<CGFloat>) -> SlopePIXUI {
        slopepix.amplitude = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func amplitude(_ liveValue: LiveFloat) -> SlopePIXUI {
        slopepix.amplitude = liveValue
        return self
    }
}


// MARK: ThresholdPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ThresholdPIXUI: View, PIXUI {

    public let pix: PIX
    let thresholdpix: ThresholdPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        thresholdpix = ThresholdPIX()
        thresholdpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = thresholdpix
    }
    public func threshold(_ binding: Binding<CGFloat>) -> ThresholdPIXUI {
        thresholdpix.threshold = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func threshold(_ liveValue: LiveFloat) -> ThresholdPIXUI {
        thresholdpix.threshold = liveValue
        return self
    }
}


// MARK: TransformPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TransformPIXUI: View, PIXUI {

    public let pix: PIX
    let transformpix: TransformPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        transformpix = TransformPIX()
        transformpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = transformpix
    }
    public func rotation(_ binding: Binding<CGFloat>) -> TransformPIXUI {
        transformpix.rotation = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func rotation(_ liveValue: LiveFloat) -> TransformPIXUI {
        transformpix.rotation = liveValue
        return self
    }
    public func scale(_ binding: Binding<CGFloat>) -> TransformPIXUI {
        transformpix.scale = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func scale(_ liveValue: LiveFloat) -> TransformPIXUI {
        transformpix.scale = liveValue
        return self
    }
    public func position(_ binding: Binding<CGPoint>) -> TransformPIXUI {
        transformpix.position = LivePoint({ binding.wrappedValue })
        return self
    }
    public func position(_ liveValue: LivePoint) -> TransformPIXUI {
        transformpix.position = liveValue
        return self
    }
    public func size(_ binding: Binding<CGSize>) -> TransformPIXUI {
        transformpix.size = LiveSize({ binding.wrappedValue })
        return self
    }
    public func size(_ liveValue: LiveSize) -> TransformPIXUI {
        transformpix.size = liveValue
        return self
    }
}


// MARK: TwirlPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TwirlPIXUI: View, PIXUI {

    public let pix: PIX
    let twirlpix: TwirlPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init(_ uiPix: () -> (PIXUI)) {
        twirlpix = TwirlPIX()
        twirlpix.inPix = uiPix().pix as? (PIX & PIXOut)
        pix = twirlpix
    }
    public func strength(_ binding: Binding<CGFloat>) -> TwirlPIXUI {
        twirlpix.strength = LiveFloat({ binding.wrappedValue })
        return self
    }
    public func strength(_ liveValue: LiveFloat) -> TwirlPIXUI {
        twirlpix.strength = liveValue
        return self
    }
}




#endif
