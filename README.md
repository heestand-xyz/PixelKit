<img src="https://github.com/anton-hexagons/Pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS, written in Swift & Metal

## Example

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

---

Try out the effects in [Pixel Nodes](http://pixelnodes.net/), a live graphics node editor for iPad, from which the core of Pixels was created.

by Anton Heestand, [Hexagons](http://hexagons.se/).
