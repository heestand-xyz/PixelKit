// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

#if canImport(SwiftUI)

import SwiftUI


// MARK - UIPIXGenerator


// ArcPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ArcPIXUI: View, PIXUI {

    public let pix: PIX
    let arcpix: ArcPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        arcpix = ArcPIX()
        pix = arcpix
    }


    public func fillColor(_ bind: Binding<
    _Color
    >) -> ArcPIXUI {
        arcpix.fillColor = LiveColor({ bind.wrappedValue })
        return self
    }


    public func radius(_ bind: Binding<
    CGFloat
    >) -> ArcPIXUI {
        arcpix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angleFrom(_ bind: Binding<
    CGFloat
    >) -> ArcPIXUI {
        arcpix.angleFrom = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angleTo(_ bind: Binding<
    CGFloat
    >) -> ArcPIXUI {
        arcpix.angleTo = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angleOffset(_ bind: Binding<
    CGFloat
    >) -> ArcPIXUI {
        arcpix.angleOffset = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func edgeRadius(_ bind: Binding<
    CGFloat
    >) -> ArcPIXUI {
        arcpix.edgeRadius = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> ArcPIXUI {
        arcpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// CirclePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CirclePIXUI: View, PIXUI {

    public let pix: PIX
    let circlepix: CirclePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        circlepix = CirclePIX()
        pix = circlepix
    }


    public func edgeColor(_ bind: Binding<
    _Color
    >) -> CirclePIXUI {
        circlepix.edgeColor = LiveColor({ bind.wrappedValue })
        return self
    }


    public func radius(_ bind: Binding<
    CGFloat
    >) -> CirclePIXUI {
        circlepix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func edgeRadius(_ bind: Binding<
    CGFloat
    >) -> CirclePIXUI {
        circlepix.edgeRadius = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> CirclePIXUI {
        circlepix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// ColorPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ColorPIXUI: View, PIXUI {

    public let pix: PIX
    let colorpix: ColorPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        colorpix = ColorPIX()
        pix = colorpix
    }







}


// GradientPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct GradientPIXUI: View, PIXUI {

    public let pix: PIX
    let gradientpix: GradientPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        gradientpix = GradientPIX()
        pix = gradientpix
    }



    public func scale(_ bind: Binding<
    CGFloat
    >) -> GradientPIXUI {
        gradientpix.scale = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func offset(_ bind: Binding<
    CGFloat
    >) -> GradientPIXUI {
        gradientpix.offset = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> GradientPIXUI {
        gradientpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// LinePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LinePIXUI: View, PIXUI {

    public let pix: PIX
    let linepix: LinePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        linepix = LinePIX()
        pix = linepix
    }



    public func scale(_ bind: Binding<
    CGFloat
    >) -> LinePIXUI {
        linepix.scale = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func positionFrom(_ bind: Binding<
    CGPoint
    >) -> LinePIXUI {
        linepix.positionFrom = LivePoint({ bind.wrappedValue })
        return self
    }

    public func positionTo(_ bind: Binding<
    CGPoint
    >) -> LinePIXUI {
        linepix.positionTo = LivePoint({ bind.wrappedValue })
        return self
    }



}


// NoisePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct NoisePIXUI: View, PIXUI {

    public let pix: PIX
    let noisepix: NoisePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        noisepix = NoisePIX()
        pix = noisepix
    }

    public func colored(_ bind: Binding<
    Bool
    >) -> NoisePIXUI {
        noisepix.colored = LiveBool({ bind.wrappedValue })
        return self
    }

    public func random(_ bind: Binding<
    Bool
    >) -> NoisePIXUI {
        noisepix.random = LiveBool({ bind.wrappedValue })
        return self
    }

    public func includeAlpha(_ bind: Binding<
    Bool
    >) -> NoisePIXUI {
        noisepix.includeAlpha = LiveBool({ bind.wrappedValue })
        return self
    }



    public func zPosition(_ bind: Binding<
    CGFloat
    >) -> NoisePIXUI {
        noisepix.zPosition = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func zoom(_ bind: Binding<
    CGFloat
    >) -> NoisePIXUI {
        noisepix.zoom = LiveFloat({ bind.wrappedValue })
        return self
    }


    public func seed(_ bind: Binding<
    Int
    >) -> NoisePIXUI {
        noisepix.seed = LiveInt({ bind.wrappedValue })
        return self
    }

    public func octaves(_ bind: Binding<
    Int
    >) -> NoisePIXUI {
        noisepix.octaves = LiveInt({ bind.wrappedValue })
        return self
    }


    public func position(_ bind: Binding<
    CGPoint
    >) -> NoisePIXUI {
        noisepix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// PolygonPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct PolygonPIXUI: View, PIXUI {

    public let pix: PIX
    let polygonpix: PolygonPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        polygonpix = PolygonPIX()
        pix = polygonpix
    }



    public func radius(_ bind: Binding<
    CGFloat
    >) -> PolygonPIXUI {
        polygonpix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func rotation(_ bind: Binding<
    CGFloat
    >) -> PolygonPIXUI {
        polygonpix.rotation = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func cornerRadius(_ bind: Binding<
    CGFloat
    >) -> PolygonPIXUI {
        polygonpix.cornerRadius = LiveFloat({ bind.wrappedValue })
        return self
    }


    public func vertexCount(_ bind: Binding<
    Int
    >) -> PolygonPIXUI {
        polygonpix.vertexCount = LiveInt({ bind.wrappedValue })
        return self
    }


    public func position(_ bind: Binding<
    CGPoint
    >) -> PolygonPIXUI {
        polygonpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// RectanglePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RectanglePIXUI: View, PIXUI {

    public let pix: PIX
    let rectanglepix: RectanglePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        rectanglepix = RectanglePIX()
        pix = rectanglepix
    }



    public func cornerRadius(_ bind: Binding<
    CGFloat
    >) -> RectanglePIXUI {
        rectanglepix.cornerRadius = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> RectanglePIXUI {
        rectanglepix.position = LivePoint({ bind.wrappedValue })
        return self
    }



    public func size(_ bind: Binding<
    CGSize
    >) -> RectanglePIXUI {
        rectanglepix.size = LiveSize({ bind.wrappedValue })
        return self
    }

}




// MARK - UIPIXMergerEffect


// BlendPIXUI

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

    public func bypassTransform(_ bind: Binding<
    Bool
    >) -> BlendPIXUI {
        blendpix.bypassTransform = LiveBool({ bind.wrappedValue })
        return self
    }



    public func rotation(_ bind: Binding<
    CGFloat
    >) -> BlendPIXUI {
        blendpix.rotation = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func scale(_ bind: Binding<
    CGFloat
    >) -> BlendPIXUI {
        blendpix.scale = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> BlendPIXUI {
        blendpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



    public func size(_ bind: Binding<
    CGSize
    >) -> BlendPIXUI {
        blendpix.size = LiveSize({ bind.wrappedValue })
        return self
    }

}


// CrossPIXUI

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



    public func fraction(_ bind: Binding<
    CGFloat
    >) -> CrossPIXUI {
        crosspix.fraction = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// DisplacePIXUI

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



    public func distance(_ bind: Binding<
    CGFloat
    >) -> DisplacePIXUI {
        displacepix.distance = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func origin(_ bind: Binding<
    CGFloat
    >) -> DisplacePIXUI {
        displacepix.origin = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// LookupPIXUI

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


// LumaBlurPIXUI

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



    public func radius(_ bind: Binding<
    CGFloat
    >) -> LumaBlurPIXUI {
        lumablurpix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angle(_ bind: Binding<
    CGFloat
    >) -> LumaBlurPIXUI {
        lumablurpix.angle = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> LumaBlurPIXUI {
        lumablurpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// LumaLevelsPIXUI

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



    public func brightness(_ bind: Binding<
    CGFloat
    >) -> LumaLevelsPIXUI {
        lumalevelspix.brightness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func darkness(_ bind: Binding<
    CGFloat
    >) -> LumaLevelsPIXUI {
        lumalevelspix.darkness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func contrast(_ bind: Binding<
    CGFloat
    >) -> LumaLevelsPIXUI {
        lumalevelspix.contrast = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func gamma(_ bind: Binding<
    CGFloat
    >) -> LumaLevelsPIXUI {
        lumalevelspix.gamma = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func opacity(_ bind: Binding<
    CGFloat
    >) -> LumaLevelsPIXUI {
        lumalevelspix.opacity = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// RemapPIXUI

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


// ReorderPIXUI

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




// MARK - UIPIXMultiEffect


// ArrayPIXUI

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


    public func bgColor(_ bind: Binding<
    _Color
    >) -> ArrayPIXUI {
        arraypix.bgColor = LiveColor({ bind.wrappedValue })
        return self
    }






}


// BlendsPIXUI

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




// MARK - UIPIXSingleEffect


// BlurPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct BlurPIXUI: View, PIXUI {

    public let pix: PIX
    let blurpix: BlurPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        blurpix = BlurPIX()
        pix = blurpix
    }



    public func radius(_ bind: Binding<
    CGFloat
    >) -> BlurPIXUI {
        blurpix.radius = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angle(_ bind: Binding<
    CGFloat
    >) -> BlurPIXUI {
        blurpix.angle = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> BlurPIXUI {
        blurpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// ChannelMixPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChannelMixPIXUI: View, PIXUI {

    public let pix: PIX
    let channelmixpix: ChannelMixPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        channelmixpix = ChannelMixPIX()
        pix = channelmixpix
    }







}


// ChromaKeyPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ChromaKeyPIXUI: View, PIXUI {

    public let pix: PIX
    let chromakeypix: ChromaKeyPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        chromakeypix = ChromaKeyPIX()
        pix = chromakeypix
    }

    public func premultiply(_ bind: Binding<
    Bool
    >) -> ChromaKeyPIXUI {
        chromakeypix.premultiply = LiveBool({ bind.wrappedValue })
        return self
    }


    public func keyColor(_ bind: Binding<
    _Color
    >) -> ChromaKeyPIXUI {
        chromakeypix.keyColor = LiveColor({ bind.wrappedValue })
        return self
    }


    public func range(_ bind: Binding<
    CGFloat
    >) -> ChromaKeyPIXUI {
        chromakeypix.range = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func softness(_ bind: Binding<
    CGFloat
    >) -> ChromaKeyPIXUI {
        chromakeypix.softness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func edgeDesaturation(_ bind: Binding<
    CGFloat
    >) -> ChromaKeyPIXUI {
        chromakeypix.edgeDesaturation = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// ClampPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ClampPIXUI: View, PIXUI {

    public let pix: PIX
    let clamppix: ClampPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        clamppix = ClampPIX()
        pix = clamppix
    }

    public func clampAlpha(_ bind: Binding<
    Bool
    >) -> ClampPIXUI {
        clamppix.clampAlpha = LiveBool({ bind.wrappedValue })
        return self
    }



    public func low(_ bind: Binding<
    CGFloat
    >) -> ClampPIXUI {
        clamppix.low = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func high(_ bind: Binding<
    CGFloat
    >) -> ClampPIXUI {
        clamppix.high = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// CornerPinPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct CornerPinPIXUI: View, PIXUI {

    public let pix: PIX
    let cornerpinpix: CornerPinPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        cornerpinpix = CornerPinPIX()
        pix = cornerpinpix
    }







}


// EdgePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct EdgePIXUI: View, PIXUI {

    public let pix: PIX
    let edgepix: EdgePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        edgepix = EdgePIX()
        pix = edgepix
    }



    public func strength(_ bind: Binding<
    CGFloat
    >) -> EdgePIXUI {
        edgepix.strength = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func distance(_ bind: Binding<
    CGFloat
    >) -> EdgePIXUI {
        edgepix.distance = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// FlarePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlarePIXUI: View, PIXUI {

    public let pix: PIX
    let flarepix: FlarePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        flarepix = FlarePIX()
        pix = flarepix
    }


    public func color(_ bind: Binding<
    _Color
    >) -> FlarePIXUI {
        flarepix.color = LiveColor({ bind.wrappedValue })
        return self
    }


    public func scale(_ bind: Binding<
    CGFloat
    >) -> FlarePIXUI {
        flarepix.scale = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func angle(_ bind: Binding<
    CGFloat
    >) -> FlarePIXUI {
        flarepix.angle = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func threshold(_ bind: Binding<
    CGFloat
    >) -> FlarePIXUI {
        flarepix.threshold = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func brightness(_ bind: Binding<
    CGFloat
    >) -> FlarePIXUI {
        flarepix.brightness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func gamma(_ bind: Binding<
    CGFloat
    >) -> FlarePIXUI {
        flarepix.gamma = LiveFloat({ bind.wrappedValue })
        return self
    }


    public func count(_ bind: Binding<
    Int
    >) -> FlarePIXUI {
        flarepix.count = LiveInt({ bind.wrappedValue })
        return self
    }

    public func rayRes(_ bind: Binding<
    Int
    >) -> FlarePIXUI {
        flarepix.rayRes = LiveInt({ bind.wrappedValue })
        return self
    }




}


// FlipFlopPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct FlipFlopPIXUI: View, PIXUI {

    public let pix: PIX
    let flipfloppix: FlipFlopPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        flipfloppix = FlipFlopPIX()
        pix = flipfloppix
    }







}


// HueSaturationPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct HueSaturationPIXUI: View, PIXUI {

    public let pix: PIX
    let huesaturationpix: HueSaturationPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        huesaturationpix = HueSaturationPIX()
        pix = huesaturationpix
    }



    public func hue(_ bind: Binding<
    CGFloat
    >) -> HueSaturationPIXUI {
        huesaturationpix.hue = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func saturation(_ bind: Binding<
    CGFloat
    >) -> HueSaturationPIXUI {
        huesaturationpix.saturation = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// KaleidoscopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct KaleidoscopePIXUI: View, PIXUI {

    public let pix: PIX
    let kaleidoscopepix: KaleidoscopePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        kaleidoscopepix = KaleidoscopePIX()
        pix = kaleidoscopepix
    }

    public func mirror(_ bind: Binding<
    Bool
    >) -> KaleidoscopePIXUI {
        kaleidoscopepix.mirror = LiveBool({ bind.wrappedValue })
        return self
    }



    public func rotation(_ bind: Binding<
    CGFloat
    >) -> KaleidoscopePIXUI {
        kaleidoscopepix.rotation = LiveFloat({ bind.wrappedValue })
        return self
    }


    public func divisions(_ bind: Binding<
    Int
    >) -> KaleidoscopePIXUI {
        kaleidoscopepix.divisions = LiveInt({ bind.wrappedValue })
        return self
    }


    public func position(_ bind: Binding<
    CGPoint
    >) -> KaleidoscopePIXUI {
        kaleidoscopepix.position = LivePoint({ bind.wrappedValue })
        return self
    }



}


// LevelsPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct LevelsPIXUI: View, PIXUI {

    public let pix: PIX
    let levelspix: LevelsPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        levelspix = LevelsPIX()
        pix = levelspix
    }

    public func inverted(_ bind: Binding<
    Bool
    >) -> LevelsPIXUI {
        levelspix.inverted = LiveBool({ bind.wrappedValue })
        return self
    }



    public func brightness(_ bind: Binding<
    CGFloat
    >) -> LevelsPIXUI {
        levelspix.brightness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func darkness(_ bind: Binding<
    CGFloat
    >) -> LevelsPIXUI {
        levelspix.darkness = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func contrast(_ bind: Binding<
    CGFloat
    >) -> LevelsPIXUI {
        levelspix.contrast = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func gamma(_ bind: Binding<
    CGFloat
    >) -> LevelsPIXUI {
        levelspix.gamma = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func opacity(_ bind: Binding<
    CGFloat
    >) -> LevelsPIXUI {
        levelspix.opacity = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// QuantizePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct QuantizePIXUI: View, PIXUI {

    public let pix: PIX
    let quantizepix: QuantizePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        quantizepix = QuantizePIX()
        pix = quantizepix
    }



    public func fraction(_ bind: Binding<
    CGFloat
    >) -> QuantizePIXUI {
        quantizepix.fraction = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// RangePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct RangePIXUI: View, PIXUI {

    public let pix: PIX
    let rangepix: RangePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        rangepix = RangePIX()
        pix = rangepix
    }

    public func ignoreAlpha(_ bind: Binding<
    Bool
    >) -> RangePIXUI {
        rangepix.ignoreAlpha = LiveBool({ bind.wrappedValue })
        return self
    }


    public func inLowColor(_ bind: Binding<
    _Color
    >) -> RangePIXUI {
        rangepix.inLowColor = LiveColor({ bind.wrappedValue })
        return self
    }

    public func inHighColor(_ bind: Binding<
    _Color
    >) -> RangePIXUI {
        rangepix.inHighColor = LiveColor({ bind.wrappedValue })
        return self
    }

    public func outLowColor(_ bind: Binding<
    _Color
    >) -> RangePIXUI {
        rangepix.outLowColor = LiveColor({ bind.wrappedValue })
        return self
    }

    public func outHighColor(_ bind: Binding<
    _Color
    >) -> RangePIXUI {
        rangepix.outHighColor = LiveColor({ bind.wrappedValue })
        return self
    }


    public func inLow(_ bind: Binding<
    CGFloat
    >) -> RangePIXUI {
        rangepix.inLow = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func inHigh(_ bind: Binding<
    CGFloat
    >) -> RangePIXUI {
        rangepix.inHigh = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func outLow(_ bind: Binding<
    CGFloat
    >) -> RangePIXUI {
        rangepix.outLow = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func outHigh(_ bind: Binding<
    CGFloat
    >) -> RangePIXUI {
        rangepix.outHigh = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// SepiaPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SepiaPIXUI: View, PIXUI {

    public let pix: PIX
    let sepiapix: SepiaPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        sepiapix = SepiaPIX()
        pix = sepiapix
    }


    public func color(_ bind: Binding<
    _Color
    >) -> SepiaPIXUI {
        sepiapix.color = LiveColor({ bind.wrappedValue })
        return self
    }






}


// SharpenPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SharpenPIXUI: View, PIXUI {

    public let pix: PIX
    let sharpenpix: SharpenPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        sharpenpix = SharpenPIX()
        pix = sharpenpix
    }



    public func contrast(_ bind: Binding<
    CGFloat
    >) -> SharpenPIXUI {
        sharpenpix.contrast = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// SlopePIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct SlopePIXUI: View, PIXUI {

    public let pix: PIX
    let slopepix: SlopePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        slopepix = SlopePIX()
        pix = slopepix
    }



    public func amplitude(_ bind: Binding<
    CGFloat
    >) -> SlopePIXUI {
        slopepix.amplitude = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// ThresholdPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ThresholdPIXUI: View, PIXUI {

    public let pix: PIX
    let thresholdpix: ThresholdPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        thresholdpix = ThresholdPIX()
        pix = thresholdpix
    }



    public func threshold(_ bind: Binding<
    CGFloat
    >) -> ThresholdPIXUI {
        thresholdpix.threshold = LiveFloat({ bind.wrappedValue })
        return self
    }





}


// TransformPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TransformPIXUI: View, PIXUI {

    public let pix: PIX
    let transformpix: TransformPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        transformpix = TransformPIX()
        pix = transformpix
    }



    public func rotation(_ bind: Binding<
    CGFloat
    >) -> TransformPIXUI {
        transformpix.rotation = LiveFloat({ bind.wrappedValue })
        return self
    }

    public func scale(_ bind: Binding<
    CGFloat
    >) -> TransformPIXUI {
        transformpix.scale = LiveFloat({ bind.wrappedValue })
        return self
    }



    public func position(_ bind: Binding<
    CGPoint
    >) -> TransformPIXUI {
        transformpix.position = LivePoint({ bind.wrappedValue })
        return self
    }



    public func size(_ bind: Binding<
    CGSize
    >) -> TransformPIXUI {
        transformpix.size = LiveSize({ bind.wrappedValue })
        return self
    }

}


// TwirlPIXUI

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct TwirlPIXUI: View, PIXUI {

    public let pix: PIX
    let twirlpix: TwirlPIX
    public var body: some View {
        PIXRepView(pix: pix)
    }

    public init() {
        twirlpix = TwirlPIX()
        pix = twirlpix
    }



    public func strength(_ bind: Binding<
    CGFloat
    >) -> TwirlPIXUI {
        twirlpix.strength = LiveFloat({ bind.wrappedValue })
        return self
    }





}




#endif
