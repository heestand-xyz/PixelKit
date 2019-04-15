// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// MARK - PIXGenerator

public enum AutoPIXGenerator: String, Codable, CaseIterable {

	case arcpix
	case circlepix
	case colorpix
	case gradientpix
	case linepix
	case noisepix
	case polygonpix
	case rectanglepix

	public var name: String {
		switch self {
		case .arcpix: return "ArcPIX"
		case .circlepix: return "CirclePIX"
		case .colorpix: return "ColorPIX"
		case .gradientpix: return "GradientPIX"
		case .linepix: return "LinePIX"
		case .noisepix: return "NoisePIX"
		case .polygonpix: return "PolygonPIX"
		case .rectanglepix: return "RectanglePIX"
		}
	}

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

	public func autoLiveBools(for pix: PIXGenerator) -> [AutoLiveBoolProperty] {
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
				AutoLiveBoolProperty(name: "colored", getCallback: {
					return (pix as! NoisePIX).colored
				}, setCallback: { value in
					(pix as! NoisePIX).colored = value
				}),
				AutoLiveBoolProperty(name: "random", getCallback: {
					return (pix as! NoisePIX).random
				}, setCallback: { value in
					(pix as! NoisePIX).random = value
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
	public func autoLiveColors(for pix: PIXGenerator) -> [AutoLiveColorProperty] {
		switch self {
		case .arcpix:
			return [
				AutoLiveColorProperty(name: "fillColor", getCallback: {
					return (pix as! ArcPIX).fillColor
				}, setCallback: { value in
					(pix as! ArcPIX).fillColor = value
				}),
			]
		case .circlepix:
			return [
				AutoLiveColorProperty(name: "edgeColor", getCallback: {
					return (pix as! CirclePIX).edgeColor
				}, setCallback: { value in
					(pix as! CirclePIX).edgeColor = value
				}),
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
	public func autoLiveFloats(for pix: PIXGenerator) -> [AutoLiveFloatProperty] {
		switch self {
		case .arcpix:
			return [
				AutoLiveFloatProperty(name: "radius", getCallback: {
					return (pix as! ArcPIX).radius
				}, setCallback: { value in
					(pix as! ArcPIX).radius = value
				}),
				AutoLiveFloatProperty(name: "angleFrom", getCallback: {
					return (pix as! ArcPIX).angleFrom
				}, setCallback: { value in
					(pix as! ArcPIX).angleFrom = value
				}),
				AutoLiveFloatProperty(name: "angleTo", getCallback: {
					return (pix as! ArcPIX).angleTo
				}, setCallback: { value in
					(pix as! ArcPIX).angleTo = value
				}),
				AutoLiveFloatProperty(name: "angleOffset", getCallback: {
					return (pix as! ArcPIX).angleOffset
				}, setCallback: { value in
					(pix as! ArcPIX).angleOffset = value
				}),
				AutoLiveFloatProperty(name: "edgeRadius", getCallback: {
					return (pix as! ArcPIX).edgeRadius
				}, setCallback: { value in
					(pix as! ArcPIX).edgeRadius = value
				}),
			]
		case .circlepix:
			return [
				AutoLiveFloatProperty(name: "radius", getCallback: {
					return (pix as! CirclePIX).radius
				}, setCallback: { value in
					(pix as! CirclePIX).radius = value
				}),
				AutoLiveFloatProperty(name: "edgeRadius", getCallback: {
					return (pix as! CirclePIX).edgeRadius
				}, setCallback: { value in
					(pix as! CirclePIX).edgeRadius = value
				}),
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
				AutoLiveFloatProperty(name: "scale", getCallback: {
					return (pix as! GradientPIX).scale
				}, setCallback: { value in
					(pix as! GradientPIX).scale = value
				}),
				AutoLiveFloatProperty(name: "offset", getCallback: {
					return (pix as! GradientPIX).offset
				}, setCallback: { value in
					(pix as! GradientPIX).offset = value
				}),
			]
		case .linepix:
			return [
				AutoLiveFloatProperty(name: "scale", getCallback: {
					return (pix as! LinePIX).scale
				}, setCallback: { value in
					(pix as! LinePIX).scale = value
				}),
			]
		case .noisepix:
			return [
				AutoLiveFloatProperty(name: "zPosition", getCallback: {
					return (pix as! NoisePIX).zPosition
				}, setCallback: { value in
					(pix as! NoisePIX).zPosition = value
				}),
				AutoLiveFloatProperty(name: "zoom", getCallback: {
					return (pix as! NoisePIX).zoom
				}, setCallback: { value in
					(pix as! NoisePIX).zoom = value
				}),
			]
		case .polygonpix:
			return [
				AutoLiveFloatProperty(name: "radius", getCallback: {
					return (pix as! PolygonPIX).radius
				}, setCallback: { value in
					(pix as! PolygonPIX).radius = value
				}),
				AutoLiveFloatProperty(name: "rotation", getCallback: {
					return (pix as! PolygonPIX).rotation
				}, setCallback: { value in
					(pix as! PolygonPIX).rotation = value
				}),
				AutoLiveFloatProperty(name: "cornerRadius", getCallback: {
					return (pix as! PolygonPIX).cornerRadius
				}, setCallback: { value in
					(pix as! PolygonPIX).cornerRadius = value
				}),
			]
		case .rectanglepix:
			return [
				AutoLiveFloatProperty(name: "cornerRadius", getCallback: {
					return (pix as! RectanglePIX).cornerRadius
				}, setCallback: { value in
					(pix as! RectanglePIX).cornerRadius = value
				}),
			]
		}	
	}
	public func autoLiveInts(for pix: PIXGenerator) -> [AutoLiveIntProperty] {
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
				AutoLiveIntProperty(name: "seed", getCallback: {
					return (pix as! NoisePIX).seed
				}, setCallback: { value in
					(pix as! NoisePIX).seed = value
				}),
				AutoLiveIntProperty(name: "octaves", getCallback: {
					return (pix as! NoisePIX).octaves
				}, setCallback: { value in
					(pix as! NoisePIX).octaves = value
				}),
			]
		case .polygonpix:
			return [
				AutoLiveIntProperty(name: "vertexCount", getCallback: {
					return (pix as! PolygonPIX).vertexCount
				}, setCallback: { value in
					(pix as! PolygonPIX).vertexCount = value
				}),
			]
		case .rectanglepix:
			return [
			]
		}	
	}
	public func autoLivePoints(for pix: PIXGenerator) -> [AutoLivePointProperty] {
		switch self {
		case .arcpix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! ArcPIX).position
				}, setCallback: { value in
					(pix as! ArcPIX).position = value
				}),
			]
		case .circlepix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! CirclePIX).position
				}, setCallback: { value in
					(pix as! CirclePIX).position = value
				}),
			]
		case .colorpix:
			return [
			]
		case .gradientpix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! GradientPIX).position
				}, setCallback: { value in
					(pix as! GradientPIX).position = value
				}),
			]
		case .linepix:
			return [
				AutoLivePointProperty(name: "positionFrom", getCallback: {
					return (pix as! LinePIX).positionFrom
				}, setCallback: { value in
					(pix as! LinePIX).positionFrom = value
				}),
				AutoLivePointProperty(name: "positionTo", getCallback: {
					return (pix as! LinePIX).positionTo
				}, setCallback: { value in
					(pix as! LinePIX).positionTo = value
				}),
			]
		case .noisepix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! NoisePIX).position
				}, setCallback: { value in
					(pix as! NoisePIX).position = value
				}),
			]
		case .polygonpix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! PolygonPIX).position
				}, setCallback: { value in
					(pix as! PolygonPIX).position = value
				}),
			]
		case .rectanglepix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! RectanglePIX).position
				}, setCallback: { value in
					(pix as! RectanglePIX).position = value
				}),
			]
		}	
	}
	public func autoLiveRects(for pix: PIXGenerator) -> [AutoLiveRectProperty] {
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
	public func autoLiveSizes(for pix: PIXGenerator) -> [AutoLiveSizeProperty] {
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
				AutoLiveSizeProperty(name: "size", getCallback: {
					return (pix as! RectanglePIX).size
				}, setCallback: { value in
					(pix as! RectanglePIX).size = value
				}),
			]
		}	
	}

	public func autoEnums(for pix: PIXGenerator) -> [AutoEnumProperty] {
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
				AutoEnumProperty(name: "direction", cases: [
						"horizontal",
						"vertical",
						"radial",
						"angle",
				], getCallback: {
					return (pix as! GradientPIX).direction.rawValue
				}, setCallback: { value in
					(pix as! GradientPIX).direction = GradientPIX.Direction(rawValue: value) ?? .horizontal
				}),
				AutoEnumProperty(name: "extendRamp", cases: [
						"hold",
						"zero",
						"loop",
						"mirror",
				], getCallback: {
					return (pix as! GradientPIX).extendRamp.rawValue
				}, setCallback: { value in
					(pix as! GradientPIX).extendRamp = PIX.ExtendMode(rawValue: value) ?? .hold
				}),
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


// MARK - PIXMergerEffect

public enum AutoPIXMergerEffect: String, Codable, CaseIterable {

	case blendpix
	case crosspix
	case displacepix
	case lookuppix
	case lumablurpix
	case remappix
	case reorderpix

	public var name: String {
		switch self {
		case .blendpix: return "BlendPIX"
		case .crosspix: return "CrossPIX"
		case .displacepix: return "DisplacePIX"
		case .lookuppix: return "LookupPIX"
		case .lumablurpix: return "LumaBlurPIX"
		case .remappix: return "RemapPIX"
		case .reorderpix: return "ReorderPIX"
		}
	}

	public var pixType: PIXMergerEffect.Type {
		switch self {
		case .blendpix: return BlendPIX.self
		case .crosspix: return CrossPIX.self
		case .displacepix: return DisplacePIX.self
		case .lookuppix: return LookupPIX.self
		case .lumablurpix: return LumaBlurPIX.self
		case .remappix: return RemapPIX.self
		case .reorderpix: return ReorderPIX.self
		}
	}

	public func autoLiveBools(for pix: PIXMergerEffect) -> [AutoLiveBoolProperty] {
		switch self {
		case .blendpix:
			return [
				AutoLiveBoolProperty(name: "bypassTransform", getCallback: {
					return (pix as! BlendPIX).bypassTransform
				}, setCallback: { value in
					(pix as! BlendPIX).bypassTransform = value
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
		}	
	}
	public func autoLiveColors(for pix: PIXMergerEffect) -> [AutoLiveColorProperty] {
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
		}	
	}
	public func autoLiveFloats(for pix: PIXMergerEffect) -> [AutoLiveFloatProperty] {
		switch self {
		case .blendpix:
			return [
				AutoLiveFloatProperty(name: "rotation", getCallback: {
					return (pix as! BlendPIX).rotation
				}, setCallback: { value in
					(pix as! BlendPIX).rotation = value
				}),
				AutoLiveFloatProperty(name: "scale", getCallback: {
					return (pix as! BlendPIX).scale
				}, setCallback: { value in
					(pix as! BlendPIX).scale = value
				}),
			]
		case .crosspix:
			return [
				AutoLiveFloatProperty(name: "fraction", getCallback: {
					return (pix as! CrossPIX).fraction
				}, setCallback: { value in
					(pix as! CrossPIX).fraction = value
				}),
			]
		case .displacepix:
			return [
				AutoLiveFloatProperty(name: "distance", getCallback: {
					return (pix as! DisplacePIX).distance
				}, setCallback: { value in
					(pix as! DisplacePIX).distance = value
				}),
				AutoLiveFloatProperty(name: "origin", getCallback: {
					return (pix as! DisplacePIX).origin
				}, setCallback: { value in
					(pix as! DisplacePIX).origin = value
				}),
			]
		case .lookuppix:
			return [
			]
		case .lumablurpix:
			return [
				AutoLiveFloatProperty(name: "radius", getCallback: {
					return (pix as! LumaBlurPIX).radius
				}, setCallback: { value in
					(pix as! LumaBlurPIX).radius = value
				}),
				AutoLiveFloatProperty(name: "angle", getCallback: {
					return (pix as! LumaBlurPIX).angle
				}, setCallback: { value in
					(pix as! LumaBlurPIX).angle = value
				}),
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		}	
	}
	public func autoLiveInts(for pix: PIXMergerEffect) -> [AutoLiveIntProperty] {
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
		}	
	}
	public func autoLivePoints(for pix: PIXMergerEffect) -> [AutoLivePointProperty] {
		switch self {
		case .blendpix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! BlendPIX).position
				}, setCallback: { value in
					(pix as! BlendPIX).position = value
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
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! LumaBlurPIX).position
				}, setCallback: { value in
					(pix as! LumaBlurPIX).position = value
				}),
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
			]
		}	
	}
	public func autoLiveRects(for pix: PIXMergerEffect) -> [AutoLiveRectProperty] {
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
		}	
	}
	public func autoLiveSizes(for pix: PIXMergerEffect) -> [AutoLiveSizeProperty] {
		switch self {
		case .blendpix:
			return [
				AutoLiveSizeProperty(name: "size", getCallback: {
					return (pix as! BlendPIX).size
				}, setCallback: { value in
					(pix as! BlendPIX).size = value
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
		}	
	}

	public func autoEnums(for pix: PIXMergerEffect) -> [AutoEnumProperty] {
		switch self {
		case .blendpix:
			return [
				AutoEnumProperty(name: "blendMode", cases: [
						"over",
						"under",
						"add",
						"multiply",
						"difference",
						"subtractWithAlpha",
						"subtract",
						"maximum",
						"minimum",
						"gamma",
						"power",
						"divide",
						"average",
						"cosine",
						"insideSource",
						"insideDestination",
						"outsideSource",
						"outsideDestination",
						"xor",
				], getCallback: {
					return (pix as! BlendPIX).blendMode.rawValue
				}, setCallback: { value in
					(pix as! BlendPIX).blendMode = PIX.BlendingMode(rawValue: value) ?? .over
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
				AutoEnumProperty(name: "axis", cases: [
						"x",
						"y",
				], getCallback: {
					return (pix as! LookupPIX).axis.rawValue
				}, setCallback: { value in
					(pix as! LookupPIX).axis = LookupPIX.Axis(rawValue: value) ?? .x
				}),
			]
		case .lumablurpix:
			return [
				AutoEnumProperty(name: "style", cases: [
						"box",
						"angle",
						"zoom",
						"random",
				], getCallback: {
					return (pix as! LumaBlurPIX).style.rawValue
				}, setCallback: { value in
					(pix as! LumaBlurPIX).style = LumaBlurPIX.LumaBlurStyle(rawValue: value) ?? .box
				}),
			]
		case .remappix:
			return [
			]
		case .reorderpix:
			return [
				AutoEnumProperty(name: "redInput", cases: [
						"a",
						"b",
				], getCallback: {
					return (pix as! ReorderPIX).redInput.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).redInput = ReorderPIX.Input(rawValue: value) ?? .a
				}),
				AutoEnumProperty(name: "redChannel", cases: [
						"red",
						"green",
						"blue",
						"alpha",
						"zero",
						"one",
						"lum",
				], getCallback: {
					return (pix as! ReorderPIX).redChannel.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).redChannel = ReorderPIX.Channel(rawValue: value) ?? .red
				}),
				AutoEnumProperty(name: "greenInput", cases: [
						"a",
						"b",
				], getCallback: {
					return (pix as! ReorderPIX).greenInput.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).greenInput = ReorderPIX.Input(rawValue: value) ?? .a
				}),
				AutoEnumProperty(name: "greenChannel", cases: [
						"red",
						"green",
						"blue",
						"alpha",
						"zero",
						"one",
						"lum",
				], getCallback: {
					return (pix as! ReorderPIX).greenChannel.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).greenChannel = ReorderPIX.Channel(rawValue: value) ?? .red
				}),
				AutoEnumProperty(name: "blueInput", cases: [
						"a",
						"b",
				], getCallback: {
					return (pix as! ReorderPIX).blueInput.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).blueInput = ReorderPIX.Input(rawValue: value) ?? .a
				}),
				AutoEnumProperty(name: "blueChannel", cases: [
						"red",
						"green",
						"blue",
						"alpha",
						"zero",
						"one",
						"lum",
				], getCallback: {
					return (pix as! ReorderPIX).blueChannel.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).blueChannel = ReorderPIX.Channel(rawValue: value) ?? .red
				}),
				AutoEnumProperty(name: "alphaInput", cases: [
						"a",
						"b",
				], getCallback: {
					return (pix as! ReorderPIX).alphaInput.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).alphaInput = ReorderPIX.Input(rawValue: value) ?? .a
				}),
				AutoEnumProperty(name: "alphaChannel", cases: [
						"red",
						"green",
						"blue",
						"alpha",
						"zero",
						"one",
						"lum",
				], getCallback: {
					return (pix as! ReorderPIX).alphaChannel.rawValue
				}, setCallback: { value in
					(pix as! ReorderPIX).alphaChannel = ReorderPIX.Channel(rawValue: value) ?? .red
				}),
			]
		}	
	}

}


