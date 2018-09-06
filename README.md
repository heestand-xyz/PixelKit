<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS<br>
powered by Metal

<b>ContentPIXs</b>:
[CameraPIX](DOCS.md#camerapix) -
[ImagePIX](DOCS.md#imagepix) -
[VideoPIX](DOCS.md#videopix) -
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
[HueSaturationPIX](DOCS.md#huesaturationpix) -
[CropPIX](DOCS.md#croppix) -
[FlipFlopPIX](DOCS.md#flipfloppix) -
[RangePIX](DOCS.md#rangepix) -
[SharpenPIX](DOCS.md#sharpenpix) -
[SlopePIX](DOCS.md#slopepix) -
[LookupPIX](DOCS.md#lookuppix) -
[CrossPIX](DOCS.md#crosspix) -
[BlendPIX](DOCS.md#blendpix) -
[BlendsPIX](DOCS.md#blendspix)

<!--
[Docs](#docs) -
[Tutorial](#tutorial) -
-->
Examples:
[Camera Effects](#example-camera-effects) -
[Green Screen](#example-green-screen)<br>
Info:
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
[Effect Convenience Funcs](#effect-convenience-funcs) -
[File IO](#file-io) -
[Apps](#apps)

Under development. More effects and pod coming soon!

## Docs
Classes, Delegates and Properties of:<br>
[Pixels](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixels) -
[PIX](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pix) - 
[PIXContent](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixcontent-pix-pixout) - 
[PIXEffect](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md#pixeffect-pix-pixin-pixout)

## Tutorial

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

let hueSaturation = HueSaturationPIX()
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
`let pix = CameraPIX().gamma(2.0).invert().hue(0.5).saturation(0.5).blur(0.25)`<br>
Tho it is not as efficiant as two LevelsPIXs and  HueSaturationPIXs will be created.

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
`let pix = ImagePIX(named: "city") & VideoPIX(fileNamed: "superman", withExtension: "mov").chromaKey(.green)`<br>

| <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-1.png" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-2.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-3.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-4.png" width="150" height="100"/> |
| --- | --- | --- | --- |

This is a representation of the Pixel Nodes [Green Screen](http://pixelnodes.net/pixelshare/project/?id=3E292943-194A-426B-A624-BAAF423D17C1) project.

## Coordinate Space

Pixels coordinate space is normailzed to the vertical axis with the origin in the center.<br>
Note that compared to native UIKit views the vertical axis is flipped.

<b>Center:</b> CGPoint(x: 0, y: 0)<br>
<b>Bottom Left:</b> CGPoint(x: -0.5 * aspectRatio, y: -0.5)<br>
<b>Top Right:</b> CGPoint(x: 0.5 * aspectRatio, y: 0.5)<br>

<b>Tip:</b> `PIX.Res` has an `.aspect` property:<br>
`let aspectRatio: CGFloat = PIX.Res._1080p.aspect`

## Blend Operators

A quick and convenient way to blend PIXs<br>
These are the supported `PIX.BlendingMode` operators:

| `&` | `!&` | `+` | `-` | `*` | `**` | `!**` | `%` | `<>` | `><` | `--` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| .over | .under | .add | .subtract | .multiply | .power | .gamma | .difference | .minimum | .maximum | .subtractWithAlpha |

~~~~swift
let blendPix = (CameraPIX() !** NoisePIX(res: .fullHD(.portrait))) * CirclePIX(res: .fullHD(.portrait))
~~~~

The default global blend operator fill mode is `.aspectFit`, change it like this:<br>
`PIX.blendOperators.globalFillMode = .aspectFill`

## Effect Convenience Funcs

- pix.<b>reRes(to: ._1080p * 0.5)</b> -> ResPIX
- pix.<b>reRes(by: 0.5)</b> -> ResPIX
- pix.<b>brightness(0.5)</b> -> LevelsPIX
- pix.<b>darkness(0.5)</b> -> LevelsPIX
- pix.<b>contrast(0.5)</b> -> LevelsPIX
- pix.<b>gamma(0.5)</b> -> LevelsPIX
- pix.<b>invert()</b> -> LevelsPIX
- pix.<b>opacity(0.5)</b> -> LevelsPIX
- pix.<b>blur(0.5)</b> -> BlurPIX
- pix.<b>edge()</b> -> EdgePIX
- pix.<b>threshold(at: 0.5)</b> -> ThresholdPIX
- pix.<b>quantize(by: 0.5)</b> -> QuantizePIX
- pix.<b>position(at: CGPoint(x: 0.5, y: 0.5))</b> -> TransformPIX
- pix.<b>rotatate(to: .pi)</b> -> TransformPIX
- pix.<b>scale(by: 0.5)</b> -> TransformPIX
- pix.<b>kaleidoscope()</b> -> KaleidoscopePIX
- pix.<b>twirl(0.5)</b> -> TwirlPIX
- pix.<b>swap(.red, .blue)</b> -> ChannelMixPIX
- pix.<b>key(.green)</b> -> ChromaKeyPIX
- pix.<b>hue(0.5)</b> -> HueSaturationPIX
- pix.<b>saturation(0.5)</b> -> HueSaturationPIX
- pix.<b>crop(CGRect(x: 0.5, y 0.5, width: 0.5, height: 0.5))</b> -> CropPIX
- pix.<b>flipX()</b> -> FlipFlopPIX
- pix.<b>flipY()</b> -> FlipFlopPIX
- pix.<b>flopLeft()</b> -> FlipFlopPIX
- pix.<b>flopRight()</b> -> FlipFlopPIX
- pix.<b>range(inLow: 0.0, inHigh: 0.5, outLow: 0.5, outHigh: 1.0)</b> -> RangePIX
- pix.<b>range(inLow: .clear, inHigh: .gray, outLow: .gray, outHigh: .white)</b> -> RangePIX
- pix.<b>sharpen()</b> -> SharpenPIX
- pix.<b>slope()</b> - > SlopePIX

Keep in mind that these funcs will create new PIXs.<br>
Be careful of overloading GPU memory if in a loop.

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

--- 

Note that Pixels dose not have simulator support. Metal for iOS can only run on a physical device.

---

## Apps

<img src="http://pixelnodes.net/assets/pixelnodes-logo.png" width="64"/>

### [Pixel Nodes](http://pixelnodes.net/)

a Live Graphics Node Editor for iPad<br>
powered by Pixels<br>

---

by Anton Heestand, [Hexagons](http://hexagons.se/)
