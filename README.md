<img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Logo/pixels_logo_1k_bg.png?raw=true" width="128"/>

# PixelKit

Live Graphics for iOS, macOS and tvOS<br>
Runs on [RenderKit](https://github.com/heestand-xyz/RenderKit), powered by Metal

Examples:
[Camera Effects](#example-camera-effects) -
[Green Screen](#example-green-screen)
<br>
Info:
[Coordinate Space](#coordinate-space) -
[Blend Operators](#blend-operators) -
[Effect Convenience Funcs](#effect-convenience-funcs) -
[High Bit Mode](#high-bit-mode)

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_camera.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_camera.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_image.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_video.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_screenCapture.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_stream.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_slope.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- |
| CameraPIX | DepthCameraPIX | ImagePIX | VideoPIX | ScreenCapturePIX | StreamInPIX | SlopePIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_color.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_circle.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_rectangle.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_polygon.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_arc.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_line.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_gradient.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_stack.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ColorPIX | CirclePIX | RectanglePIX | PolygonPIX | ArcPIX | LinePIX | GradientPIX | StackPIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/%20thumb_noise.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_text.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_metal.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_twirl.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_feedback.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_delay.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_sharpen.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_stream.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| NoisePIX | TextPIX | MetalPIX | TwirlPIX | FeedbackPIX | DelayPIX | SharpenPIX | StreamOutPIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_levels.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_blur.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_edge.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_threshold.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_quantize.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_transform.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_kaleidoscope.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- |
| LevelsPIX | BlurPIX | EdgePIX | ThresholdPIX | QuantizePIX | TransformPIX | KaleidoscopePIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_channelMix.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_chromaKey.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_cornerPin.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_hueSat.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_flipFlop.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_range.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_star.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- |
| ChannelMixPIX | ChromaKeyPIX | CornerPinPIX | ColorShiftPIX | FlipFlopPIX | RangePIX | StarPIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_sepia.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_convert.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_reduce.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_clamp.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_freeze.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_flare.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_airplay.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_rec.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SepiaPIX | ConvertPIX | ReducePIX | ClampPIX | FreezePIX | FlarePIX | AirPlayPIX | RecordPIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_blend.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_cross.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_lookup.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_displace.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_remap.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_reorder.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_res.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_crop.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| BlendPIX | CrossPIX | LookupPIX | DisplacePIX | RemapPIX | ReorderPIX | ResolutionPIX | CropPIX |

| <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_blend.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_levels.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_lumaBlur.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_transform.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_delay.png?raw=true" width="32"/> | <img src="https://github.com/heestand-xyz/PixelKit/blob/main/Assets/Icons/thumb_array.png?raw=true" width="32"/> |
| --- | --- | --- | --- | --- | --- |
| BlendsPIX | LumaLevelsPIX | LumaBlurPIX | LumaTransformPIX | TimeMachinePIX | ArrayPIX |

--- 

## Install

### Swift Package

~~~~swift
.package(url: "https://github.com/heestand-xyz/PixelKit", from: "2.0.9")
~~~~

## Setup

### SwiftUI

~~~~swift
import SwiftUI
import PixelKit

class ViewModel: ObservableObject {
    
    let circlePix: CirclePIX
    let blurPix: BlurPIX
    
    let finalPix: PIX
    
    init() {
        
        circlePix = CirclePIX()

        blurPix = BlurPIX()
        blurPix.input = circlePix
        blurPix.radius = 0.25

        finalPix = blurPix
    }
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        PixelView(pix: viewModel.finalPix)
    }
}
~~~~

### UIKit

~~~~swift
import UIKit
import PixelKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let circlePix = CirclePIX()

        let blurPix = BlurPIX()
        blurPix.input = circlePix
        blurPix.radius = 0.25

        let finalPix: PIX = blurPix
        finalPix.view.frame = view.bounds
        view.addSubview(finalPix.view)
    }
}
~~~~

## Rendered Image

~~~~swift
.renderedImage // UIImage or NSImage
.renderedTexture // MTLTexture
~~~~


### Example: Camera Effects

| <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/pix_demo_01.jpg" width="150" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/pix_demo_02.jpg" width="140" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/pix_demo_03.jpg" width="140" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/pix_demo_04.jpg" width="150" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/pix_demo_05.jpg" width="150" height="100"/> |
| --- | --- | --- | --- | --- |

```swift
import SwiftUI
import PixelKit

class ViewModel: ObservableObject {
    
    let camera: CameraPIX
    let levels: LevelsPIX
    let colorShift: ColorShiftPIX
    let blur: BlurPIX
    let circle: CirclePIX
    
    let finalPix: PIX
    
    init() {
        
        camera = CameraPIX()
        camera.cameraResolution = ._1080p

        levels = LevelsPIX()
        levels.input = camera
        levels.brightness = 1.5
        levels.gamma = 0.5

        colorShift = ColorShiftPIX()
        colorShift.input = levels
        colorShift.saturation = 0.5

        blur = BlurPIX()
        blur.input = colorShift
        blur.radius = 0.25

        circle = CirclePIX(at: .square(1080))
        circle.radius = 0.45
        circle.backgroundColor = .clear

        finalPix = blur & (camera * circle)
    }
}

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        PixelView(pix: viewModel.finalPix)
    }
}
```

This can also be done with [Effect Convenience Funcs](#effect-convenience-funcs):<br>
```swift
let pix = CameraPIX().pixBrightness(1.5).pixGamma(0.5).pixSaturation(0.5).pixBlur(0.25)
```

Remeber to add `NSCameraUsageDescription` to your *Info.plist*


### Example: Green Screen

| <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/Pixels-GreenScreen-1.png" width="150" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/Pixels-GreenScreen-2.png" width="140" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/Pixels-GreenScreen-3.png" width="140" height="100"/> | <img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/Pixels-GreenScreen-4.png" width="150" height="100"/> |
| --- | --- | --- | --- |

`import RenderKit
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
let pix = cityImage & supermanVideo.pixChromaKey(.green)
```


### Example: Depth Camera

`
import RenderKit
import PixelKit`

~~~~swift
let cameraPix = CameraPIX()
cameraPix.camera = .front

let depthCameraPix = DepthCameraPIX.setup(with: cameraPix)

let levelsPix = LevelsPIX()
levelsPix.input = depthCameraPix
levelsPix.inverted = true

let lumaBlurPix = cameraPix.pixLumaBlur(pix: levelsPix, radius: 0.1)

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

let movedMultiCameraPix = multiCameraPix.pixScale(by: 0.25).pixTranslate(x: 0.375 * (9 / 16), y: 0.375)

let finalPix: PIX = cameraPix & movedMultiCameraPix
finalPix.view.frame = view.bounds
view.addSubview(finalPix.view)
~~~~ 

Note `MultiCameraPIX` requires iOS 13. 

## Coordinate Space

The PixelKit coordinate space is normailzed to the vertical axis (1.0 in height) with the origin (0.0, 0.0) in the center.<br>
Note that compared to native UIKit and SwiftUI views the vertical axis is flipped and origin is moved, this is more convinent when working with graphics in PixelKit.
A full rotation is defined by 1.0 

<b>Center:</b> CGPoint(x: 0, y: 0)<br>
<b>Bottom Left:</b> CGPoint(x: -0.5 * aspectRatio, y: -0.5)<br>
<b>Top Right:</b> CGPoint(x: 0.5 * aspectRatio, y: 0.5)<br>

<b>Tip:</b> `Resolution` has an `.aspect` property:<br>
`let aspectRatio: CGFloat = Resolution._1080p.aspect`

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

The default global blend operator fill mode is `.fit`, change it like this:<br>
`PIX.blendOperators.globalPlacement = .fill`

## Effect Convenience Funcs

- <b>.pixScaleResolution(to: ._1080p * 0.5)</b> -> ResolutionPIX
- <b>.pixScaleResolution(by: 0.5)</b> -> ResolutionPIX
- <b>.pixBrightness(0.5)</b> -> LevelsPIX
- <b>.pixDarkness(0.5)</b> -> LevelsPIX
- <b>.pixContrast(0.5)</b> -> LevelsPIX
- <b>.pixGamma(0.5)</b> -> LevelsPIX
- <b>.pixInvert()</b> -> LevelsPIX
- <b>.pixOpacity(0.5)</b> -> LevelsPIX
- <b>.pixBlur(0.5)</b> -> BlurPIX
- <b>.pixEdge()</b> -> EdgePIX
- <b>.pixThreshold(at: 0.5)</b> -> ThresholdPIX
- <b>.pixQuantize(by: 0.5)</b> -> QuantizePIX
- <b>.pixPosition(at: CGPoint(x: 0.5, y: 0.5))</b> -> TransformPIX
- <b>.pixRotatate(by: 0.5)</b> -> TransformPIX
- <b>.pixRotatate(byRadians: .pi)</b> -> TransformPIX
- <b>.pixRotatate(byDegrees: 180)</b> -> TransformPIX
- <b>.pixScale(by: 0.5)</b> -> TransformPIX
- <b>.pixKaleidoscope()</b> -> KaleidoscopePIX
- <b>.pixTwirl(0.5)</b> -> TwirlPIX
- <b>.pixSwap(.red, .blue)</b> -> ChannelMixPIX
- <b>.pixChromaKey(.green)</b> -> ChromaKeyPIX
- <b>.pixHue(0.5)</b> -> ColorShiftPIX
- <b>.pixSaturation(0.5)</b> -> ColorShiftPIX
- <b>.pixCrop(CGRect(x: 0.25, y 0.25, width: 0.5, height: 0.5))</b> -> CropPIX
- <b>.pixFlipX()</b> -> FlipFlopPIX
- <b>.pixFlipY()</b> -> FlipFlopPIX
- <b>.pixFlopLeft()</b> -> FlipFlopPIX
- <b>.pixFlopRight()</b> -> FlipFlopPIX
- <b>.pixRange(inLow: 0.0, inHigh: 0.5, outLow: 0.5, outHigh: 1.0)</b> -> RangePIX
- <b>.pixRange(inLow: .clear, inHigh: .gray, outLow: .gray, outHigh: .white)</b> -> RangePIX
- <b>.pixSharpen()</b> -> SharpenPIX
- <b>.pixSlope()</b> - > SlopePIX
- <b>.pixVignetting(radius: 0.5, inset: 0.25, gamma: 0.5)</b> -> LumaLevelsPIX
- <b>.pixLookup(pix: pixB, axis: .x)</b> -> LookupPIX
- <b>.pixLumaBlur(pix: pixB, radius: 0.5)</b> -> LumaBlurPIX
- <b>.pixLumaLevels(pix: pixB, brightness: 2.0)</b> -> LumaLevelsPIX
- <b>.pixDisplace(pix: pixB, distance: 0.5)</b> -> DisplacePIX
- <b>.pixRemap(pix: pixB)</b> -> RemapPIX

Keep in mind that these funcs will create new PIXs.<br>
Be careful of overloading GPU memory, some funcs create several PIXs.

## High Bit Mode

Some effects like <b>DisplacePIX</b> and <b>SlopePIX</b> can benefit from a higher bit depth.<br>
The default is 8 bits. Change it like this:
`PixelKit.main.render.bits = ._16`

Enable high bit mode before you create any PIXs.

Note resources do not support higher bits yet.<br>
There is currently there is some gamma offset with resources.

## MetalPIXs

<img src="https://github.com/heestand-xyz/PixelKit/raw/main/Assets/Renders/uv_1080p.png" width="150"/>

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

inspired by [TouchDesigner](https://derivative.ca)
created by Anton [Heestand XYZ](http://heestand.xyz/)