// MARK - PIXMultiEffect

public enum AutoPIXMultiEffect: String, Codable, CaseIterable {

	case arraypix
	case blendspix

	public var name: String {
		switch self {
		case .arraypix: return "ArrayPIX"
		case .blendspix: return "BlendsPIX"
		}
	}

	public var pixType: PIXMultiEffect.Type {
		switch self {
		case .arraypix: return ArrayPIX.self
		case .blendspix: return BlendsPIX.self
		}
	}

	public func autoLiveBools(for pix: PIXMultiEffect) -> [AutoLiveBoolProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLiveColors(for pix: PIXMultiEffect) -> [AutoLiveColorProperty] {
		switch self {
		case .arraypix:
			return [
				AutoLiveColorProperty(name: "bgColor", getCallback: {
					return (pix as! ArrayPIX).bgColor
				}, setCallback: { value in
					(pix as! ArrayPIX).bgColor = value
				}),
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLiveFloats(for pix: PIXMultiEffect) -> [AutoLiveFloatProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLiveInts(for pix: PIXMultiEffect) -> [AutoLiveIntProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLivePoints(for pix: PIXMultiEffect) -> [AutoLivePointProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLiveRects(for pix: PIXMultiEffect) -> [AutoLiveRectProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}
	public func autoLiveSizes(for pix: PIXMultiEffect) -> [AutoLiveSizeProperty] {
		switch self {
		case .arraypix:
			return [
			]
		case .blendspix:
			return [
			]
		}	
	}

	public func autoEnums(for pix: PIXMultiEffect) -> [AutoEnumProperty] {
		switch self {
		case .arraypix:
			return [
				AutoEnumProperty(name: "blendMode", cases: [
						"over",
						"under",
						"add",
						"multiply",
						"difference",
						"subtractWithAlpha",
						"subtract",
						"maximum",
						"minimum",
						"gamma",
						"power",
						"divide",
						"average",
						"cosine",
						"insideSource",
						"insideDestination",
						"outsideSource",
						"outsideDestination",
						"xor",
				], getCallback: {
					return (pix as! ArrayPIX).blendMode.rawValue
				}, setCallback: { value in
					(pix as! ArrayPIX).blendMode = PIX.BlendingMode(rawValue: value) ?? .over
				}),
			]
		case .blendspix:
			return [
				AutoEnumProperty(name: "blendMode", cases: [
						"over",
						"under",
						"add",
						"multiply",
						"difference",
						"subtractWithAlpha",
						"subtract",
						"maximum",
						"minimum",
						"gamma",
						"power",
						"divide",
						"average",
						"cosine",
						"insideSource",
						"insideDestination",
						"outsideSource",
						"outsideDestination",
						"xor",
				], getCallback: {
					return (pix as! BlendsPIX).blendMode.rawValue
				}, setCallback: { value in
					(pix as! BlendsPIX).blendMode = PIX.BlendingMode(rawValue: value) ?? .over
				}),
			]
		}	
	}

}


// MARK - PIXSingleEffect

public enum AutoPIXSingleEffect: String, Codable, CaseIterable {

	case blurpix
	case channelmixpix
	case chromakeypix
	case clamppix
	case cornerpinpix
	case croppix
	case edgepix
	case flarepix
	case flipfloppix
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

	public var name: String {
		switch self {
		case .blurpix: return "BlurPIX"
		case .channelmixpix: return "ChannelMixPIX"
		case .chromakeypix: return "ChromaKeyPIX"
		case .clamppix: return "ClampPIX"
		case .cornerpinpix: return "CornerPinPIX"
		case .croppix: return "CropPIX"
		case .edgepix: return "EdgePIX"
		case .flarepix: return "FlarePIX"
		case .flipfloppix: return "FlipFlopPIX"
		case .huesatpix: return "HueSatPIX"
		case .kaleidoscopepix: return "KaleidoscopePIX"
		case .levelspix: return "LevelsPIX"
		case .quantizepix: return "QuantizePIX"
		case .rangepix: return "RangePIX"
		case .sepiapix: return "SepiaPIX"
		case .sharpenpix: return "SharpenPIX"
		case .slopepix: return "SlopePIX"
		case .thresholdpix: return "ThresholdPIX"
		case .transformpix: return "TransformPIX"
		case .twirlpix: return "TwirlPIX"
		}
	}

	public var pixType: PIXSingleEffect.Type {
		switch self {
		case .blurpix: return BlurPIX.self
		case .channelmixpix: return ChannelMixPIX.self
		case .chromakeypix: return ChromaKeyPIX.self
		case .clamppix: return ClampPIX.self
		case .cornerpinpix: return CornerPinPIX.self
		case .croppix: return CropPIX.self
		case .edgepix: return EdgePIX.self
		case .flarepix: return FlarePIX.self
		case .flipfloppix: return FlipFlopPIX.self
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

	public func autoLiveBools(for pix: PIXSingleEffect) -> [AutoLiveBoolProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
				AutoLiveBoolProperty(name: "premultiply", getCallback: {
					return (pix as! ChromaKeyPIX).premultiply
				}, setCallback: { value in
					(pix as! ChromaKeyPIX).premultiply = value
				}),
			]
		case .clamppix:
			return [
				AutoLiveBoolProperty(name: "clampAlpha", getCallback: {
					return (pix as! ClampPIX).clampAlpha
				}, setCallback: { value in
					(pix as! ClampPIX).clampAlpha = value
				}),
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
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
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoLiveBoolProperty(name: "mirror", getCallback: {
					return (pix as! KaleidoscopePIX).mirror
				}, setCallback: { value in
					(pix as! KaleidoscopePIX).mirror = value
				}),
			]
		case .levelspix:
			return [
				AutoLiveBoolProperty(name: "inverted", getCallback: {
					return (pix as! LevelsPIX).inverted
				}, setCallback: { value in
					(pix as! LevelsPIX).inverted = value
				}),
			]
		case .quantizepix:
			return [
			]
		case .rangepix:
			return [
				AutoLiveBoolProperty(name: "ignoreAlpha", getCallback: {
					return (pix as! RangePIX).ignoreAlpha
				}, setCallback: { value in
					(pix as! RangePIX).ignoreAlpha = value
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
				AutoLiveBoolProperty(name: "smooth", getCallback: {
					return (pix as! ThresholdPIX).smooth
				}, setCallback: { value in
					(pix as! ThresholdPIX).smooth = value
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
	public func autoLiveColors(for pix: PIXSingleEffect) -> [AutoLiveColorProperty] {
		switch self {
		case .blurpix:
			return [
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
				AutoLiveColorProperty(name: "keyColor", getCallback: {
					return (pix as! ChromaKeyPIX).keyColor
				}, setCallback: { value in
					(pix as! ChromaKeyPIX).keyColor = value
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
				AutoLiveColorProperty(name: "color", getCallback: {
					return (pix as! FlarePIX).color
				}, setCallback: { value in
					(pix as! FlarePIX).color = value
				}),
			]
		case .flipfloppix:
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
				AutoLiveColorProperty(name: "inLowColor", getCallback: {
					return (pix as! RangePIX).inLowColor
				}, setCallback: { value in
					(pix as! RangePIX).inLowColor = value
				}),
				AutoLiveColorProperty(name: "inHighColor", getCallback: {
					return (pix as! RangePIX).inHighColor
				}, setCallback: { value in
					(pix as! RangePIX).inHighColor = value
				}),
				AutoLiveColorProperty(name: "outLowColor", getCallback: {
					return (pix as! RangePIX).outLowColor
				}, setCallback: { value in
					(pix as! RangePIX).outLowColor = value
				}),
				AutoLiveColorProperty(name: "outHighColor", getCallback: {
					return (pix as! RangePIX).outHighColor
				}, setCallback: { value in
					(pix as! RangePIX).outHighColor = value
				}),
			]
		case .sepiapix:
			return [
				AutoLiveColorProperty(name: "color", getCallback: {
					return (pix as! SepiaPIX).color
				}, setCallback: { value in
					(pix as! SepiaPIX).color = value
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
	public func autoLiveFloats(for pix: PIXSingleEffect) -> [AutoLiveFloatProperty] {
		switch self {
		case .blurpix:
			return [
				AutoLiveFloatProperty(name: "radius", getCallback: {
					return (pix as! BlurPIX).radius
				}, setCallback: { value in
					(pix as! BlurPIX).radius = value
				}),
				AutoLiveFloatProperty(name: "angle", getCallback: {
					return (pix as! BlurPIX).angle
				}, setCallback: { value in
					(pix as! BlurPIX).angle = value
				}),
			]
		case .channelmixpix:
			return [
			]
		case .chromakeypix:
			return [
				AutoLiveFloatProperty(name: "range", getCallback: {
					return (pix as! ChromaKeyPIX).range
				}, setCallback: { value in
					(pix as! ChromaKeyPIX).range = value
				}),
				AutoLiveFloatProperty(name: "softness", getCallback: {
					return (pix as! ChromaKeyPIX).softness
				}, setCallback: { value in
					(pix as! ChromaKeyPIX).softness = value
				}),
				AutoLiveFloatProperty(name: "edgeDesaturation", getCallback: {
					return (pix as! ChromaKeyPIX).edgeDesaturation
				}, setCallback: { value in
					(pix as! ChromaKeyPIX).edgeDesaturation = value
				}),
			]
		case .clamppix:
			return [
				AutoLiveFloatProperty(name: "low", getCallback: {
					return (pix as! ClampPIX).low
				}, setCallback: { value in
					(pix as! ClampPIX).low = value
				}),
				AutoLiveFloatProperty(name: "high", getCallback: {
					return (pix as! ClampPIX).high
				}, setCallback: { value in
					(pix as! ClampPIX).high = value
				}),
			]
		case .cornerpinpix:
			return [
			]
		case .croppix:
			return [
			]
		case .edgepix:
			return [
				AutoLiveFloatProperty(name: "strength", getCallback: {
					return (pix as! EdgePIX).strength
				}, setCallback: { value in
					(pix as! EdgePIX).strength = value
				}),
				AutoLiveFloatProperty(name: "distance", getCallback: {
					return (pix as! EdgePIX).distance
				}, setCallback: { value in
					(pix as! EdgePIX).distance = value
				}),
			]
		case .flarepix:
			return [
				AutoLiveFloatProperty(name: "scale", getCallback: {
					return (pix as! FlarePIX).scale
				}, setCallback: { value in
					(pix as! FlarePIX).scale = value
				}),
				AutoLiveFloatProperty(name: "angle", getCallback: {
					return (pix as! FlarePIX).angle
				}, setCallback: { value in
					(pix as! FlarePIX).angle = value
				}),
				AutoLiveFloatProperty(name: "threshold", getCallback: {
					return (pix as! FlarePIX).threshold
				}, setCallback: { value in
					(pix as! FlarePIX).threshold = value
				}),
				AutoLiveFloatProperty(name: "brightness", getCallback: {
					return (pix as! FlarePIX).brightness
				}, setCallback: { value in
					(pix as! FlarePIX).brightness = value
				}),
				AutoLiveFloatProperty(name: "gamma", getCallback: {
					return (pix as! FlarePIX).gamma
				}, setCallback: { value in
					(pix as! FlarePIX).gamma = value
				}),
			]
		case .flipfloppix:
			return [
			]
		case .huesatpix:
			return [
				AutoLiveFloatProperty(name: "hue", getCallback: {
					return (pix as! HueSatPIX).hue
				}, setCallback: { value in
					(pix as! HueSatPIX).hue = value
				}),
				AutoLiveFloatProperty(name: "sat", getCallback: {
					return (pix as! HueSatPIX).sat
				}, setCallback: { value in
					(pix as! HueSatPIX).sat = value
				}),
			]
		case .kaleidoscopepix:
			return [
				AutoLiveFloatProperty(name: "rotation", getCallback: {
					return (pix as! KaleidoscopePIX).rotation
				}, setCallback: { value in
					(pix as! KaleidoscopePIX).rotation = value
				}),
			]
		case .levelspix:
			return [
				AutoLiveFloatProperty(name: "brightness", getCallback: {
					return (pix as! LevelsPIX).brightness
				}, setCallback: { value in
					(pix as! LevelsPIX).brightness = value
				}),
				AutoLiveFloatProperty(name: "darkness", getCallback: {
					return (pix as! LevelsPIX).darkness
				}, setCallback: { value in
					(pix as! LevelsPIX).darkness = value
				}),
				AutoLiveFloatProperty(name: "contrast", getCallback: {
					return (pix as! LevelsPIX).contrast
				}, setCallback: { value in
					(pix as! LevelsPIX).contrast = value
				}),
				AutoLiveFloatProperty(name: "gamma", getCallback: {
					return (pix as! LevelsPIX).gamma
				}, setCallback: { value in
					(pix as! LevelsPIX).gamma = value
				}),
				AutoLiveFloatProperty(name: "opacity", getCallback: {
					return (pix as! LevelsPIX).opacity
				}, setCallback: { value in
					(pix as! LevelsPIX).opacity = value
				}),
			]
		case .quantizepix:
			return [
				AutoLiveFloatProperty(name: "fraction", getCallback: {
					return (pix as! QuantizePIX).fraction
				}, setCallback: { value in
					(pix as! QuantizePIX).fraction = value
				}),
			]
		case .rangepix:
			return [
				AutoLiveFloatProperty(name: "inLow", getCallback: {
					return (pix as! RangePIX).inLow
				}, setCallback: { value in
					(pix as! RangePIX).inLow = value
				}),
				AutoLiveFloatProperty(name: "inHigh", getCallback: {
					return (pix as! RangePIX).inHigh
				}, setCallback: { value in
					(pix as! RangePIX).inHigh = value
				}),
				AutoLiveFloatProperty(name: "outLow", getCallback: {
					return (pix as! RangePIX).outLow
				}, setCallback: { value in
					(pix as! RangePIX).outLow = value
				}),
				AutoLiveFloatProperty(name: "outHigh", getCallback: {
					return (pix as! RangePIX).outHigh
				}, setCallback: { value in
					(pix as! RangePIX).outHigh = value
				}),
			]
		case .sepiapix:
			return [
			]
		case .sharpenpix:
			return [
				AutoLiveFloatProperty(name: "contrast", getCallback: {
					return (pix as! SharpenPIX).contrast
				}, setCallback: { value in
					(pix as! SharpenPIX).contrast = value
				}),
			]
		case .slopepix:
			return [
				AutoLiveFloatProperty(name: "amplitude", getCallback: {
					return (pix as! SlopePIX).amplitude
				}, setCallback: { value in
					(pix as! SlopePIX).amplitude = value
				}),
			]
		case .thresholdpix:
			return [
				AutoLiveFloatProperty(name: "threshold", getCallback: {
					return (pix as! ThresholdPIX).threshold
				}, setCallback: { value in
					(pix as! ThresholdPIX).threshold = value
				}),
			]
		case .transformpix:
			return [
				AutoLiveFloatProperty(name: "rotation", getCallback: {
					return (pix as! TransformPIX).rotation
				}, setCallback: { value in
					(pix as! TransformPIX).rotation = value
				}),
				AutoLiveFloatProperty(name: "scale", getCallback: {
					return (pix as! TransformPIX).scale
				}, setCallback: { value in
					(pix as! TransformPIX).scale = value
				}),
			]
		case .twirlpix:
			return [
				AutoLiveFloatProperty(name: "strength", getCallback: {
					return (pix as! TwirlPIX).strength
				}, setCallback: { value in
					(pix as! TwirlPIX).strength = value
				}),
			]
		}	
	}
	public func autoLiveInts(for pix: PIXSingleEffect) -> [AutoLiveIntProperty] {
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
				AutoLiveIntProperty(name: "count", getCallback: {
					return (pix as! FlarePIX).count
				}, setCallback: { value in
					(pix as! FlarePIX).count = value
				}),
				AutoLiveIntProperty(name: "rayRes", getCallback: {
					return (pix as! FlarePIX).rayRes
				}, setCallback: { value in
					(pix as! FlarePIX).rayRes = value
				}),
			]
		case .flipfloppix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoLiveIntProperty(name: "divisions", getCallback: {
					return (pix as! KaleidoscopePIX).divisions
				}, setCallback: { value in
					(pix as! KaleidoscopePIX).divisions = value
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
	public func autoLivePoints(for pix: PIXSingleEffect) -> [AutoLivePointProperty] {
		switch self {
		case .blurpix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! BlurPIX).position
				}, setCallback: { value in
					(pix as! BlurPIX).position = value
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
			]
		case .huesatpix:
			return [
			]
		case .kaleidoscopepix:
			return [
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! KaleidoscopePIX).position
				}, setCallback: { value in
					(pix as! KaleidoscopePIX).position = value
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
				AutoLivePointProperty(name: "position", getCallback: {
					return (pix as! TransformPIX).position
				}, setCallback: { value in
					(pix as! TransformPIX).position = value
				}),
			]
		case .twirlpix:
			return [
			]
		}	
	}
	public func autoLiveRects(for pix: PIXSingleEffect) -> [AutoLiveRectProperty] {
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
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
	public func autoLiveSizes(for pix: PIXSingleEffect) -> [AutoLiveSizeProperty] {
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
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
				AutoLiveSizeProperty(name: "size", getCallback: {
					return (pix as! TransformPIX).size
				}, setCallback: { value in
					(pix as! TransformPIX).size = value
				}),
			]
		case .twirlpix:
			return [
			]
		}	
	}

	public func autoEnums(for pix: PIXSingleEffect) -> [AutoEnumProperty] {
		switch self {
		case .blurpix:
			return [
				AutoEnumProperty(name: "style", cases: [
						"guassian",
						"box",
						"angle",
						"zoom",
						"random",
				], getCallback: {
					return (pix as! BlurPIX).style.rawValue
				}, setCallback: { value in
					(pix as! BlurPIX).style = BlurPIX.BlurStyle(rawValue: value) ?? .guassian
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
		case .edgepix:
			return [
			]
		case .flarepix:
			return [
			]
		case .flipfloppix:
			return [
				AutoEnumProperty(name: "flip", cases: [
						"none",
						"x",
						"y",
						"xy",
				], getCallback: {
					return (pix as! FlipFlopPIX).flip.rawValue
				}, setCallback: { value in
					(pix as! FlipFlopPIX).flip = FlipFlopPIX.Flip(rawValue: value) ?? .none
				}),
				AutoEnumProperty(name: "flop", cases: [
						"none",
						"left",
						"right",
				], getCallback: {
					return (pix as! FlipFlopPIX).flop.rawValue
				}, setCallback: { value in
					(pix as! FlipFlopPIX).flop = FlipFlopPIX.Flop(rawValue: value) ?? .none
				}),
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

