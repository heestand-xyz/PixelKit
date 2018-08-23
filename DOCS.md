# Pixels Docs


## PIXs

### Resource Content
- CameraPIX
- ImagePIX
- VideoPIX (coming soon)
- VectorPIX (coming soon)
- TextPIX (coming soon)
- PaintPIX (coming soon)

### Generator Content
- ColorPIX
- CirclePIX
- RectanglePIX
- PolygonPIX
- GradientPIX
- NoisePIX

### Single Effects
- LevelsPIX
- BlurPIX
- EdgePIX
- ThresholdPIX
- QuantizePIX
- KaleidoscopePIX
- TwirlPIX
- FeedbackPIX
- ChannelMixPIX
- ChromaKeyPIX
- CropPIX (coming soon)
- TranformPIX (coming soon)
- CornerPinPIX (coming soon)
- ColorizePIX (coming soon)
- SlopePIX (coming soon)
- SharpenPIX (coming soon)
- FlipFlopPIX (coming soon)
- DelayPIX (coming soon)
- RangePIX (coming soon)

### Merge Effects
- LookupPIX
- CrossPIX
- BlendPIX
- DispacePIX (coming soon)
- ReorderPIX (coming soon)
- RemapPIX (coming soon)
- LumaBlurPIX (coming soon)
- TimeMachinePIX (coming soon)

### Multi Effects
- BlendsPIX


## Delegates

### PixelsDelegate
To access the global frame loop:
`Pixels.main.delegate = self`

### PIXDelegate
To access will and did render of a specific PIX:
`pix.delegate = self`
