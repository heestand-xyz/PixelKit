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
				AutoFloatPropertyArcPIX(name: "radius", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.radius] = value
				}),
				AutoFloatPropertyArcPIX(name: "angleFrom", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleFrom]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleFrom] = value
				}),
				AutoFloatPropertyArcPIX(name: "angleTo", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleTo]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleTo] = value
				}),
				AutoFloatPropertyArcPIX(name: "angleOffset", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.angleOffset]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.angleOffset] = value
				}),
				AutoFloatPropertyArcPIX(name: "edgeRadius", getCallback: {
					return (pix as! ArcPIX)[keyPath: \.edgeRadius]
				}, setCallback: { value in
					(pix as! ArcPIX)[keyPath: \.edgeRadius] = value
				}),
			]
		case .circlepix:
			return [
				AutoFloatPropertyCirclePIX(name: "radius", getCallback: {
					return (pix as! CirclePIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! CirclePIX)[keyPath: \.radius] = value
				}),
				AutoFloatPropertyCirclePIX(name: "edgeRadius", getCallback: {
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
				AutoFloatPropertyGradientPIX(name: "scale", getCallback: {
					return (pix as! GradientPIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! GradientPIX)[keyPath: \.scale] = value
				}),
				AutoFloatPropertyGradientPIX(name: "offset", getCallback: {
					return (pix as! GradientPIX)[keyPath: \.offset]
				}, setCallback: { value in
					(pix as! GradientPIX)[keyPath: \.offset] = value
				}),
			]
		case .linepix:
			return [
				AutoFloatPropertyLinePIX(name: "scale", getCallback: {
					return (pix as! LinePIX)[keyPath: \.scale]
				}, setCallback: { value in
					(pix as! LinePIX)[keyPath: \.scale] = value
				}),
			]
		case .noisepix:
			return [
				AutoFloatPropertyNoisePIX(name: "zPosition", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.zPosition]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.zPosition] = value
				}),
				AutoFloatPropertyNoisePIX(name: "zoom", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.zoom]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.zoom] = value
				}),
			]
		case .polygonpix:
			return [
				AutoFloatPropertyPolygonPIX(name: "radius", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.radius]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.radius] = value
				}),
				AutoFloatPropertyPolygonPIX(name: "rotation", getCallback: {
					return (pix as! PolygonPIX)[keyPath: \.rotation]
				}, setCallback: { value in
					(pix as! PolygonPIX)[keyPath: \.rotation] = value
				}),
			]
		case .rectanglepix:
			return [
				AutoFloatPropertyRectanglePIX(name: "cornerRadius", getCallback: {
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
				AutoIntPropertyNoisePIX(name: "seed", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.seed]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.seed] = value
				}),
				AutoIntPropertyNoisePIX(name: "octaves", getCallback: {
					return (pix as! NoisePIX)[keyPath: \.octaves]
				}, setCallback: { value in
					(pix as! NoisePIX)[keyPath: \.octaves] = value
				}),
			]
		case .polygonpix:
			return [
				AutoIntPropertyPolygonPIX(name: "vertexCount", getCallback: {
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
}

class AutoFloatPropertyArcPIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyCirclePIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyColorPIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyGradientPIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyLinePIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyNoisePIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyPolygonPIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}
class AutoFloatPropertyRectanglePIX: AutoFloatProperty {
	let name: String
	let getCallback: () -> (LiveFloat)
	let setCallback: (LiveFloat) -> ()
	init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveFloat {
        return getCallback()
    }
	func set(_ value: LiveFloat) {
     	setCallback(value)
    }    
}

class AutoIntPropertyArcPIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyCirclePIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyColorPIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyGradientPIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyLinePIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyNoisePIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyPolygonPIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}
class AutoIntPropertyRectanglePIX: AutoIntProperty {
	let name: String
	let getCallback: () -> (LiveInt)
	let setCallback: (LiveInt) -> ()
	init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
		self.name = name
		self.getCallback = getCallback
		self.setCallback = setCallback
	}
    func get() -> LiveInt {
        return getCallback()
    }
	func set(_ value: LiveInt) {
     	setCallback(value)
    }    
}









public enum AutoPIXSingleEffect {
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
}

public enum AutoPIXMergerEffect {
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
}

public enum AutoPIXMultiEffect {
	case blendspix
	public var pixType: PIXMultiEffect.Type {
		switch self {
		case .blendspix: return BlendsPIX.self
		}
	}
}
