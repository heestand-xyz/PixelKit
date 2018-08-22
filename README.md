<img src="https://github.com/anton-hexagons/Pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS, written in Swift & Metal

## Example
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

---

Try out the effects in [Pixel Nodes](http://pixelnodes.net/), a live graphics node editor for iPad, based on Pixels.

Created by Anton Heestand, [Hexagons](http://hexagons.se/).
