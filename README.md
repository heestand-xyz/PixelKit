<img src="https://github.com/anton-hexagons/HxPxE/raw/master/Assets/HxPxE_logo_1k_bg.png" width="128"/>

# Hexagon Pixel Engine
a Live Graphics Framework for iOS, written in Swift & Metal

## Usage Example
~~~~
let cameraPix = CameraPIX()
cameraPix.camera = .front

let levelsPix = LevelsPIX()
levelsPix.inPix = cameraPix
levelsPix.gamma = 2
levelsPix.inverted = true

let blurPix = BlurPIX()
blurPix.inPix = levelsPix
blurPix.radius = 100

let finalPix: PIX = blurPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 
