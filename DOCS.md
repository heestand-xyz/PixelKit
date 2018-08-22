# Pixels Docs

## PIXs

### Resource Content
- CameraPIX
- ImagePIX

### Generator Content
- CirclePIX
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

### Merge Effects
- LookupPIX
- CrossPIX

### Multi Effects
- BlendsPIX


## Delegates

### PixelsDelegate
To access the global frame loop:
`Pixels.main.delegate = self`

### PIXDelegate
To access will and did render of a specific PIX:
`pix.delegate = self`
