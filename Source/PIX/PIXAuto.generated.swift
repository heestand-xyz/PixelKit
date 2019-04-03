// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import CoreGraphics

public enum AutoPIXGenerator: String, CaseIterable {
	case arcpix
	case circlepix
	case colorpix
	case gradientpix
	case linepix
	case noisepix
	case polygonpix
	case rectanglepix
	public var pixType: PIXGenerator.Type {
		switch self {
		case .arcpix: return ArcPIX.self
		case .circlepix: return CirclePIX.self
		case .colorpix: return ColorPIX.self
		case .gradientpix: return GradientPIX.self
		case .linepix: return LinePIX.self
		case .noisepix: return NoisePIX.self
		case .polygonpix: return PolygonPIX.self
		case .rectanglepix: return RectanglePIX.self
		}
	}
	public func autoFloats(for pix: PIXGenerator) -> [AutoFloatProperty] {
		switch self {
		case .arcpix:
			return [
				AutoFloatProperty(name: "radius", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.radius] = value
				}),
				AutoFloatProperty(name: "angleFrom", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleFrom]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleFrom] = value
				}),
				AutoFloatProperty(name: "angleTo", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleTo]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleTo] = value
				}),
				AutoFloatProperty(name: "angleOffset", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleOffset]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleOffset] = value
				}),
				AutoFloatProperty(name: "edgeRadius", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.edgeRadius]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.edgeRadius] = value
				}),
			]
		case .circlepix:
			return [
				AutoFloatProperty(name: "radius", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.radius] = value
				}),
				AutoFloatProperty(name: "edgeRadius", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.edgeRadius]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.edgeRadius] = value
				}),
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
				AutoFloatProperty(name: "scale", getCallback: {
					return (pix as! GradientPIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! GradientPIX)[keyPath: \.scale] = value
				}),
				AutoFloatProperty(name: "offset", getCallback: {
					return (pix as! GradientPIX)[keyPath: \.offset]
				}, setCallback: { value in
					(pix as! GradientPIX)[keyPath: \.offset] = value
				}),
			]
		case .linepix:
			return [
				AutoFloatProperty(name: "scale", getCallback: {
					return (pix as! LinePIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.scale] = value
				}),
			]
		case .noisepix:
			return [
				AutoFloatProperty(name: "zPosition", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.zPosition]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.zPosition] = value
				}),
				AutoFloatProperty(name: "zoom", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.zoom]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.zoom] = value
				}),
			]
		case .polygonpix:
			return [
				AutoFloatProperty(name: "radius", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.radius] = value
				}),
				AutoFloatProperty(name: "rotation", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.rotation]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.rotation] = value
				}),
			]
		case .rectanglepix:
			return [
				AutoFloatProperty(name: "cornerRadius", getCallback: {
					return (pix as! RectanglePIX)[keyPath: \.cornerRadius]
				}, setCallback: { value in
					(pix as! RectanglePIX)[keyPath: \.cornerRadius] = value
				}),
			]
		}	
	}
	public func autoInts(for pix: PIXGenerator) -> [AutoIntProperty] {
		switch self {
		case .arcpix:
			return [
			]
		case .circlepix:
			return [
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
			]
		case .linepix:
			return [
			]
		case .noisepix:
			return [
				AutoIntProperty(name: "seed", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.seed]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.seed] = value
				}),
				AutoIntProperty(name: "octaves", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.octaves]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.octaves] = value
				}),
			]
		case .polygonpix:
			return [
				AutoIntProperty(name: "vertexCount", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.vertexCount]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.vertexCount] = value
				}),
			]
		case .rectanglepix:
			return [
			]
		}	
	}
	public func autoBools(for pix: PIXGenerator) -> [AutoBoolProperty] {
		switch self {
		case .arcpix:
			return [
			]
		case .circlepix:
			return [
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
			]
		case .linepix:
			return [
			]
		case .noisepix:
			return [
				AutoBoolProperty(name: "colored", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.colored]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.colored] = value
				}),
				AutoBoolProperty(name: "random", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.random]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.random] = value
				}),
			]
		case .polygonpix:
			return [
			]
		case .rectanglepix:
			return [
			]
		}	
	}
	public func autoColors(for pix: PIXGenerator) -> [AutoColorProperty] {
		switch self {
		case .arcpix:
			return [
				AutoColorProperty(name: "fillColor", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.fillColor]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.fillColor] = value
				}),
				AutoColorProperty(name: "edgeColor", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.edgeColor]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.edgeColor] = value
				}),
				AutoColorProperty(name: "bgColor", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.bgColor]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.bgColor] = value
				}),
			]
		case .circlepix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.color] = value
				}),
				AutoColorProperty(name: "edgeColor", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.edgeColor]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.edgeColor] = value
				}),
				AutoColorProperty(name: "bgColor", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.bgColor]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.bgColor] = value
				}),
			]
		case .colorpix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! ColorPIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! ColorPIX)[keyPath: \.color] = value
				}),
			]
		case .gradientpix:
			return [
			]
		case .linepix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! LinePIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.color] = value
				}),
				AutoColorProperty(name: "bgColor", getCallback: {
					return (pix as! LinePIX)[keyPath: \.bgColor]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.bgColor] = value
				}),
			]
		case .noisepix:
			return [
			]
		case .polygonpix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.color] = value
				}),
				AutoColorProperty(name: "bgColor", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.bgColor]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.bgColor] = value
				}),
			]
		case .rectanglepix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! RectanglePIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! RectanglePIX)[keyPath: \.color] = value
				}),
				AutoColorProperty(name: "bgColor", getCallback: {
					return (pix as! RectanglePIX)[keyPath: \.bgColor]
				}, setCallback: { value in
					(pix as! RectanglePIX)[keyPath: \.bgColor] = value
				}),
			]
		}	
	}
	public func autoPoints(for pix: PIXGenerator) -> [AutoPointProperty] {
		switch self {
		case .arcpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.position] = value
				}),
			]
		case .circlepix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.position] = value
				}),
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! GradientPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! GradientPIX)[keyPath: \.position] = value
				}),
			]
		case .linepix:
			return [
				AutoPointProperty(name: "positionFrom", getCallback: {
					return (pix as! LinePIX)[keyPath: \.positionFrom]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.positionFrom] = value
				}),
				AutoPointProperty(name: "positionTo", getCallback: {
					return (pix as! LinePIX)[keyPath: \.positionTo]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.positionTo] = value
				}),
			]
		case .noisepix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.position] = value
				}),
			]
		case .polygonpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.position] = value
				}),
			]
		case .rectanglepix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! RectanglePIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! RectanglePIX)[keyPath: \.position] = value
				}),
			]
		}	
	}
	public func autoSizes(for pix: PIXGenerator) -> [AutoSizeProperty] {
		switch self {
		case .arcpix:
			return [
			]
		case .circlepix:
			return [
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
			]
		case .linepix:
			return [
			]
		case .noisepix:
			return [
			]
		case .polygonpix:
			return [
			]
		case .rectanglepix:
			return [
				AutoSizeProperty(name: "size", getCallback: {
					return (pix as! RectanglePIX)[keyPath: \.size]
				}, setCallback: { value in
					(pix as! RectanglePIX)[keyPath: \.size] = value
				}),
			]
		}	
	}
	public func autoRects(for pix: PIXGenerator) -> [AutoRectProperty] {
		switch self {
		case .arcpix:
			return [
			]
		case .circlepix:
			return [
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
			]
		case .linepix:
			return [
			]
		case .noisepix:
			return [
			]
		case .polygonpix:
			return [
			]
		case .rectanglepix:
			return [
			]
		}	
	}
}


