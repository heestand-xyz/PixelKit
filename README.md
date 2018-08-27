<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS<br>
powered by Metal

<b>Content</b>: Camera, Image, Video, Color, Circle, Rectangle, Polygon, Gradient and Noise.
<br>
<b>Effects</b>: Levels, Blur, Edge, Threshold, Quantize, Kaleidoscope, Twirl, Feedback, ChannelMix, ChromaKey, CornerPin, Lookup, Cross, Blend and Blends.

Under development. More effects coming soon.

More info in the [Docs](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md).


## Example 1

`import Pixels`

~~~~swift
let camera = CameraPIX()

let levels = LevelsPIX()
levels.inPix = camera
levels.gamma = 2
levels.inverted = true

let blur = BlurPIX()
blur.inPix = levels
blur.radius = 100

let finalPix: PIX = blur
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

Remeber to add `NSCameraUsageDescription` to your info.plist

## Example 2

`import Pixels`

~~~~swift
let cityImage = ImagePIX()
cityImage.image = UIImage(named: "city")

let supermanVideo = VideoPIX()
supermanVideo.load(fileNamed: "superman", withExtension: "mov")

let supermanKeyed = ChromaKeyPIX()
supermanKeyed.inPix = supermanVideo
supermanKeyed.keyColor = .green

let supermanPinned = CornerPinPIX()
supermanPinned.inPix = supermanKeyed
supermanPinned.perspective = true
supermanPinned.corners.bottomLeft.x = 0.125
supermanPinned.corners.bottomRight.x = 0.875

let blend = BlendPIX()
blend.inPixA = cityImage
blend.inPixB = supermanPinned
blend.blendingMode = .over

let finalPix: PIX = blend
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This is a representation of the Pixel Nodes [Green Screen](http://pixelnodes.net/pixelshare/project/?id=3E292943-194A-426B-A624-BAAF423D17C1) project.

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

Simulator not supported. Metal for iOS can only run on a physical device.

Try out the effects in [Pixel Nodes](http://pixelnodes.net/), a live graphics node editor for iPad, from which the core of Pixels was created.

by Anton Heestand, [Hexagons](http://hexagons.se/).
