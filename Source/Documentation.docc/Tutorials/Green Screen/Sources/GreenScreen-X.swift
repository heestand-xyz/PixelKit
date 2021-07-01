import SwiftUI
import PixelKit





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
