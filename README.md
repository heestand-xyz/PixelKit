<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS<br>
powered by Metal

<b>Content</b>: Camera, Image, Video, Color, Circle, Rectangle, Polygon, Gradient, Noise and Text.
<br>
<b>Effects</b>: Levels, Blur, Edge, Threshold, Quantize, Transform, Kaleidoscope, Twirl, Feedback, ChannelMix, ChromaKey, CornerPin, HueSaturation, Crop, Lookup, Cross, Blend and Blends.

[Docs](#docs) -
[Tutorial](#tutorial) -
[Example: Camera Effects](#example-camera-effects) -
[Example: Green Screen](#example-green-screen) -
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
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
levels.gamma = 2
levels.inverted = true

let hueSaturation = HueSaturationPIX()
hueSaturation.inPix = levels
hueSaturation.hue = 0.5
hueSaturation.saturation = 0.5

let blur = BlurPIX()
blur.inPix = hueSaturation
blur.radius = 100

let finalPix: PIX = blur
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

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

let finalPix = cityImage & supermanKeyed
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

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
