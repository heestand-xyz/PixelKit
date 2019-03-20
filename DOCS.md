# Docs

[README.md](https://github.com/hexagons/pixels/blob/master/README.md)

## Pixels
static let <b>main</b>: Pixels<br>
weak var <b>delegate</b>: PixelsDelegate?<br>
var <b>fps</b>: Int { get }<br>
var <b>fpsMax</b>: Int { get }<br>
var <b>frame</b>: Int { get }<br>
var <b>seconds</b>: CGFloat { get }<br>
var <b>logLevel</b>: LogLevel = .debug<br>
var <b>logLoopLimitActive</b> = true<br>
var <b>logLoopLimitFrameCount</b> = 10<br>
var <b>bits</b>: PIX.Color.Bits = ._8<br>
var <b>colorSpace</b>: PIX.Color.Space = .sRGB

## PixelsDelegate
func <b>pixelsFrameLoop()</b>


## PIX
var <b>id</b> = UUID()<br>
var <b>name</b>: String?<br>
weak var  <b>delegate</b>: PIXDelegate?<br>
let  <b>view</b>: PIXView<br>
var  <b>interpolate</b>: InterpolateMode = .linear<br>
var  <b>extend</b>: ExtendMode = .zero<br>
var  <b>renderedTexture</b>: MTLTexture? { get }<br>
var  <b>renderedImage</b>: UIImage? { get }<br>
var  <b>renderedPixels</b>: PixelPack? { get }

## PIXDelegate
func <b>pixWillRender(_ pix: PIX)</b><br>
func <b>pixDidRender(_ pix: PIX)</b>

## PIXContent: PIX, PIXOut

## PIXResource: PIXContent

### CameraPIX
var <b>camera</b>: Camera = .back
### ImagePIX
var <b>image</b>: UIImage?
### VideoPIX
var <b>url</b>: URL?<br>
var <b>volume</b>: CGFloat = 1<br>
func <b>load(fileNamed: String, withExtension: String)</b><br>
func <b>play()</b><br>
func <b>pause()</b><br>
func <b>seek(toTime: CMTime)</b><br>
func <b>seek(toFraction: CGFloat)</b><br>
func <b>restart()</b><br>
func <b>reset()</b>
### ScreenCapturePIX
var <b>screenIndex</b>: Int = 0
### VectorPIX <i>(coming soon)</i>
### TextPIX <i>(coming soon)</i>
### PaintPIX <i>(coming soon)</i>

## PIXGenerator: PIXContent
var <b>res</b>: Res<br>
static var <b>globalResMultiplier</b>: CGFloat = 1<br>
var <b>premultiply</b>: Bool = true

### ColorPIX
var <b>color</b>: UIColor = .white
### CirclePIX
var <b>radius</b>: CGFloat<br>
var <b>position</b>: CGPoint = .zero<br>
var <b>edgeRadius</b>: CGFloat = 0.0<br>
var <b>color</b>: UIColor = .white<br>
var <b>edgeColor</b>: UIColor = .gray<br>
var <b>bgColor</b>: UIColor = .black
### RectanglePIX
var <b>size</b>: CGSize<br>
var <b>position</b>: CGPoint = .zero<br>
var <b>color</b>: UIColor = .white<br>
var <b>bgColor</b>: UIColor = .black
### PolygonPIX
var <b>radius</b>: CGFloat = 0.25<br>
var <b>position</b>: CGPoint = .zero<br>
var <b>rotation</b>: CGFloat = 0.0<br>
var <b>vertexCount</b>: Int = 6<br>
var <b>color</b>: UIColor = .white<br>
var <b>bgColor</b>: UIColor = .black
### GradientPIX
var <b>style</b>: Style = .horizontal<br>
var <b>scale</b>: CGFloat = 1.0<br>
var <b>offset</b>: CGFloat = 0.0<br>
var <b>colorFirst</b>: UIColor = .black<br>
var <b>colorLast</b>: UIColor = .white<br>
var <b>extendGradient</b>: ExtendMode = .repeat
### NoisePIX
var <b>seed</b>: Int = 0<br>
var <b>octaves</b>: Int = 7<br>
var <b>position</b>: CGPoint = .zero<br>
var <b>zPosition</b>: CGFloat = 0.0<br>
var <b>zoom</b>: CGFloat = 1.0<br>
var <b>colored</b>: Bool = false<br>
var <b>random</b>: Bool = false
### MetalPIX
var <b>metalUniforms</b>: [MetalUniform] = []

## PIXSprite: PIXContent
var <b>res</b>: Res<br>
var <b>bgColor</b>: UIColor

### TextPIX
var <b>text</b>: String = "Pixels"<br>
var <b>textColor</b>: UIColor = .white<br>
var <b>font</b>: UIFont = UIFont.systemFont(ofSize: 100)<br>
var <b>position</b>: CGPoint = .zero

## PIXEffect</b>: PIX, PIXIn, PIXOut

## PIXSingleEffect</b>: PIXEffect
var <b>inPix</b>: (PIX & PIXOut)?

### NilPIX
### ResPIX
var <b>res</b>: Res<br>
var <b>resMultiplier</b>: CGFloat = 1.0<br>
var <b>inheritInRes</b>: Bool = false<br>
var <b>placement</b>: Placement = .aspectFit<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>reRes(to: PIX.Res)</b> -> ResPIX<br>
func <b>reRes(by: CGFloat)</b> -> ResPIX
### LevelsPIX
var <b>brightness</b>: CGFloat = 1.0<br>
var <b>darkness</b>: CGFloat = 0.0<br>
var <b>contrast</b>: CGFloat = 0.0<br>
var <b>gamma</b>: CGFloat = 1.0<br>
var <b>inverted</b>: Bool = false<br>
var <b>opacity</b>: CGFloat = 1.0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>brightness(\_: CGFloat)</b> -> LevelsPIX<br>
func <b>darkness(\_: CGFloat)</b> -> LevelsPIX<br>
func <b>contrast(\_: CGFloat)</b> -> LevelsPIX<br>
func <b>gamma(\_: CGFloat)</b> -> LevelsPIX<br>
func <b>invert()</b> -> LevelsPIX<br>
func <b>opacity(\_: CGFloat)</b> -> LevelsPIX
### BlurPIX
var <b>style</b>: Style = .guassian<br>
var <b>radius</b>: CGFloat = 0.5<br>
var <b>quality</b>: SampleQualityMode = .mid<br>
var <b>angle</b>: CGFloat = 0.0<br>
var <b>position</b>: CGPoint = .zero<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>blur(\_: CGFloat)</b> -> BlurPIX
### EdgePIX
var <b>strength</b>: CGFloat = 4.0<br>
var <b>distance</b>: CGFloat = 1.0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>edge()</b> -> EdgePIX
### ThresholdPIX
var <b>threshold</b>: CGFloat = 0.5<br>
var <b>smoothness</b>: CGFloat = 0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>threshold(at: CGFloat)</b> -> ThresholdPIX
### QuantizePIX
var <b>fraction</b>: CGFloat = 0.125<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>quantize(by: CGFloat)</b> -> QuantizePIX
### TransformPIX
var <b>position</b>: CGPoint = .zero<br>
var <b>rotation</b>: CGFloat = 0.0<br>
var <b>scale</b>: CGFloat = 1.0<br>
var <b>size</b>: CGSize = CGSize(width: 1.0, height: 1.0)<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>position(at: CGPoint)</b> -> TransformPIX<br>
func <b>rotatate(to: CGFloat)</b> -> TransformPIX<br>
func <b>scale(by: CGFloat)</b> -> TransformPIX
### KaleidoscopePIX
var <b>divisions</b>: Int = 12<br>
var <b>mirror</b>: Bool = true<br>
var <b>rotation</b>: CGFloat = 0<br>
var <b>position</b>: CGPoint = .zero<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>kaleidoscope(divisions: Int = 12, mirror: Bool = true)</b> -> KaleidoscopePIX
### TwirlPIX
var <b>strength</b>: CGFloat = 1<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>twirl(\_: CGFloat)</b> -> TwirlPIX
### FeedbackPIX
var <b>feedActive</b>: Bool = true<br>
var <b>feedPix</b>: (PIX & PIXOut)?
### ChannelMixPIX
var <b>red</b>: PIX.Color = PIX.Color(pure: .red)<br>
var <b>green</b>: PIX.Color = PIX.Color(pure: .green)<br>
var <b>blue</b>: PIX.Color = PIX.Color(pure: .blue)<br>
var <b>alpha</b>: PIX.Color = PIX.Color(pure: .alpha)<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>swap(\_: PIX.Color.Pure, \_: PIX.Color.Pure)</b> -> ChannelMixPIX
### ChromaKeyPIX
var <b>keyColor</b>: UIColor = .green<br>
var <b>range</b>: CGFloat = 0.1<br>
var <b>softness</b>: CGFloat = 0.1<br>
var <b>edgeDesaturation</b>: CGFloat = 0.5<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>chromaKey(\_: UIColor)</b> -> ChromaKeyPIX
### CornerPinPIX
var <b>corners</b>: Corners<br>
var <b>perspective</b>: Bool = false<br>
var <b>divisions</b>: Int = 16
### HueSatPIX
var <b>hue</b>: CGFloat = 0.0<br>
var <b>saturation</b>: CGFloat = 1.0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>hue(\_: CGFloat)</b> -> HueSatPIX<br>
func <b>saturation(\_: CGFloat)</b> -> HueSatPIX
### CropPIX
var <b>cropFrame</b>: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>crop(\_: CGRect)</b> -> CropPIX
### FlipFlopPIX
var <b>flip</b>: Flip? = nil<br>
var <b>flop</b>: Flop? = nil<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>flipX()</b> -> FlipFlopPIX<br>
func <b>flipY()</b> -> FlipFlopPIX<br>
func <b>flopLeft()</b> -> FlipFlopPIX<br>
func <b>flopRight()</b> -> FlipFlopPIX
### RangePIX
var <b>inLow</b>: CGFloat = 0.0<br>
var <b>inHigh</b>: CGFloat = 1.0<br>
var <b>outLow</b>: CGFloat = 0.0<br>
var <b>outHigh</b>: CGFloat = 1.0<br>
var <b>inLowColor</b>: UIColor = .clear<br>
var <b>inHighColor</b>: UIColor = .white<br>
var <b>outLowColor</b>: UIColor = .clear<br>
var <b>outHighColor</b>: UIColor = .white<br>
var <b>ignoreAlpha</b>: Bool = true<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>range(inLow: CGFloat = 0.0, inHigh: CGFloat = 1.0, outLow: CGFloat = 0.0, outHigh: CGFloat = 1.0)</b> -> RangePIX<br>
func <b>range(inLow: UIColor = .clear, inHigh: UIColor = .white, outLow: UIColor = .clear, outHigh: UIColor = .white)</b> -> RangePIX
### SharpenPIX
var <b>contrast</b>: CGFloat = 1.0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>sharpen(\_: CGFloat = 1.0)</b> -> SharpenPIX
### SlopePIX
var <b>amplitude</b>: CGFloat = 1.0<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>slope(\_: CGFloat = 1.0)</b> - > SlopePIX
### DelayPIX <i>(coming soon)</i>
### MetalEffectPIX
var <b>metalUniforms</b>: [MetalUniform] = []

## PIXMergerEffect</b>: PIXEffect
var <b>inPixA</b>: (PIX & PIXOut)?<br>
var <b>inPixB</b>: (PIX & PIXOut)?<br>
var <b>placement</b>: Placement = .aspectFit

### CrossPIX
var <b>lerp</b>: CGFloat = 0.5
### BlendPIX
var <b>blendingMode</b>: BlendingMode = .add<br>
var <b>bypassTransform</b>: Bool = false<br>
var <b>position</b>: CGPoint = .zero<br>
var <b>rotation</b>: CGFloat = 0.0<br>
var <b>scale</b>: CGFloat = 1.0<br>
var <b>size</b>: CGSize
### LookupPIX
var <b>axis</b>: Axis = .x<br>
var <b>holdEdge</b>: Bool = true<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>lookup(pix: PIX, axis: Axis)</b> -> LookupPIX
### LumaBlurPIX
var <b>style</b>: Style = .box<br>
var <b>radius</b>: CGFloat = 0.5<br>
var <b>quality</b>: SampleQualityMode = .mid<br>
var <b>angle</b>: CGFloat = 0<br>
var <b>position</b>: CGPoint = .zero<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>lumaBlur(pix: PIX, radius: CGFloat)</b> -> LumaBlurPIX
### DisplacePIX
var <b>distance</b>: CGFloat = 1.0<br>
var <b>origin</b>: CGPoint = CGPoint(x: 0.5, y: 0.5)<br>
<br>
<b>PIXOut</b> convenience funcs:<br>
func <b>displace(pix: PIX, distance: CGFloat)</b> -> DisplacePIX
### RemapPIX
<b>PIXOut</b> convenience funcs:<br>
func <b>remap(pix: PIX)</b> -> RemapPIX
### ReorderPIX
var <b>redInput</b>: Input = .a<br>
var <b>redChannel</b>: Channel = .red<br>
var <b>greenInput</b>: Input = .a<br>
var <b>greenChannel</b>: Channel = .green<br>
var <b>blueInput</b>: Input = .a<br>
var <b>blueChannel</b>: Channel = .blue<br>
var <b>alphaInput</b>: Input = .a<br>
var <b>alphaChannel</b>: Channel = .alpha<br>
var <b>premultiply</b>: Bool = true
### TimeMachinePIX <i>(coming soon)</i>
### MetalMergerEffectPIX
var <b>metalUniforms</b>: [MetalUniform] = []


## PIXMultiEffect</b>: PIXEffect
var <b>inPixs</b>: [PIX & PIXOut] = []

### BlendsPIX
var <b>blendingMode</b>: BlendingMode = .add
### MetalMultiEffectPIX
var <b>metalUniforms</b>: [MetalUniform] = []

