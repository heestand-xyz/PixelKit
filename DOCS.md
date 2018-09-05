# Docs for [Pixels](https://github.com/anton-hexagons/Pixels)


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
var <b>colorBits</b>: PIX.Color.Bits = ._8<br>
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
var <b>fillMode</b>: FillMode = .aspectFit
### LevelsPIX
var <b>brightness</b>: CGFloat = 1.0<br>
var <b>darkness</b>: CGFloat = 0.0<br>
var <b>contrast</b>: CGFloat = 0.0<br>
var <b>gamma</b>: CGFloat = 1.0<br>
var <b>inverted</b>: Bool = false<br>
var <b>opacity</b>: CGFloat = 1.0
### BlurPIX
var <b>style</b>: Style = .guassian<br>
var <b>radius</b>: CGFloat = 0.5<br>
var <b>quality</b>: SampleQualityMode = .mid<br>
var <b>angle</b>: CGFloat = 0.0<br>
var <b>position</b>: CGPoint = .zero
### EdgePIX
var <b>strength</b>: CGFloat = 4.0<br>
var <b>distance</b>: CGFloat = 1.0
### ThresholdPIX
var <b>threshold</b>: CGFloat = 0.5<br>
var <b>smoothness</b>: CGFloat = 0
### QuantizePIX
var <b>fraction</b>: CGFloat = 0.125
### TranformPIX
var <b>position</b>: CGPoint = .zero<br>
var <b>rotation</b>: CGFloat = 0.0<br>
var <b>scale</b>: CGFloat = 1.0<br>
var <b>size</b>: CGSize = CGSize(width: 1.0, height: 1.0)
### KaleidoscopePIX
var <b>divisions</b>: Int = 12<br>
var <b>mirror</b>: Bool = true<br>
var <b>rotation</b>: CGFloat = 0<br>
var <b>position</b>: CGPoint = .zero
### TwirlPIX
var <b>strength</b>: CGFloat = 1
### FeedbackPIX
var <b>feedActive</b>: Bool = true<br>
var <b>feedPix</b>: (PIX & PIXOut)?
### ChannelMixPIX
var <b>red</b>: Color = Color(pure: .red)<br>
var <b>green</b>: Color = Color(pure: .green)<br>
var <b>blue</b>: Color = Color(pure: .blue)<br>
var <b>alpha</b>: Color = Color(pure: .alpha)
### ChromaKeyPIX
var <b>keyColor</b>: UIColor = .green<br>
var <b>range</b>: CGFloat = 0.1<br>
var <b>softness</b>: CGFloat = 0.1<br>
var <b>edgeDesaturation</b>: CGFloat = 0.5
### CornerPinPIX
var <b>corners</b>: Corners<br>
var <b>perspective</b>: Bool = false<br>
var <b>divisions</b>: Int = 16
### HueSaturationPIX
var <b>hue</b>: CGFloat = 0.0<br>
var <b>saturation</b>: CGFloat = 1.0
### CropPIX
var <b>cropFrame</b>: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
### SlopePIX <i>(coming soon)</i>
### SharpenPIX <i>(coming soon)</i>
### FlipFlopPIX <i>(coming soon)</i>
### DelayPIX <i>(coming soon)</i>
### RangePIX <i>(coming soon)</i>

## PIXMergerEffect</b>: PIXEffect
var <b>inPixA</b>: (PIX & PIXOut)?<br>
var <b>inPixB</b>: (PIX & PIXOut)?<br>
var <b>fillMode</b>: FillMode = .aspectFit

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
var <b>holdEdge</b>: Bool = true
### LumaBlurPIX
var <b>style</b>: Style = .box<br>
var <b>radius</b>: CGFloat = 0.5<br>
var <b>quality</b>: SampleQualityMode = .mid<br>
var <b>angle</b>: CGFloat = 0<br>
var <b>position</b>: CGPoint = .zero
### DispacePIX <i>(coming soon)</i>
### ReorderPIX <i>(coming soon)</i>
### RemapPIX <i>(coming soon)</i>
### TimeMachinePIX <i>(coming soon)</i>

## PIXMultiEffect</b>: PIXEffect
var <b>inPixs</b>: [PIX & PIXOut] = []

### BlendsPIX
var <b>blendingMode</b>: BlendingMode = .add
