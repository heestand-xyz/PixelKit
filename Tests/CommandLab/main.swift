import Foundation
import Cocoa
import RenderKit
import PixelKit

// MARK: - Setup

pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Code/Frameworks/Swift/")
    .appendingPathComponent("PixelKit/Resources/Metal Libs/")
    .appendingPathComponent("PixelKitShaders-macOS.metallib")
frameLoopRenderThread = .background
PixelKit.main.render.engine.renderMode = .manual

// MARK: - PIXs

let lowPix = ImagePIX()
lowPix.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Desktop/HDR Source Low.png"))!

let midPix = ImagePIX()
midPix.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Desktop/HDR Source Mid.png"))!

let highPix = ImagePIX()
highPix.image = NSImage(contentsOf: FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Desktop/HDR Source High.png"))!

let hdrPix = HDRPIX()
hdrPix.inputs = [lowPix, midPix, highPix]
hdrPix.lowEV = -0.7
hdrPix.highEV = 1.25

let finalPix: PIX = hdrPix
let finalName: String = "HDRPIX"

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
