# ``PixelKit``

Live Graphics

## Overview

In PixelKit you create ``PIX``s. There is content, effects and outputs.

To connect some content with an effect, assign the content to the ``PIXSingleEffect/input`` property of the effect.

In PixelKit the coordinate system is "aspect normalized", with a height of `1.0` from `-0.5` to `0.5`, the center in the middle.

## Topics

### Resources

- ``CameraPIX``
- ``ImagePIX``
- ``VideoPIX``
- ``PaintPIX``
- ``VectorPIX``
- ``WebPIX`
- ``StreamInPIX``
- ``ScreenCapturePIX``

### Generators

- ``ColorPIX``
- ``CirclePIX``
- ``RectanglePIX``
- ``ArcPIX``
- ``LinePIX``
- ``PolygonPIX``
- ``GradientPIX``
- ``NoisePIX``

### Sprite

- ``TextPIX``

### Effects

- ``BlurPIX``
- ``ColorShiftPIX``
- ``CropPIX``
- ``EdgePIX``
- ``LevelsPIX``
- ``TransformPIX``
- ``ThresholdPIX``
- ``ChannelMixPIX``
- ``ChromaKeyPIX``
- ``ClampPIX``
- ``ColorConvertPIX``
- ``ConvertPIX``
- ``CornerPinPIX``
- ``DelayPIX``
- ``FeedbackPIX``
- ``FlarePIX``
- ``FlipFlopPIX``
- ``FreezePIX``
- ``KaleidoscopePIX``
- ``QuantizePIX``
- ``RainbowBlurPIX``
- ``RangePIX``
- ``ResolutionPIX``
- ``SaliencyPIX``
- ``SepiaPIX``
- ``SharpenPIX``
- ``SlopePIX``
- ``TwirlPIX``

### Effects (Merger)

- ``BlendPIX``
- ``CrossPIX``
- ``DisplacePIX``
- ``LookupPIX``
- ``LumaBlurPIX``
- ``LumaColorShiftPIX``
- ``LumaLevelsPIX``
- ``LumaRainbowBlurPIX``
- ``LumaTransformPIX``
- ``RemapPIX``
- ``ReorderPIX``
- ``TimeMachinePIX``

### Effects (Multi)

- ``BlendsPIX``
- ``ArrayPIX``
- ``StackPIX``

### Output

- ``AirPlayPIX``
- ``RecordPIX``
- ``StreamOutPIX``
- ``SyphonOutPIX``
