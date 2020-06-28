//
//  NoisePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-14.
//  Open Source - MIT License
//

import LiveValues
import RenderKit
#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct PixNoise: View, PIXUI {
    public var node: NODE { pix }

    public let pix: PIX
    let noisepix: NoisePIX
    public var body: some View {
        NODERepView(node: pix)
    }

    public init(octaves: Binding<Int> = .constant(10),
                colored: Binding<Bool> = .constant(false),
                random: Binding<Bool> = .constant(false),
                zPosition: Binding<CGFloat> = .constant(0.0),
                zoom: Binding<CGFloat> = .constant(1.0),
                position: Binding<CGPoint> = .constant(.zero),
                resolution: Resolution = .auto(render: PixelKit.main.render)) {
        noisepix = NoisePIX(at: resolution)
        noisepix.octaves = LiveInt({ octaves.wrappedValue })
        noisepix.colored = LiveBool({ colored.wrappedValue })
        noisepix.random = LiveBool({ random.wrappedValue })
        noisepix.zPosition = LiveFloat({ zPosition.wrappedValue })
        noisepix.zoom = LiveFloat({ zoom.wrappedValue })
        noisepix.position = LivePoint({ position.wrappedValue })
        pix = noisepix
    }
    // Parent Property Funcs
    public func bgColor(_ bgColor: Binding<_Color>) -> PixNoise {
        noisepix.bgColor = LiveColor({ bgColor.wrappedValue })
        return self
    }
    public func bgColor(_ bgColor: LiveColor) -> PixNoise {
        noisepix.bgColor = bgColor
        return self
    }
    public func color(_ color: Binding<_Color>) -> PixNoise {
        noisepix.color = LiveColor({ color.wrappedValue })
        return self
    }
    public func color(_ color: LiveColor) -> PixNoise {
        noisepix.color = color
        return self
    }
    // General Property Funcs
    public func colored(_ colored: Binding<Bool>) -> PixNoise {
        noisepix.colored = LiveBool({ colored.wrappedValue })
        return self
    }
    public func colored(_ colored: LiveBool) -> PixNoise {
        noisepix.colored = colored
        return self
    }
    public func random(_ random: Binding<Bool>) -> PixNoise {
        noisepix.random = LiveBool({ random.wrappedValue })
        return self
    }
    public func random(_ random: LiveBool) -> PixNoise {
        noisepix.random = random
        return self
    }
    public func includeAlpha(_ includeAlpha: Binding<Bool>) -> PixNoise {
        noisepix.includeAlpha = LiveBool({ includeAlpha.wrappedValue })
        return self
    }
    public func includeAlpha(_ includeAlpha: LiveBool) -> PixNoise {
        noisepix.includeAlpha = includeAlpha
        return self
    }
    public func zPosition(_ zPosition: Binding<CGFloat>) -> PixNoise {
        noisepix.zPosition = LiveFloat({ zPosition.wrappedValue })
        return self
    }
    public func zPosition(_ zPosition: LiveFloat) -> PixNoise {
        noisepix.zPosition = zPosition
        return self
    }
    public func zoom(_ zoom: Binding<CGFloat>) -> PixNoise {
        noisepix.zoom = LiveFloat({ zoom.wrappedValue })
        return self
    }
    public func zoom(_ zoom: LiveFloat) -> PixNoise {
        noisepix.zoom = zoom
        return self
    }
    public func seed(_ seed: Binding<Int>) -> PixNoise {
        noisepix.seed = LiveInt({ seed.wrappedValue })
        return self
    }
    public func seed(_ seed: LiveInt) -> PixNoise {
        noisepix.seed = seed
        return self
    }
    public func octaves(_ octaves: Binding<Int>) -> PixNoise {
        noisepix.octaves = LiveInt({ octaves.wrappedValue })
        return self
    }
    public func octaves(_ octaves: LiveInt) -> PixNoise {
        noisepix.octaves = octaves
        return self
    }
    public func position(_ position: Binding<CGPoint>) -> PixNoise {
        noisepix.position = LivePoint({ position.wrappedValue })
        return self
    }
    public func position(_ position: LivePoint) -> PixNoise {
        noisepix.position = position
        return self
    }
    // Enum Property Funcs
}

public class NoisePIX: PIXGenerator, PIXAuto {
    
    override open var shaderName: String { return "contentGeneratorNoisePIX" }
    
    // MARK: - Public Properties
    
    public var seed: LiveInt = LiveInt(1, max: 10)
    public var octaves: LiveInt = LiveInt(10, min: 1, max: 10)
    public var position: LivePoint = .zero
    public var zPosition: LiveFloat = 0.0
    public var zoom: LiveFloat = 1.0
    public var colored: LiveBool = false
    public var random: LiveBool = false
    public var includeAlpha: LiveBool = false
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [seed, octaves, position, zPosition, zoom, colored, random, includeAlpha]
    }
    
    // MARK: - Life Cycle
    
    public required init(at resolution: Resolution = .auto(render: PixelKit.main.render)) {
        super.init(at: resolution, name: "Noise", typeName: "pix-content-generator-noise")
    }
    
//    // MARK: - Life Cycle
//
//    public init(at resolution: Resolution, seed: Int = Int.random(in: 0...1000), octaves: Int = 7, colored: Bool = false, random: Bool = false) {
//        self.seed = seed
//        self.octaves = octaves
//        self.colored = colored
//        self.random = random
//        super.init(at: resolution)
//    }
    
}
