<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Logo/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS and macOS (beta)<br>
powered by Metal - inspired by TouchDesigner

<b>ContentPIXs</b>:
[CameraPIX](DOCS.md#camerapix) -
[ImagePIX](DOCS.md#imagepix) -
[VideoPIX](DOCS.md#videopix) -
[ScreenCapturePIX](DOCS.md#screencapturepix)-
[ColorPIX](DOCS.md#colorpix) -
[CirclePIX](DOCS.md#circlepix) -
[RectanglePIX](DOCS.md#rectanglepix) -
[PolygonPIX](DOCS.md#polygonpix) -
[GradientPIX](DOCS.md#gradientpix) -
[NoisePIX](DOCS.md#noisepix) - 
[TextPIX](DOCS.md#textpix)
<br>
<b>EffectPIXs</b>:
[LevelsPIX](DOCS.md#pix) -
[BlurPIX](DOCS.md#blurpix) -
[EdgePIX](DOCS.md#edgepix) -
[ThresholdPIX](DOCS.md#thresholdpix) -
[QuantizePIX](DOCS.md#quantizepix) -
[TransformPIX](DOCS.md#transformpix) -
[KaleidoscopePIX](DOCS.md#kaleidoscopepix) -
[TwirlPIX](DOCS.md#twirlpix) -
[FeedbackPIX](DOCS.md#feedbackpix) -
[ChannelMixPIX](DOCS.md#channelMixpix) -
[ChromaKeyPIX](DOCS.md#chromaKeypix) -
[CornerPinPIX](DOCS.md#cornerPinpix) -
[HueSatPIX](DOCS.md#huesaturationpix) -
[CropPIX](DOCS.md#croppix) -
[FlipFlopPIX](DOCS.md#flipfloppix) -
[RangePIX](DOCS.md#rangepix) -
[SharpenPIX](DOCS.md#sharpenpix) -
[SlopePIX](DOCS.md#slopepix) -
[CrossPIX](DOCS.md#crosspix) -
[BlendPIX](DOCS.md#blendpix) -
[LookupPIX](DOCS.md#lookuppix) -
[DisplacePIX](DOCS.md#displacepix) -
[RemapPIX](DOCS.md#remappix) -
[ReorderPIX](DOCS.md#reorderpix) -
[BlendsPIX](DOCS.md#blendspix)

Examples:
[Camera Effects](#example-camera-effects) -
[Green Screen](#example-green-screen)
<br>
Info:
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
[Effect Convenience Funcs](#effect-convenience-funcs) -
[File IO](#file-io) -
[High Bit Mode](#high-bit-mode) -
[Apps](#apps)

Under development.

--- 

## Install

To get up and running, follow these steps:
1. Download the framework and the metallib: [Pixels Beta v0.4.5 b777](https://github.com/hexagons/pixels/releases/download/0.4.5/Pixels_Beta_v0.4.5_b777.zip)
2. Add the framework files in from the zip to the root of your Xcode project.
3. In your project settings under *General* and *Embedded Binaries* add **Pixels.framework**.
4. Then under *Build Phases* and *Copy Bundle Resources* add **PixelsShaders.metallib**.
5. Now you can `import Pixels`.

Note that Pixels dose not have simulator support. Metal for iOS can only run on a physical device.

To gain camera access, on macOS, check Camera in the App Sandbox in your Xcode project settings under Capabilities.

## Docs
Classes, Delegates and Properties of:<br>
[Pixels](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixels) -
[PIX](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pix) - 
[PIXContent](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixcontent-pix-pixout) - 
[PIXEffect](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixeffect-pix-pixin-pixout)

## Tutorials

[Getting started with Pixels in Swift](http://blog.hexagons.se/uncategorized/getting-started-with-pixels/)<br>
[Getting started with Metal in Pixels](http://blog.hexagons.se/uncategorized/getting-started-with-metal-in-pixels/)

[High Quality](http://hexagons.se/pixels/tutorials/pixels_tutorial_1.mov) (1,5 GB) -
[Mid Quality](http://hexagons.se/pixels/tutorials/pixels_tutorial_1_compressed.mov) (0,5 GB) -
[Low Quality](http://hexagons.se/pixels/tutorials/pixels_tutorial_1_very_compressed.mov) (200 MB) -
[Screen Lapse x4](http://hexagons.se/pixels/tutorials/pixels_tutorial_1_screen_lapse_x4.mov) (100 MB)<br>
Video used: [warm neon birth](https://vimeo.com/104094320) by [BEEPLE](https://www.beeple-crap.com).

## Example: Camera Effects

`import Pixels`

~~~~swift
let camera = CameraPIX()

let levels = LevelsPIX()
levels.inPix = camera
levels.gamma = 2.0
levels.inverted = true

let hueSaturation = HueSatPIX()
hueSaturation.inPix = levels
hueSaturation.hue = 0.5
hueSaturation.saturation = 0.5

let blur = BlurPIX()
blur.inPix = hueSaturation
blur.radius = 0.25

let finalPix: PIX = blur
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This can also be done with [Effect Convenience Funcs](#effect-convenience-funcs):<br>
```swift
let pix = CameraPIX()._gamma(2.0)._invert()._hue(0.5)._saturation(0.5)._blur(0.25)
```
Tho it is not as efficiant as two LevelsPIXs and  HueSatPIXs will be created.

Remeber to add `NSCameraUsageDescription` to your info.plist

## Example: Green Screen

`import Pixels`

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

Pixels coordinate space is normailzed to the vertical axis (1.0 in height) with the origin (0.0, 0.0) in the center.<br>
Note that compared to native UIKit views the vertical axis is flipped and origin is moved, this is more convinent when working with graphics is Pixels.
A full rotation is defined by 1.0 
<!-- converter methods -->

<b>Center:</b> CGPoint(x: 0, y: 0)<br>
<b>Bottom Left:</b> CGPoint(x: -0.5 * aspectRatio, y: -0.5)<br>
<b>Top Right:</b> CGPoint(x: 0.5 * aspectRatio, y: 0.5)<br>

<b>Tip:</b> `PIX.Res` has an `.aspect` property:<br>
`let aspectRatio: CGFloat = PIX.Res._1080p.aspect`

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

You can find example files [here](https://github.com/anton-hexagons/Pixels/tree/master/Assets/Examples).

`import Pixels`

~~~~swift
let url = Bundle.main.url(forResource: "test", withExtension: "json")!
let json = try! String(contentsOf: url)
let project = try! Pixels.main.import(json: json)
    
let finalPix: PIX = project.pixs.last!
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

To export just run `Pixels.main.export()` once you've created your PIXs.

Note that exporting resourses like image and video are not yet supported.

-->

## MIDI

Here's an example of live midi values in range 0.0 to 1.0.

```
let circle = CirclePIX(res: ._1024)
circle.radius = .midi("#13")
circle.color = .midi("#17")
```

You can find the addresses by enabeling logging like this:

`MIDI.main.log = true`

## High Bit Mode

Some effects like <b>DisplacePIX</b> and <b>SlopePIX</b> can benefit from a higher bit depth.<br>
The default is 8 bits. Change it like this:
`Pixels.main.bits = ._16`

Enable high bit mode before you create any PIXs.

Note resources do not support higher bits yet.<br>
There is currently there is some gamma offset with resources.

## MetalPIXs

<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/uv_1080p.png" width="90"/>

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
powered by Pixels<br>

<img src="http://hexagons.se/layercam/assets/Layer-Cam.png" width="64"/>

### [Layer Cam](http://hexagons.se/layercam/)

a camera app lets you live layer filters of your choice.<br>
combine effects to create new cool styles.

---

by Anton Heestand, [Hexagons](http://hexagons.se/)
