<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Logo/pixels_logo_1k_bg.png" width="128"/>

# PixelKit

[![License](https://img.shields.io/cocoapods/l/PixelKit.svg)](https://github.com/hexagons/PixelKit/blob/master/LICENSE)
[![Cocoapods](https://img.shields.io/cocoapods/v/PixelKit.svg)](http://cocoapods.org/pods/PixelKit)
[![Platform](https://img.shields.io/cocoapods/p/PixelKit.svg)](http://cocoapods.org/pods/PixelKit)
<img src="https://img.shields.io/badge/in-swift5.0-orange.svg">

Live Graphics Framework for iOS, macOS and tvOS<br>
runs on [RenderKit](https://github.com/hexagons/RenderKit) - powered by Metal

Examples:
[Camera Effects](#example-camera-effects) -
[Green Screen](#example-green-screen) - 
[Hello Pixels App](https://github.com/hexagons/Hello-Pixels) - 
[Code Reference](http://pixelkit.net/reference/) - 
[Code Examples](http://pixelkit.net/examples/) -
[Code Demos](http://pixelkit.net/demos/)
<br>
Info:
[Website](http://pixelkit.net/) -
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
[Effect Convenience Funcs](#effect-convenience-funcs) -
[High Bit Mode](#high-bit-mode) -
[Apps](#apps)

| <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_camera.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_camera.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_image.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_video.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_screenCapture.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_stream.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- |
| [Camera](http://pixelkit.net/docs/Classes/CameraPIX.html) | Depth Camera | [Image](http://pixelkit.net/docs/Classes/ImagePIX.html) | [Video](http://pixelkit.net/docs/Classes/VideoPIX.html) | Screen Capture | [Stream In](http://pixelkit.net/docs/Classes/StreamInPIX.html) |

| <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_color.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_circle.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_rectangle.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_polygon.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_arc.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_line.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_gradient.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/%20thumb_noise.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_text.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_metal.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [Color](http://pixelkit.net/docs/Classes/ColorPIX.html) | [Circle](http://pixelkit.net/docs/Classes/CirclePIX.html) | [Rectangle](http://pixelkit.net/docs/Classes/RectanglePIX.html) | [Polygon](http://pixelkit.net/docs/Classes/PolygonPIX.html) | [Arc](http://pixelkit.net/docs/Classes/ArcPIX.html) | [Line](http://pixelkit.net/docs/Classes/LinePIX.html) | [Gradient](http://pixelkit.net/docs/Classes/GradientPIX.html) | [Noise](http://pixelkit.net/docs/Classes/NoisePIX.html) | [Text](http://pixelkit.net/docs/Classes/TextPIX.html) | [Metal](http://pixelkit.net/docs/Classes/MetalPIX.html) |

| <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_levels.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_blur.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_edge.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_threshold.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_quantize.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_transform.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_kaleidoscope.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_twirl.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_feedback.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_delay.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [Levels](http://pixelkit.net/docs/Classes/LevelsPIX.html) | [Blur](http://pixelkit.net/docs/Classes/BlurPIX.html) | [Edge](http://pixelkit.net/docs/Classes/EdgePIX.html) | [Threshold](http://pixelkit.net/docs/Classes/ThresholdPIX.html) | [Quantize](http://pixelkit.net/docs/Classes/QuantizePIX.html) | [Transform](http://pixelkit.net/docs/Classes/TransformPIX.html) | [Kaleidoscope](http://pixelkit.net/docs/Classes/KaleidoscopePIX.html) | [Twirl](http://pixelkit.net/docs/Classes/TwirlPIX.html) | [Feedback](http://pixelkit.net/docs/Classes/FeedbackPIX.html) | [Delay](http://pixelkit.net/docs/Classes/DelayPIX.html) |

| <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_channelMix.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_chromaKey.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_cornerPin.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_hueSat.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_crop.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_flipFlop.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_range.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_sharpen.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_slope.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_sepia.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [Channel Mix](http://pixelkit.net/docs/Classes/ChannelMixPIX.html) | [Chroma Key](http://pixelkit.net/docs/Classes/ChromaKeyPIX.html) | [Corner Pin](http://pixelkit.net/docs/Classes/CornerPinPIX.html) | [Color Shift](http://pixelkit.net/docs/Classes/ColorShiftPIX.html) | [Crop](http://pixelkit.net/docs/Classes/CropPIX.html) | [Flip Flop](http://pixelkit.net/docs/Classes/FlipFlopPIX.html) | [Range](http://pixelkit.net/docs/Classes/RangePIX.html) | [Sharpen](http://pixelkit.net/docs/Classes/SharpenPIX.html) | [Slope](http://pixelkit.net/docs/Classes/SlopePIX.html) | [Sepia](http://pixelkit.net/docs/Classes/SepiaPIX.html) | 

| <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_blend.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_cross.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_lookup.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_displace.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_remap.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_reorder.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_res.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_convert.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_clamp.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_freeze.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_flare.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [Blend](http://pixelkit.net/docs/Classes/BlendPIX.html) | [Cross](http://pixelkit.net/docs/Classes/CrossPIX.html) | [Lookup](http://pixelkit.net/docs/Classes/LookupPIX.html) | [Displace](http://pixelkit.net/docs/Classes/DisplacePIX.html) | [Remap](http://pixelkit.net/docs/Classes/RemapPIX.html) | [Reorder](http://pixelkit.net/docs/Classes/ReorderPIX.html) | [Res](http://pixelkit.net/docs/Classes/ResolutionPIX.html) | [Convert](http://pixelkit.net/docs/Classes/ConvertPIX.html) | [Clamp](http://pixelkit.net/docs/Classes/ClampPIX.html) | [Freeze](http://pixelkit.net/docs/Classes/FreezePIX.html) | [Flare](http://pixelkit.net/docs/Classes/FlarePIX.html) |

<img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_blend.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_levels.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_lumaBlur.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_delay.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_array.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_airplay.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_rec.png?raw=true" width="32"/> | <img src="https://github.com/hexagons/PixelKit/blob/master/Assets/Icons/thumb_stream.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [Blends](http://pixelkit.net/docs/Classes/BlendsPIX.html) | [Luma Levels](http://pixelkit.net/docs/Classes/LumaLevelsPIX.html) | [Luma Blur](http://pixelkit.net/docs/Classes/LumaBlurPIX.html) | [Time Machine](http://pixelkit.net/docs/Classes/TimeMachinePIX.html) | [Array](http://pixelkit.net/docs/Classes/ArrayPIX.html) | [AirPlay](http://pixelkit.net/docs/Classes/AirPlayPIX.html) | [Record](http://pixelkit.net/docs/Classes/RecordPIX.html) | [Stream Out](http://pixelkit.net/docs/Classes/StreamOutPIX.html) |

See the [PixelKit PIX List](https://www.notion.so/6f77438748574ada844cae3813a5bc1f?v=bd4c45ba659f48dfa0ea7ac8bcf7ca9e) in Notion for PIXs in development.

--- 

## Install

### Swift Package

~~~~swift
.package(url: "https://github.com/hexagons/PixelKit.git", from: "1.1.5")
~~~~

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate `PixelKit` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PixelKit', '~> 1.0.0'
```

## Import

```swift
import PixelKit
```

To access `LiveColor` and `Resolution` import the dependencies of PixelKit:

~~~~swift
import LiveValues
import RenderKit
~~~~

## Setup

### SwiftUI

~~~~swift
struct ContentView: View {
    var body: some View {
        BlurPIXUI {
            CirclePIXUI()
        }
            .radius(0.25)
            .edgesIgnoringSafeArea(.all)
    }
}
~~~~

### UIKit

~~~~swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let circlePix = CirclePIX(at: .fullscreen)

        let blurPix = BlurPIX()
        blurPix.input = circlePix
        blurPix.radius = 0.25

        let finalPix: PIX = blurPix
        finalPix.view.frame = view.bounds
        view.addSubview(finalPix.view)
        
    }
    
}
~~~~

## Docs

[LiveValues](http://hexagons.se/live-values/)<br>
[RenderKit](http://renderkit.info)<br>
[PixelKit](http://pixelkit.net/docs/)

## Tutorials

[Getting started with PixelKit in Swift](http://blog.hexagons.se/uncategorized/getting-started-with-pixels/)<br>
[Getting started with Metal in PixelKit](http://blog.hexagons.se/uncategorized/getting-started-with-metal-in-pixels/)<br>
[Green Screen in Swift & PixelKit](http://blog.hexagons.se/blog/green-screen-in-swift-pixelkit/)<br>
[Particles in VertexKit & PixelKit](http://blog.hexagons.se/blog/particles-in-vertexkit-pixelkit/)

## Examples

[Hello Pixels App](https://github.com/hexagons/Hello-Pixels)<br>
[Code Reference](http://pixelkit.net/reference/)<br>
[Code Examples](http://pixelkit.net/examples/)<br>
[Code Demos](http://pixelkit.net/demos/)

### Example: Camera Effects

| <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_01.jpg" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_02.jpg" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_03.jpg" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_04.jpg" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/pix_demo_05.jpg" width="150" height="100"/> |
| --- | --- | --- | --- | --- |

#### SwiftUI
```swift
struct ContentView: View {
    var content: PIXUI {
        ColorShiftPIXUI {
            LevelsPIXUI {
                ResolutionPIXUI {
                    CameraPIXUI()
                }
            }
                .gamma(0.5)
                .brightness(LiveFloat(1.5))
        }
            .saturation(LiveFloat(0.5))
    }
    var body: some View {
        BlendsPIXUI {
            BlurPIXUI {
                RawPIXUI(pix: content.pix)
            }
                .radius(0.25)
            BlendsPIXUI {
                CirclePIXUI()
                    .bgColor(.clear)
                    .radius(0.25)
                RawPIXUI(pix: content.pix)
            }
                .blendMode(.multiply)
        }
            .blendMode(.over)
    }
}
```

~~~~swift
let camera = CameraPIX()

let levels = LevelsPIX()
levels.input = camera
levels.brightness = 1.5
levels.gamma = 0.5

let colorShift = ColorShiftPIX()
colorShift.input = levels
colorShift.saturation = 0.5

let blur = BlurPIX()
blur.input = colorShift
blur.radius = 0.25

let res: Resolution = .custom(w: 1500, h: 1000)
let circle = CirclePIX(at: res)
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

Remeber to add `NSCameraUsageDescription` to your info.plist

### Example: Green Screen

`import LiveValues
import RenderKit
import PixelKit`

~~~~swift
let cityImage = ImagePIX()
cityImage.image = UIImage(named: "city")

let supermanVideo = VideoPIX()
supermanVideo.load(fileNamed: "superman", withExtension: "mov")

let supermanKeyed = ChromaKeyPIX()
supermanKeyed.input = supermanVideo
supermanKeyed.keyColor = .green

let blendPix = BlendPIX()
blendPix.blendingMode = .over
blendPix.inputA = cityImage
blendPix.inputB = supermanKeyed

let finalPix: PIX = blendPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

This can also be done with [Blend Operators](#blend-operators) and [Effect Convenience Funcs](#effect-convenience-funcs):<br>
```swift
let pix = cityImage & supermanVideo._chromaKey(.green)
```

#### SwiftUI
```swift
struct ContentView: View {
    var body: some View {
        BlendsPIXUI {
            ImagePIXUI(image: UIImage(named: "city")!)
            ChromaKeyPIXUI {
                VideoPIXUI(fileNamed: "superman", withExtension: "mov")
            }
                .keyColor(.green)
        }
            .blendMode(.over)
    }
}
```

| <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-1.png" width="150" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-2.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-3.png" width="140" height="100"/> | <img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/Pixels-GreenScreen-4.png" width="150" height="100"/> |
| --- | --- | --- | --- |

This is a representation of the Pixel Nodes [Green Screen](https://pixelnodes.app/pixelshare/project/?id=3E292943-194A-426B-A624-BAAF423D17C1) project.


### Example: Depth Camera

`import LiveValues
import RenderKit
import PixelKit`

~~~~swift
let cameraPix = CameraPIX()
cameraPix.camera = .front

let depthCameraPix = DepthCameraPIX.setup(with: cameraPix)

let levelsPix = LevelsPIX()
levelsPix.input = depthCameraPix
levelsPix.inverted = true

let lumaBlurPix = cameraPix._lumaBlur(with: levelsPix, radius: 0.1)

let finalPix: PIX = lumaBlurPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

The `DepthCameraPIX` was added in PixelKit `v0.8.4` and requires an iPhone X or newer.

Note to use the `setup(with:filter:)` method of `DepthCameraPIX`.<br>
It will take care of orientation, color and enable depth on the `CameraPIX`.

To gain access to depth values ouside of the 0.0 and 1.0 bounds,<br>
enable `16 bit` mode like this: `PixelKit.main.render.bits = ._16`


### Example: Multi Camera

~~~~swift
let cameraPix = CameraPIX()
cameraPix.camera = .back

let multiCameraPix = MultiCameraPIX.setup(with: cameraPix, camera: .front)

let movedMultiCameraPix = multiCameraPix._scale(by: 0.25)._move(x: 0.375 * (9 / 16), y: 0.375)

let finalPix: PIX = camearPix & movedMultiCameraPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

Note `MultiCameraPIX` requires iOS 13. 

## Coordinate Space

PixelKit coordinate space is normailzed to the vertical axis (1.0 in height) with the origin (0.0, 0.0) in the center.<br>
Note that compared to native UIKit views the vertical axis is flipped and origin is moved, this is more convinent when working with graphics is PixelKit.
A full rotation is defined by 1.0 
<!-- converter methods -->

<b>Center:</b> CGPoint(x: 0, y: 0)<br>
<b>Bottom Left:</b> CGPoint(x: -0.5 * aspectRatio, y: -0.5)<br>
<b>Top Right:</b> CGPoint(x: 0.5 * aspectRatio, y: 0.5)<br>

<b>Tip:</b> `Resolution` has an `.aspect` property:<br>
`let aspectRatio: LiveFloat = Resolution._1080p.aspect`

## Blend Operators

A quick and convenient way to blend PIXs<br>
These are the supported `BlendingMode` operators:

| `&` | `!&` | `+` | `-` | `*` | `**` | `!**` | `%` | `~` | `°` |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| .over | .under | .add | .subtract | .multiply | .power | .gamma | .difference | .average | cosine |


| `<>` | `><` | `++` | `--` | `<->` | `>-<` | `+-+` |
| --- | --- | --- | --- | --- | --- | --- |
| .minimum | .maximum | .addWithAlpha | .subtractWithAlpha | inside | outside | exclusiveOr |

```swift
let blendPix = (CameraPIX() !** NoisePIX(at: .fullHD(.portrait))) * CirclePIX(at: .fullHD(.portrait))
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
- `LiveFloat.gyroX`
- `LiveFloat.gyroY`
- `LiveFloat.gyroZ`
- `LiveFloat.accelerationX/Y/X`
- `LiveFloat.magneticFieldX/Y/X`
- `LiveFloat.deviceAttitudeX/Y/X`
- `LiveFloat.deviceGravityX/Y/X`
- `LiveFloat.deviceHeading`

### Functions:
- `liveFloat.delay(seconds: 1.0)`
- `liveFloat.filter(seconds: 1.0)`
- `liveFloat.filter(frames: 60)`

### Static functions:
- `LiveFloat.noise(range: -1.0...1.0, for: 1.0)`
- `LiveFloat.wave(range: -1.0...1.0, for: 1.0)`

## Effect Convenience Funcs

- pix.<b>_reRes(to: ._1080p * 0.5)</b> -> ResolutionPIX
- pix.<b>_reRes(by: 0.5)</b> -> ResolutionPIX
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
- pix.<b>_hue(0.5)</b> -> ColorShiftPIX
- pix.<b>_saturation(0.5)</b> -> ColorShiftPIX
- pix.<b>_crop(CGRect(x: 0.25, y 0.25, width: 0.5, height: 0.5))</b> -> CropPIX
- pix.<b>_flipX()</b> -> FlipFlopPIX
- pix.<b>_flipY()</b> -> FlipFlopPIX
- pix.<b>_flopLeft()</b> -> FlipFlopPIX
- pix.<b>_flopRight()</b> -> FlipFlopPIX
- pix.<b>_range(inLow: 0.0, inHigh: 0.5, outLow: 0.5, outHigh: 1.0)</b> -> RangePIX
- pix.<b>_range(inLow: .clear, inHigh: .gray, outLow: .gray, outHigh: .white)</b> -> RangePIX
- pix.<b>_sharpen()</b> -> SharpenPIX
- pix.<b>_slope()</b> - > SlopePIX
- pixA.<b>_lookup(with: pixB, axis: .x)</b> -> LookupPIX
- pixA.<b>_lumaBlur(with: pixB, radius: 0.5)</b> -> LumaBlurPIX
- pixA.<b>_lumaLevels(with: pixB, brightness: 2.0)</b> -> LumaLevelsPIX
- pixA.<b>_vignetting(with: pixB, inset: 0.25, gamma: 0.5)</b> -> LumaLevelsPIX
- pixA.<b>_displace(with: pixB, distance: 0.5)</b> -> DisplacePIX
- pixA.<b>_remap(with: pixB)</b> -> RemapPIX

Keep in mind that these funcs will create new PIXs.<br>
Be careful of overloading GPU memory, some funcs create several PIXs.

## MIDI

Here's an example of live midi values in range 0.0 to 1.0.

```
let circle = CirclePIX(at: ._1024)
circle.radius = .midi("13")
circle.color = .midi("17")
```

You can find the addresses by enabeling logging like this:

`MIDI.main.log = true`

## High Bit Mode

Some effects like <b>DisplacePIX</b> and <b>SlopePIX</b> can benefit from a higher bit depth.<br>
The default is 8 bits. Change it like this:
`PixelKit.main.render.bits = ._16`

Enable high bit mode before you create any PIXs.

Note resources do not support higher bits yet.<br>
There is currently there is some gamma offset with resources.

## MetalPIXs

<img src="https://github.com/anton-hexagons/pixels/raw/master/Assets/Renders/uv_1080p.png" width="150"/>

~~~~swift
let metalPix = MetalPIX(at: ._1080p, code:
    """
    pix = float4(u, v, 0.0, 1.0);
    """
)
~~~~

~~~~swift
let metalEffectPix = MetalEffectPIX(code:
    """
    float gamma = 0.25;
    pix = pow(input, 1.0 / gamma);
    """
)
metalEffectPix.input = CameraPIX()
~~~~

~~~~swift
let metalMergerEffectPix = MetalMergerEffectPIX(code:
    """
    pix = pow(inputA, 1.0 / inputB);
    """
)
metalMergerEffectPix.inputA = CameraPIX()
metalMergerEffectPix.inputB = ImagePIX("img_name")
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
metalMultiEffectPix.inputs = [ImagePIX("img_a"), ImagePIX("img_b"), ImagePIX("img_c")]
~~~~

### Uniforms:

~~~~swift
var lumUniform = MetalUniform(name: "lum")
let metalPix = MetalPIX(at: ._1080p, code:
    """
    pix = float4(in.lum, in.lum, in.lum, 1.0);
    """,
    uniforms: [lumUniform]
)
lumUniform.value = 0.5
~~~~

### Notes:

- To gain camera access, on macOS, check Camera in the App Sandbox in your Xcode project settings under Capabilities.

---

## Apps

<img src="http://pixelkit.net/resources/pixel-nodes-logo-512px.png" width="64"/>

### [Pixel Nodes](https://pixelnodes.app/)

a Live Graphics Node Editor for iPad<br>
powered by PixelKit<br>


<img src="http://hexagons.se/layercam/assets/Layer-Cam.png" width="64"/>

### [Layer Cam](http://hexagons.se/layercam/)

a camera app lets you live layer filters of your choice.<br>
combine effects to create new cool styles.


<img src="http://pixelkit.net/resources/pixel_cam.png" width="64"/>

### [Pixel Cam](https://itunes.apple.com/se/app/the-pixel-cam/id1465959201)

Live camera filters.<br>
Load photos from library.


<img src="http://pixelkit.net/resources/VJLive.png" width="64"/>

### [VJLive](https://itunes.apple.com/us/app/vjlive/id1464372525?mt=8&ign-mpt=uo%3D2)

VJLive is a dual deck asset playback system with effects.<br>
Assets can be loaded from Photos. Live camera support. AirPlay support.

---

inspired by TouchDesigner
created by Anton [Heestand XYZ](http://heestand.xyz/)