public enum AutoPIXSingleEffect: String, CaseIterable {
	case blurpix
	case channelmixpix
	case chromakeypix
	case clamppix
	case cornerpinpix
	case croppix
	case delaypix
	case edgepix
	case flarepix
	case flipfloppix
	case freezepix
	case huesatpix
	case kaleidoscopepix
	case levelspix
	case quantizepix
	case rangepix
	case sepiapix
	case sharpenpix
	case slopepix
	case thresholdpix
	case transformpix
	case twirlpix
	public var pixType: PIXSingleEffect.Type {
		switch self {
		case .blurpix: return BlurPIX.self
		case .channelmixpix: return ChannelMixPIX.self
		case .chromakeypix: return ChromaKeyPIX.self
		case .clamppix: return ClampPIX.self
		case .cornerpinpix: return CornerPinPIX.self
		case .croppix: return CropPIX.self
		case .delaypix: return DelayPIX.self
		case .edgepix: return EdgePIX.self
		case .flarepix: return FlarePIX.self
		case .flipfloppix: return FlipFlopPIX.self
		case .freezepix: return FreezePIX.self
		case .huesatpix: return HueSatPIX.self
		case .kaleidoscopepix: return KaleidoscopePIX.self
		case .levelspix: return LevelsPIX.self
		case .quantizepix: return QuantizePIX.self
		case .rangepix: return RangePIX.self
		case .sepiapix: return SepiaPIX.self
		case .sharpenpix: return SharpenPIX.self
		case .slopepix: return SlopePIX.self
		case .thresholdpix: return ThresholdPIX.self
		case .transformpix: return TransformPIX.self
		case .twirlpix: return TwirlPIX.self
		}
	}
	public func autoFloats(for pix: PIXSingleEffect) -> [AutoFloatProperty] {
		switch self {
		case .blurpix:
			return [
				AutoFloatProperty(name: "radius", getCallback: {
					return (pix as! BlurPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! BlurPIX)[keyPath: \.radius] = value
				}),
				AutoFloatProperty(name: "angle", getCallback: {
					return (pix as! BlurPIX)[keyPath: \.angle]
				}, setCallback: { value in
					(pix as! BlurPIX)[keyPath: \.angle] = value
				}),
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
				AutoFloatProperty(name: "range", getCallback: {
					return (pix as! ChromaKeyPIX)[keyPath: \.range]
				}, setCallback: { value in
					(pix as! ChromaKeyPIX)[keyPath: \.range] = value
				}),
				AutoFloatProperty(name: "softness", getCallback: {
					return (pix as! ChromaKeyPIX)[keyPath: \.softness]
				}, setCallback: { value in
					(pix as! ChromaKeyPIX)[keyPath: \.softness] = value
				}),
				AutoFloatProperty(name: "edgeDesaturation", getCallback: {
					return (pix as! ChromaKeyPIX)[keyPath: \.edgeDesaturation]
				}, setCallback: { value in
					(pix as! ChromaKeyPIX)[keyPath: \.edgeDesaturation] = value
				}),
			]
		case .clamppix:
			return [
				AutoFloatProperty(name: "low", getCallback: {
					return (pix as! ClampPIX)[keyPath: \.low]
				}, setCallback: { value in
					(pix as! ClampPIX)[keyPath: \.low] = value
				}),
				AutoFloatProperty(name: "high", getCallback: {
					return (pix as! ClampPIX)[keyPath: \.high]
				}, setCallback: { value in
					(pix as! ClampPIX)[keyPath: \.high] = value
				}),
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
				AutoFloatProperty(name: "strength", getCallback: {
					return (pix as! EdgePIX)[keyPath: \.strength]
				}, setCallback: { value in
					(pix as! EdgePIX)[keyPath: \.strength] = value
				}),
				AutoFloatProperty(name: "distance", getCallback: {
					return (pix as! EdgePIX)[keyPath: \.distance]
				}, setCallback: { value in
					(pix as! EdgePIX)[keyPath: \.distance] = value
				}),
			]
		case .flarepix:
			return [
				AutoFloatProperty(name: "scale", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.scale] = value
				}),
				AutoFloatProperty(name: "angle", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.angle]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.angle] = value
				}),
				AutoFloatProperty(name: "threshold", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.threshold]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.threshold] = value
				}),
				AutoFloatProperty(name: "brightness", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.brightness]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.brightness] = value
				}),
				AutoFloatProperty(name: "gamma", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.gamma]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.gamma] = value
				}),
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
				AutoFloatProperty(name: "hue", getCallback: {
					return (pix as! HueSatPIX)[keyPath: \.hue]
				}, setCallback: { value in
					(pix as! HueSatPIX)[keyPath: \.hue] = value
				}),
				AutoFloatProperty(name: "sat", getCallback: {
					return (pix as! HueSatPIX)[keyPath: \.sat]
				}, setCallback: { value in
					(pix as! HueSatPIX)[keyPath: \.sat] = value
				}),
			]
		case .kaleidoscopepix:
			return [
				AutoFloatProperty(name: "rotation", getCallback: {
					return (pix as! KaleidoscopePIX)[keyPath: \.rotation]
				}, setCallback: { value in
					(pix as! KaleidoscopePIX)[keyPath: \.rotation] = value
				}),
			]
		case .levelspix:
			return [
				AutoFloatProperty(name: "brightness", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.brightness]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.brightness] = value
				}),
				AutoFloatProperty(name: "darkness", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.darkness]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.darkness] = value
				}),
				AutoFloatProperty(name: "contrast", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.contrast]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.contrast] = value
				}),
				AutoFloatProperty(name: "gamma", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.gamma]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.gamma] = value
				}),
				AutoFloatProperty(name: "opacity", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.opacity]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.opacity] = value
				}),
			]
		case .quantizepix:
			return [
				AutoFloatProperty(name: "fraction", getCallback: {
					return (pix as! QuantizePIX)[keyPath: \.fraction]
				}, setCallback: { value in
					(pix as! QuantizePIX)[keyPath: \.fraction] = value
				}),
			]
		case .rangepix:
			return [
				AutoFloatProperty(name: "inLow", getCallback: {
					return (pix as! RangePIX)[keyPath: \.inLow]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.inLow] = value
				}),
				AutoFloatProperty(name: "inHigh", getCallback: {
					return (pix as! RangePIX)[keyPath: \.inHigh]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.inHigh] = value
				}),
				AutoFloatProperty(name: "outLow", getCallback: {
					return (pix as! RangePIX)[keyPath: \.outLow]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.outLow] = value
				}),
				AutoFloatProperty(name: "outHigh", getCallback: {
					return (pix as! RangePIX)[keyPath: \.outHigh]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.outHigh] = value
				}),
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
				AutoFloatProperty(name: "contrast", getCallback: {
					return (pix as! SharpenPIX)[keyPath: \.contrast]
				}, setCallback: { value in
					(pix as! SharpenPIX)[keyPath: \.contrast] = value
				}),
			]
		case .slopepix:
			return [
				AutoFloatProperty(name: "amplitude", getCallback: {
					return (pix as! SlopePIX)[keyPath: \.amplitude]
				}, setCallback: { value in
					(pix as! SlopePIX)[keyPath: \.amplitude] = value
				}),
			]
		case .thresholdpix:
			return [
				AutoFloatProperty(name: "threshold", getCallback: {
					return (pix as! ThresholdPIX)[keyPath: \.threshold]
				}, setCallback: { value in
					(pix as! ThresholdPIX)[keyPath: \.threshold] = value
				}),
			]
		case .transformpix:
			return [
				AutoFloatProperty(name: "rotation", getCallback: {
					return (pix as! TransformPIX)[keyPath: \.rotation]
				}, setCallback: { value in
					(pix as! TransformPIX)[keyPath: \.rotation] = value
				}),
				AutoFloatProperty(name: "scale", getCallback: {
					return (pix as! TransformPIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! TransformPIX)[keyPath: \.scale] = value
				}),
			]
		case .twirlpix:
			return [
				AutoFloatProperty(name: "strength", getCallback: {
					return (pix as! TwirlPIX)[keyPath: \.strength]
				}, setCallback: { value in
					(pix as! TwirlPIX)[keyPath: \.strength] = value
				}),
			]
		}	
	}
	public func autoInts(for pix: PIXSingleEffect) -> [AutoIntProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
			]
		case .clamppix:
			return [
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
				AutoIntProperty(name: "count", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.count]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.count] = value
				}),
				AutoIntProperty(name: "rayRes", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.rayRes]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.rayRes] = value
				}),
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoIntProperty(name: "divisions", getCallback: {
					return (pix as! KaleidoscopePIX)[keyPath: \.divisions]
				}, setCallback: { value in
					(pix as! KaleidoscopePIX)[keyPath: \.divisions] = value
				}),
			]
		case .levelspix:
			return [
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
			]
		case .transformpix:
			return [
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoBools(for pix: PIXSingleEffect) -> [AutoBoolProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
				AutoBoolProperty(name: "premultiply", getCallback: {
					return (pix as! ChromaKeyPIX)[keyPath: \.premultiply]
				}, setCallback: { value in
					(pix as! ChromaKeyPIX)[keyPath: \.premultiply] = value
				}),
			]
		case .clamppix:
			return [
				AutoBoolProperty(name: "clampAlpha", getCallback: {
					return (pix as! ClampPIX)[keyPath: \.clampAlpha]
				}, setCallback: { value in
					(pix as! ClampPIX)[keyPath: \.clampAlpha] = value
				}),
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
				AutoBoolProperty(name: "freeze", getCallback: {
					return (pix as! FreezePIX)[keyPath: \.freeze]
				}, setCallback: { value in
					(pix as! FreezePIX)[keyPath: \.freeze] = value
				}),
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoBoolProperty(name: "mirror", getCallback: {
					return (pix as! KaleidoscopePIX)[keyPath: \.mirror]
				}, setCallback: { value in
					(pix as! KaleidoscopePIX)[keyPath: \.mirror] = value
				}),
			]
		case .levelspix:
			return [
				AutoBoolProperty(name: "inverted", getCallback: {
					return (pix as! LevelsPIX)[keyPath: \.inverted]
				}, setCallback: { value in
					(pix as! LevelsPIX)[keyPath: \.inverted] = value
				}),
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
				AutoBoolProperty(name: "ignoreAlpha", getCallback: {
					return (pix as! RangePIX)[keyPath: \.ignoreAlpha]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.ignoreAlpha] = value
				}),
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
				AutoBoolProperty(name: "smooth", getCallback: {
					return (pix as! ThresholdPIX)[keyPath: \.smooth]
				}, setCallback: { value in
					(pix as! ThresholdPIX)[keyPath: \.smooth] = value
				}),
			]
		case .transformpix:
			return [
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoColors(for pix: PIXSingleEffect) -> [AutoColorProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
				AutoColorProperty(name: "red", getCallback: {
					return (pix as! ChannelMixPIX)[keyPath: \.red]
				}, setCallback: { value in
					(pix as! ChannelMixPIX)[keyPath: \.red] = value
				}),
				AutoColorProperty(name: "green", getCallback: {
					return (pix as! ChannelMixPIX)[keyPath: \.green]
				}, setCallback: { value in
					(pix as! ChannelMixPIX)[keyPath: \.green] = value
				}),
				AutoColorProperty(name: "blue", getCallback: {
					return (pix as! ChannelMixPIX)[keyPath: \.blue]
				}, setCallback: { value in
					(pix as! ChannelMixPIX)[keyPath: \.blue] = value
				}),
				AutoColorProperty(name: "alpha", getCallback: {
					return (pix as! ChannelMixPIX)[keyPath: \.alpha]
				}, setCallback: { value in
					(pix as! ChannelMixPIX)[keyPath: \.alpha] = value
				}),
			]
		case .chromakeypix:
			return [
				AutoColorProperty(name: "keyColor", getCallback: {
					return (pix as! ChromaKeyPIX)[keyPath: \.keyColor]
				}, setCallback: { value in
					(pix as! ChromaKeyPIX)[keyPath: \.keyColor] = value
				}),
			]
		case .clamppix:
			return [
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! FlarePIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! FlarePIX)[keyPath: \.color] = value
				}),
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
			]
		case .levelspix:
			return [
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
				AutoColorProperty(name: "inLowColor", getCallback: {
					return (pix as! RangePIX)[keyPath: \.inLowColor]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.inLowColor] = value
				}),
				AutoColorProperty(name: "inHighColor", getCallback: {
					return (pix as! RangePIX)[keyPath: \.inHighColor]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.inHighColor] = value
				}),
				AutoColorProperty(name: "outLowColor", getCallback: {
					return (pix as! RangePIX)[keyPath: \.outLowColor]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.outLowColor] = value
				}),
				AutoColorProperty(name: "outHighColor", getCallback: {
					return (pix as! RangePIX)[keyPath: \.outHighColor]
				}, setCallback: { value in
					(pix as! RangePIX)[keyPath: \.outHighColor] = value
				}),
			]
		case .sepiapix:
			return [
				AutoColorProperty(name: "color", getCallback: {
					return (pix as! SepiaPIX)[keyPath: \.color]
				}, setCallback: { value in
					(pix as! SepiaPIX)[keyPath: \.color] = value
				}),
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
			]
		case .transformpix:
			return [
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoPoints(for pix: PIXSingleEffect) -> [AutoPointProperty] {
		switch self {
		case .blurpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! BlurPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! BlurPIX)[keyPath: \.position] = value
				}),
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
			]
		case .clamppix:
			return [
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! KaleidoscopePIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! KaleidoscopePIX)[keyPath: \.position] = value
				}),
			]
		case .levelspix:
			return [
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
			]
		case .transformpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! TransformPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! TransformPIX)[keyPath: \.position] = value
				}),
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoSizes(for pix: PIXSingleEffect) -> [AutoSizeProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
			]
		case .clamppix:
			return [
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
			]
		case .levelspix:
			return [
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
			]
		case .transformpix:
			return [
				AutoSizeProperty(name: "size", getCallback: {
					return (pix as! TransformPIX)[keyPath: \.size]
				}, setCallback: { value in
					(pix as! TransformPIX)[keyPath: \.size] = value
				}),
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoRects(for pix: PIXSingleEffect) -> [AutoRectProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
			]
		case .clamppix:
			return [
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .delaypix:
			return [
			]
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
			]
		case .freezepix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
			]
		case .levelspix:
			return [
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
			]
		case .slopepix:
			return [
			]
		case .thresholdpix:
			return [
			]
		case .transformpix:
			return [
			]
		case .twirlpix:
			return [
			]
		}	
	}
}


