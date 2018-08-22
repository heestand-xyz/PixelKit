<img src="https://github.com/anton-hexagons/Pixels/raw/master/Assets/pixels_logo_1k_bg.png" width="128"/>

# Pixels
a Live Graphics Framework for iOS, written in Swift & Metal

## Usage Example
~~~~swift
let camera = CameraPIX()

let levels = LevelsPIX()
levels.inPix = camera
levels.gamma = 2
levels.inverted = true

let blur = BlurPIX()
blur.inPix = levels
blur.radius = 100

let final: PIX = blur
final.view.frame = view.bounds
view.addSubview(final.view)
~~~~ 
