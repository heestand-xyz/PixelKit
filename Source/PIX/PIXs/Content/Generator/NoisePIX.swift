//
//  NoisePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-14.
//  Open Source - MIT License
//


import RenderKit
#if canImport(SwiftUI)
import SwiftUI
#endif

//@available(iOS 13.0.0, *)
//@available(OSX 10.15, *)
//@available(tvOS 13.0.0, *)
//public struct PixNoise: View, PIXUI {
//    public var node: NODE { pix }
//
//    public let pix: PIX
//    let noisepix: NoisePIX
//    public var body: some View {
//        NODERepView(node: pix)
//    }
//
//    public init(octaves: Binding<Int> = .constant(10),
//                colored: Binding<Bool> = .constant(false),
//                random: Binding<Bool> = .constant(false),
//                zPosition: Binding<CGFloat> = .constant(0.0),
//                zoom: Binding<CGFloat> = .constant(1.0),
//                position: Binding<CGPoint> = .constant(.zero),
//                resolution: Resolution = .auto(render: PixelKit.main.render)) {
//        noisepix = NoisePIX(at: resolution)
//        noisepix.octaves = Int({ octaves.wrappedValue })
//        noisepix.colored = Bool({ colored.wrappedValue })
//        noisepix.random = Bool({ random.wrappedValue })
//        noisepix.zPosition = CGFloat({ zPosition.wrappedValue })
//        noisepix.zoom = CGFloat({ zoom.wrappedValue })
//        noisepix.position = CGPoint({ position.wrappedValue })
//        pix = noisepix
//    }
//    // Parent Property Funcs
//    public func bgColor(_ bgColor: Binding<_Color>) -> PixNoise {
//        noisepix.bgColor = PixelColor({ bgColor.wrappedValue })
//        return self
//    }
//    public func bgColor(_ bgColor: PixelColor) -> PixNoise {
//        noisepix.bgColor = bgColor
//        return self
//    }
//    public func color(_ color: Binding<_Color>) -> PixNoise {
//        noisepix.color = PixelColor({ color.wrappedValue })
//        return self
//    }
//    public func color(_ color: PixelColor) -> PixNoise {
//        noisepix.color = color
//        return self
//    }
//    // General Property Funcs
//    public func colored(_ colored: Binding<Bool>) -> PixNoise {
//        noisepix.colored = Bool({ colored.wrappedValue })
//        return self
//    }
//    public func colored(_ colored: Bool) -> PixNoise {
//        noisepix.colored = colored
//        return self
//    }
//    public func random(_ random: Binding<Bool>) -> PixNoise {
//        noisepix.random = Bool({ random.wrappedValue })
//        return self
//    }
//    public func random(_ random: Bool) -> PixNoise {
//        noisepix.random = random
//        return self
//    }
//    public func includeAlpha(_ includeAlpha: Binding<Bool>) -> PixNoise {
//        noisepix.includeAlpha = Bool({ includeAlpha.wrappedValue })
//        return self
//    }
//    public func includeAlpha(_ includeAlpha: Bool) -> PixNoise {
//        noisepix.includeAlpha = includeAlpha
//        return self
//    }
//    public func zPosition(_ zPosition: Binding<CGFloat>) -> PixNoise {
//        noisepix.zPosition = CGFloat({ zPosition.wrappedValue })
//        return self
//    }
//    public func zPosition(_ zPosition: CGFloat) -> PixNoise {
//        noisepix.zPosition = zPosition
//        return self
//    }
//    public func zoom(_ zoom: Binding<CGFloat>) -> PixNoise {
//        noisepix.zoom = CGFloat({ zoom.wrappedValue })
//        return self
//    }
//    public func zoom(_ zoom: CGFloat) -> PixNoise {
//        noisepix.zoom = zoom
//        return self
//    }
//    public func seed(_ seed: Binding<Int>) -> PixNoise {
//        noisepix.seed = Int({ seed.wrappedValue })
//        return self
//    }
//    public func seed(_ seed: Int) -> PixNoise {
//        noisepix.seed = seed
//        return self
//    }
//    public func octaves(_ octaves: Binding<Int>) -> PixNoise {
//        noisepix.octaves = Int({ octaves.wrappedValue })
//        return self
//    }
//    public func octaves(_ octaves: Int) -> PixNoise {
//        noisepix.octaves = octaves
//        return self
//    }
//    public func position(_ position: Binding<CGPoint>) -> PixNoise {
//        noisepix.position = CGPoint({ position.wrappedValue })
//        return self
//    }
//    public func position(_ position: CGPoint) -> PixNoise {
//        noisepix.position = position
//        return self
//    }
//    // Enum Property Funcs
//}

final public class NoisePIX: PIXGenerator, BodyViewRepresentable {
    
    override public var shaderName: String { return "contentGeneratorNoisePIX" }
    
    var bodyView: MultiView { pixView }
    
    // MARK: - Public Properties
    
    @Live public var seed: Int = 1
    @Live public var octaves: Int = 10
    @Live public var position: CGPoint = .zero
    @Live public var zPosition: CGFloat = 0.0
    @Live public var zoom: CGFloat = 1.0
    @Live public var colored: Bool = false
    @Live public var random: Bool = false
    @Live public var includeAlpha: Bool = false
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_seed, _octaves, _position, _zPosition, _zoom, _colored, _random, _includeAlpha]
    }
    
    override public var values: [Floatable] {
        [seed, octaves, position, zPosition, zoom, colored, random, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Noise", typeName: "pix-content-generator-noise")
    }
    
}
