<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS, written in Swift & Metal

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
let cityImage = ImagePIX(named: "city")
let supermanVideo = VideoPIX(fileNamed: "superman", withExtension: "mov")

let supermanKeyed = ChromaKeyPIX()
supermanKeyed.inPix = supermanVideo
supermanKeyed.keyColor = .green

let blend = BlendPIX()
blend.blendingMode = .over
blend.inPixA = cityImage
blend.inPixB = supermanKeyed

let finalPix: PIX = blend
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This is a representation of the [Green Screen](http://pixelnodes.net/pixelshare/project/?id=3E292943-194A-426B-A624-BAAF423D17C1) Pixel Nodes project.

---

[Docs](https://github.com/anton-hexagons/pixels/blob/master/DOCS.md) info of PIX types and delegates. 

Try out the effects in [Pixel Nodes](http://pixelnodes.net/), a live graphics node editor for iPad, from which the core of Pixels was created.

by Anton Heestand, [Hexagons](http://hexagons.se/).