public enum AutoPIXMergerEffect: String, CaseIterable {
	case blendpix
	case crosspix
	case displacepix
	case lookuppix
	case lumablurpix
	case remappix
	case reorderpix
	case timemachinepix
	public var pixType: PIXMergerEffect.Type {
		switch self {
		case .blendpix: return BlendPIX.self
		case .crosspix: return CrossPIX.self
		case .displacepix: return DisplacePIX.self
		case .lookuppix: return LookupPIX.self
		case .lumablurpix: return LumaBlurPIX.self
		case .remappix: return RemapPIX.self
		case .reorderpix: return ReorderPIX.self
		case .timemachinepix: return TimeMachinePIX.self
		}
	}
	public func autoFloats(for pix: PIXMergerEffect) -> [AutoFloatProperty] {
		switch self {
		case .blendpix:
			return [
				AutoFloatProperty(name: "rotation", getCallback: {
					return (pix as! BlendPIX)[keyPath: \.rotation]
				}, setCallback: { value in
					(pix as! BlendPIX)[keyPath: \.rotation] = value
				}),
				AutoFloatProperty(name: "scale", getCallback: {
					return (pix as! BlendPIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! BlendPIX)[keyPath: \.scale] = value
				}),
			]
		case .crosspix:
			return [
				AutoFloatProperty(name: "fraction", getCallback: {
					return (pix as! CrossPIX)[keyPath: \.fraction]
				}, setCallback: { value in
					(pix as! CrossPIX)[keyPath: \.fraction] = value
				}),
			]
		case .displacepix:
			return [
				AutoFloatProperty(name: "distance", getCallback: {
					return (pix as! DisplacePIX)[keyPath: \.distance]
				}, setCallback: { value in
					(pix as! DisplacePIX)[keyPath: \.distance] = value
				}),
				AutoFloatProperty(name: "origin", getCallback: {
					return (pix as! DisplacePIX)[keyPath: \.origin]
				}, setCallback: { value in
					(pix as! DisplacePIX)[keyPath: \.origin] = value
				}),
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
				AutoFloatProperty(name: "radius", getCallback: {
					return (pix as! LumaBlurPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! LumaBlurPIX)[keyPath: \.radius] = value
				}),
				AutoFloatProperty(name: "angle", getCallback: {
					return (pix as! LumaBlurPIX)[keyPath: \.angle]
				}, setCallback: { value in
					(pix as! LumaBlurPIX)[keyPath: \.angle] = value
				}),
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
				AutoFloatProperty(name: "seconds", getCallback: {
					return (pix as! TimeMachinePIX)[keyPath: \.seconds]
				}, setCallback: { value in
					(pix as! TimeMachinePIX)[keyPath: \.seconds] = value
				}),
			]
		}	
	}
	public func autoInts(for pix: PIXMergerEffect) -> [AutoIntProperty] {
		switch self {
		case .blendpix:
			return [
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
	public func autoBools(for pix: PIXMergerEffect) -> [AutoBoolProperty] {
		switch self {
		case .blendpix:
			return [
				AutoBoolProperty(name: "bypassTransform", getCallback: {
					return (pix as! BlendPIX)[keyPath: \.bypassTransform]
				}, setCallback: { value in
					(pix as! BlendPIX)[keyPath: \.bypassTransform] = value
				}),
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
	public func autoColors(for pix: PIXMergerEffect) -> [AutoColorProperty] {
		switch self {
		case .blendpix:
			return [
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
	public func autoPoints(for pix: PIXMergerEffect) -> [AutoPointProperty] {
		switch self {
		case .blendpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! BlendPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! BlendPIX)[keyPath: \.position] = value
				}),
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
				AutoPointProperty(name: "position", getCallback: {
					return (pix as! LumaBlurPIX)[keyPath: \.position]
				}, setCallback: { value in
					(pix as! LumaBlurPIX)[keyPath: \.position] = value
				}),
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
	public func autoSizes(for pix: PIXMergerEffect) -> [AutoSizeProperty] {
		switch self {
		case .blendpix:
			return [
				AutoSizeProperty(name: "size", getCallback: {
					return (pix as! BlendPIX)[keyPath: \.size]
				}, setCallback: { value in
					(pix as! BlendPIX)[keyPath: \.size] = value
				}),
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
	public func autoRects(for pix: PIXMergerEffect) -> [AutoRectProperty] {
		switch self {
		case .blendpix:
			return [
			]
		case .crosspix:
			return [
			]
		case .displacepix:
			return [
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		case .timemachinepix:
			return [
			]
		}	
	}
}


public enum AutoPIXMultiEffect: String, CaseIterable {
	case blendspix
	public var pixType: PIXMultiEffect.Type {
		switch self {
		case .blendspix: return BlendsPIX.self
		}
	}
	public func autoFloats(for pix: PIXMultiEffect) -> [AutoFloatProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoInts(for pix: PIXMultiEffect) -> [AutoIntProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoBools(for pix: PIXMultiEffect) -> [AutoBoolProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoColors(for pix: PIXMultiEffect) -> [AutoColorProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoPoints(for pix: PIXMultiEffect) -> [AutoPointProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoSizes(for pix: PIXMultiEffect) -> [AutoSizeProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
	public func autoRects(for pix: PIXMultiEffect) -> [AutoRectProperty] {
		switch self {
		case .blendspix:
			return [
			]
		}	
	}
}
