<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Logo/pixels_logo_1k_bg.png" width="128"/>

# PixelKit

[![License](https://img.shields.io/cocoapods/l/PixelKit.svg)](https://github.com/hexagons/PixelKit/blob/master/LICENSE)
[![Cocoapods](https://img.shields.io/cocoapods/v/PixelKit.svg)](http://cocoapods.org/pods/PixelKit)
[![Platform](https://img.shields.io/cocoapods/p/PixelKit.svg)](http://cocoapods.org/pods/PixelKit)
<img src="https://img.shields.io/badge/in-swift5.0-orange.svg">

a Live Graphics Framework for iOS and macOS<br>
powered by Metal - inspired by TouchDesigner

<b>Content:</b>
[Camera](http://pixelkit.net/docs/Classes/CameraPIX.html) -
[Image](http://pixelkit.net/docs/Classes/ImagePIX.html) -
[Video](http://pixelkit.net/docs/Classes/VideoPIX.html) -
[Screen Capture](http://pixelkit.net/docs/Classes/ScreenCapturePIX.html)-
[Color](http://pixelkit.net/docs/Classes/ColorPIX.html) -
[Circle](http://pixelkit.net/docs/Classes/CirclePIX.html) -
[Rectangle](http://pixelkit.net/docs/Classes/RectanglePIX.html) -
[Polygon](http://pixelkit.net/docs/Classes/PolygonPIX.html) -
[Gradient](http://pixelkit.net/docs/Classes/GradientPIX.html) -
[Noise](http://pixelkit.net/docs/Classes/NoisePIX.html) - 
[Text](http://pixelkit.net/docs/Classes/TextPIX.html)
<br>
<b>Effects:</b>
[Levels](http://pixelkit.net/docs/Classes/LevelsPIX.html) -
[Blur](http://pixelkit.net/docs/Classes/BlurPIX.html) -
[Edge](http://pixelkit.net/docs/Classes/EdgePIX.html) -
[Threshold](http://pixelkit.net/docs/Classes/ThresholdPIX.html) -
[Quantize](http://pixelkit.net/docs/Classes/QuantizePIX.html) -
[Transform](http://pixelkit.net/docs/Classes/TransformPIX.html) -
[Kaleidoscope](http://pixelkit.net/docs/Classes/KaleidoscopePIX.html) -
[Twirl](http://pixelkit.net/docs/Classes/TwirlPIX.html) -
[Feedback](http://pixelkit.net/docs/Classes/FeedbackPIX.html) -
[Channel Mix](http://pixelkit.net/docs/Classes/ChannelMixPIX.html) -
[Chroma Key](http://pixelkit.net/docs/Classes/ChromaKeyPIX.html) -
[Corner Pin](http://pixelkit.net/docs/Classes/CornerPinPIX.html) -
[HueSat](http://pixelkit.net/docs/Classes/HueSatPIX.html) -
[Crop](http://pixelkit.net/docs/Classes/CropPIX.html) -
[Flip Flop](http://pixelkit.net/docs/Classes/FlipFlopPIX.html) -
[Range](http://pixelkit.net/docs/Classes/RangePIX.html) -
[Sharpen](http://pixelkit.net/docs/Classes/SharpenPIX.html) -
[Slope](http://pixelkit.net/docs/Classes/SlopePIX.html) -
[Cross](http://pixelkit.net/docs/Classes/CrossPIX.html) -
[Blend](http://pixelkit.net/docs/Classes/BlendPIX.html) -
[Lookup](http://pixelkit.net/docs/Classes/LookupPIX.html) -
[Displace](http://pixelkit.net/docs/Classes/DisplacePIX.html) -
[Remap](http://pixelkit.net/docs/Classes/RemapPIX.html) -
[Reorder](http://pixelkit.net/docs/Classes/ReorderPIX.html) -
[Blends](http://pixelkit.net/docs/Classes/BlendsPIX.html)

Examples:
[Camera Effects](#example-camera-effects) -
[Green Screen](#example-green-screen) - 
[Hello Pixels App](https://github.com/hexagons/Hello-Pixels) - 
[Code Examples](http://pixelkit.net/examples/)
<br>
Info:
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
[Effect Convenience Funcs](#effect-convenience-funcs) -
[File IO](#file-io) -
[High Bit Mode](#high-bit-mode) -
[Apps](#apps)

--- 

## Install

`pod 'PixelKit'`

`import PixelKit`

Note that PixelKit dose not have simulator support. Metal for iOS can only run on a physical device.

To gain camera access, on macOS, check Camera in the App Sandbox in your Xcode project settings under Capabilities.

## Docs

[Jazzy Docs](http://pixelkit.net/docs/)

## Tutorials

[Getting started with PixelKit in Swift](http://blog.hexagons.se/uncategorized/getting-started-with-pixels/)<br>
[Getting started with Metal in PixelKit](http://blog.hexagons.se/uncategorized/getting-started-with-metal-in-pixels/)<br>
[Green Screen in Swift & PixelKit](http://blog.hexagons.se/blog/green-screen-in-swift-pixelkit/)<br>
[Particles in VertexKit & PixelKit](http://blog.hexagons.se/blog/particles-in-vertexkit-pixelkit/)

## Examples

[Hello Pixels](https://github.com/hexagons/Hello-Pixels) App (iOS & macOS)<br>
[Code Examples of all PIXs](http://pixelkit.net/examples/)


### Example: Camera Effects

`import PixelKit`

~~~~swift
let camera = CameraPIX()

let levels = LevelsPIX()
levels.inPix = camera
levels.brightness = 1.5
levels.gamma = 0.5

let hueSat = HueSatPIX()
hueSat.inPix = levels
hueSat.sat = 0.5

let blur = BlurPIX()
blur.inPix = hueSat
blur.radius = 0.25

let res: PIX.Res = .custom(w: 1500, h: 1000)
let circle = CirclePIX(res: res)
circle.radius = 0.45
circle.bgColor = .clear

let finalPix: PIX = blur & (camera * circle)
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This can also be done with [Effect Convenience Funcs](#effect-convenience-funcs):<br>
```swift
let pix = CameraPIX()._brightness(1.5)._gamma(0.5)._saturation(0.5)._blur(0.25)
```

| <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_01.jpg" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_02.jpg" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_03.jpg" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_04.jpg" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_05.jpg" width="150" height="100"/> |
| --- | --- | --- | --- | --- |

Remeber to add `NSCameraUsageDescription` to your info.plist

### Example: Green Screen

`import PixelKit`

~~~~swift
let cityImage = ImagePIX()
cityImage.image = UIImage(named: "city")

let supermanVideo = VideoPIX()
supermanVideo.load(fileNamed: "superman", withExtension: "mov")

let supermanKeyed = ChromaKeyPIX()
supermanKeyed.inPix = supermanVideo
supermanKeyed.keyColor = .green

let blendPix = BlendPIX()
blendPix.blendingMode = .over
blendPix.inPixA = cityImage
blendPix.inPixB = supermanKeyed

let finalPix: PIX = blendPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This can also be done with [Blend Operators](#blend-operators) and [Effect Convenience Funcs](#effect-convenience-funcs):<br>
```swift
let pix = ImagePIX("city") & VideoPIX("superman.mov")._chromaKey(.green)
```

| <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-1.png" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-2.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-3.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-4.png" width="150" height="100"/> |
| --- | --- | --- | --- |

This is a representation of the Pixel Nodes [Green Screen](http://pixelnodes.net/pixelshare/project/?id=3E292943-194A-426B-A624-BAAF423D17C1) project.

## Coordinate Space

PixelKit coordinate space is normailzed to the vertical axis (1.0 in height) with the origin (0.0, 0.0) in the center.<br>
Note that compared to native UIKit views the vertical axis is flipped and origin is moved, this is more convinent when working with graphics is PixelKit.
A full rotation is defined by 1.0 
<!-- converter methods -->

<b>Center:</b> CGPoint(x: 0, y: 0)<br>
<b>Bottom Left:</b> CGPoint(x: -0.5 * aspectRatio, y: -0.5)<br>
<b>Top Right:</b> CGPoint(x: 0.5 * aspectRatio, y: 0.5)<br>

<b>Tip:</b> `PIX.Res` has an `.aspect` property:<br>
`let aspectRatio: LiveFloat = PIX.Res._1080p.aspect`

## Blend Operators

A quick and convenient way to blend PIXs<br>
These are the supported `PIX.BlendingMode` operators:

| `&` | `!&` | `+` | `-` | `*` | `**` | `!**` | `%` | `<>` | `><` | `--` | `~` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| .over | .under | .add | .subtract | .multiply | .power | .gamma | .difference | .minimum | .maximum | .subtractWithAlpha | .average |

```swift
let blendPix = (CameraPIX() !** NoisePIX(res: .fullHD(.portrait))) * CirclePIX(res: .fullHD(.portrait))
```

Note when using Live values, one line if else statments are written with `<?>` & `<=>`:

```swift
let a: LiveFloat = 1.0
let b: LiveFloat = 2.0
let isOdd: LiveBool = .seconds % 2.0 < 1.0
let ab: LiveFloat = isOdd <?> a <=> b
```

The default global blend operator fill mode is `.aspectFit`, change it like this:<br>
`PIX.blendOperators.globalPlacement = .aspectFill`

## Live Values

Live values can be a constant (`let`) and still have changin values.
Live values are ease to animate with the `.live` or `.seconds` static properites.

### The Live Values:
- `CGFloat` --> `LiveFloat`
- `Int` --> `LiveInt`
- `Bool` --> `LiveBool`
- `CGPoint` --> `LivePoint`
- `CGSize` --> `LiveSize`
- `CGRect` --> `LiveRect`

### Static properites:
- `LiveFloat.live`
- `LiveFloat.seconds`
- `LiveFloat.secondsSince1970`
- `LiveFloat.touch` / `LiveFloat.mouseLeft`
- `LiveFloat.touchX` / `LiveFloat.mouseX`
- `LiveFloat.touchY` / `LiveFloat.mouseY`
- `LivePoint.touchXY` / `LiveFloat.mouseXY`

### Functions:
- `liveFloat.delay(seconds: 1.0)`
- `liveFloat.filter(seconds: 1.0)`
- `liveFloat.filter(frames: 60)`

### Static functions:
- `LiveFloat.noise(range: -1.0...1.0, for: 1.0)`
- `LiveFloat.wave(range: -1.0...1.0, for: 1.0)`

## Effect Convenience Funcs

- pix.<b>_reRes(to: ._1080p * 0.5)</b> -> ResPIX
- pix.<b>_reRes(by: 0.5)</b> -> ResPIX
- pix.<b>_brightness(0.5)</b> -> LevelsPIX
- pix.<b>_darkness(0.5)</b> -> LevelsPIX
- pix.<b>_contrast(0.5)</b> -> LevelsPIX
- pix.<b>_gamma(0.5)</b> -> LevelsPIX
- pix.<b>_invert()</b> -> LevelsPIX
- pix.<b>_opacity(0.5)</b> -> LevelsPIX
- pix.<b>_blur(0.5)</b> -> BlurPIX
- pix.<b>_edge()</b> -> EdgePIX
- pix.<b>_threshold(at: 0.5)</b> -> ThresholdPIX
- pix.<b>_quantize(by: 0.5)</b> -> QuantizePIX
- pix.<b>_position(at: CGPoint(x: 0.5, y: 0.5))</b> -> TransformPIX
- pix.<b>_rotatate(to: .pi)</b> -> TransformPIX
- pix.<b>_scale(by: 0.5)</b> -> TransformPIX
- pix.<b>_kaleidoscope()</b> -> KaleidoscopePIX
- pix.<b>_twirl(0.5)</b> -> TwirlPIX
- pix.<b>_swap(.red, .blue)</b> -> ChannelMixPIX
- pix.<b>_key(.green)</b> -> ChromaKeyPIX
- pix.<b>_hue(0.5)</b> -> HueSatPIX
- pix.<b>_saturation(0.5)</b> -> HueSatPIX
- pix.<b>_crop(CGRect(x: 0.5, y 0.5, width: 0.5, height: 0.5))</b> -> CropPIX
- pix.<b>_flipX()</b> -> FlipFlopPIX
- pix.<b>_flipY()</b> -> FlipFlopPIX
- pix.<b>_flopLeft()</b> -> FlipFlopPIX
- pix.<b>_flopRight()</b> -> FlipFlopPIX
- pix.<b>_range(inLow: 0.0, inHigh: 0.5, outLow: 0.5, outHigh: 1.0)</b> -> RangePIX
- pix.<b>_range(inLow: .clear, inHigh: .gray, outLow: .gray, outHigh: .white)</b> -> RangePIX
- pix.<b>_sharpen()</b> -> SharpenPIX
- pix.<b>_slope()</b> - > SlopePIX
- pixA.<b>_lookup(pix: pixB, axis: .x)</b> -> LookupPIX
- pixA.<b>_lumaBlur(pix: pixB, radius: 0.5)</b> -> LumaBlurPIX
- pixA.<b>_displace(pix: pixB, distance: 0.5)</b> -> DisplacePIX
- pixA.<b>_remap(pix: pixB)</b> -> RemapPIX

Keep in mind that these funcs will create new PIXs.<br>
Be careful of overloading GPU memory if in a loop.

<!--
## File IO

You can find example files [here](https://github.com/anton-hexagons/PixelKit/tree/master/Assets/Examples).

`import PixelKit`

~~~~swift
let url = Bundle.main.url(forResource: "test", withExtension: "json")!
let json = try! String(contentsOf: url)
let project = try! PixelKit.main.import(json: json)
    
let finalPix: PIX = project.pixs.last!
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

To export just run `PixelKit.main.export()` once you've created your PIXs.

Note that exporting resourses like image and video are not yet supported.

-->

## MIDI

Here's an example of live midi values in range 0.0 to 1.0.

```
let circle = CirclePIX(res: ._1024)
circle.radius = .midi("13")
circle.color = .midi("17")
```

You can find the addresses by enabeling logging like this:

`MIDI.main.log = true`

## High Bit Mode

Some effects like <b>DisplacePIX</b> and <b>SlopePIX</b> can benefit from a higher bit depth.<br>
The default is 8 bits. Change it like this:
`PixelKit.main.bits = ._16`

Enable high bit mode before you create any PIXs.

Note resources do not support higher bits yet.<br>
There is currently there is some gamma offset with resources.

## MetalPIXs

<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/uv_1080p.png" width="150"/>

~~~~swift
let metalPix = MetalPIX(res: ._1080p, code:
    """
    pix = float4(u, v, 0.0, 1.0);
    """
)
~~~~

~~~~swift
let metalEffectPix = MetalEffectPIX(code:
    """
    float gamma = 0.25;
    pix = pow(inPix, 1.0 / gamma);
    """
)
metalEffectPix.inPix = CameraPIX()
~~~~

~~~~swift
let metalMergerEffectPix = MetalMergerEffectPIX(code:
    """
    pix = pow(inPixA, 1.0 / inPixB);
    """
)
metalMergerEffectPix.inPixA = CameraPIX()
metalMergerEffectPix.inPixB = ImagePIX("img_name")
~~~~

~~~~swift
let metalMultiEffectPix = MetalMultiEffectPIX(code:
    """
    float4 inPixA = inTexs.sample(s, uv, 0);
    float4 inPixB = inTexs.sample(s, uv, 1);
    float4 inPixC = inTexs.sample(s, uv, 2);
    pix = inPixA + inPixB + inPixC;
    """
)
metalMultiEffectPix.inPixs = [ImagePIX("img_a"), ImagePIX("img_b"), ImagePIX("img_c")]
~~~~

### Uniforms:

~~~~swift
var lumUniform = MetalUniform(name: "lum")
let metalPix = MetalPIX(res: ._1080p, code:
    """
    pix = float4(in.lum, in.lum, in.lum, 1.0);
    """,
    uniforms: [lumUniform]
)
lumUniform.value = 0.5
~~~~

---

## Apps

<img src="http://pixelnodes.net/assets/pixelnodes-logo.png" width="64"/>

### [Pixel Nodes](http://pixelnodes.net/)

a Live Graphics Node Editor for iPad<br>
powered by PixelKit<br>

<img src="http://hexagons.se/layercam/assets/Layer-Cam.png" width="64"/>

### [Layer Cam](http://hexagons.se/layercam/)

a camera app lets you live layer filters of your choice.<br>
combine effects to create new cool styles.

<img src="http://pixelkit.net/resources/VJLive.png" width="64"/>

### [VJLive](https://itunes.apple.com/us/app/vjlive/id1464372525?mt=8&ign-mpt=uo%3D2)

VJLive is a dual deck asset playback system with effects.<br>
Assets can be loaded from Photos. Live camera support. AirPlay support.

---

by Anton Heestand, [Hexagons](http://hexagons.se/)
