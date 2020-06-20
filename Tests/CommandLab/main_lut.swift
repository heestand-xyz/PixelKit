import Foundation
import Cocoa
import RenderKit
import PixelKit

// MARK: - Setup

//pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib")
pixelKitMetalLibURL = URL(fileURLWithPath: "/Users/hexagons/Library/Developer/Xcode/DerivedData/PixelKitShaders-bybwgywzdtazuwhcuvvzzjsjawbl/Build/Products/Debug/PixelKitShaders-macOS.metallib")
frameLoopRenderThread = .background
PixelKit.main.render.engine.renderMode = .manual

// MARK: - PIXs

let imagePix = ImagePIX()
imagePix.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/demo.jpg"))!

let combo6bit = ImagePIX()
combo6bit.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/demo_combo_lutmap.png"))!

let lutmap2bit = ImagePIX()
lutmap2bit.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/lutmap_2bit.png"))!

let lutmap4bit = ImagePIX()
lutmap4bit.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/lutmap_4bit.png"))!

let lutmap8bit = ImagePIX()
lutmap8bit.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/lutmap_8bit.png"))!

let lutmap8bitEdit = ImagePIX()
lutmap8bitEdit.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Assets/Tools/lutmaps/lutmap_8bit_edit.png"))!

let lutPix = LUTPIX()
lutPix.inputA = combo6bit
lutPix.inputB = lutmap8bit//Edit

let finalPix: PIX = lutPix
let finalName: String = "lut_test"

//let bitCount: Int = 8
//let finalPix: PIX = LUTPIX.lutMap(bitCount: bitCount)
//let finalName: String = "lutmap\(bitCount)"

// MARK: - Render

print("render...")

var img: NSImage!
let group = DispatchGroup()
group.enter()
try PixelKit.main.render.engine.manuallyRender {
    img = finalPix.renderedImage
    group.leave()
}
group.wait()
let data: Data = NSBitmapImageRep(data: img.tiffRepresentation!)!.representation(using: .png, properties: [:])!
let url: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/\(finalName).png")
try data.write(to: url)

print("done!")
