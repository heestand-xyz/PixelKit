import Foundation
import Cocoa
import RenderKit
import PixelKit

// MARK: - Setup

pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib")
frameLoopRenderThread = .background
PixelKit.main.render.engine.renderMode = .manual

// MARK: - PIXs

let bitCount: Int = 8
let finalPix: PIX = LUTPIX.lutMap(bitCount: bitCount)
let finalName: String = "lutmap\(bitCount)"

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
