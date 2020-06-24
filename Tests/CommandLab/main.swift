import Foundation
import Cocoa
import RenderKit
import PixelKit

// MARK: - Setup

//pixelKitMetalLibURL = FileManager.default.homeDirectoryForCurrentUser
//    .appendingPathComponent("Code/Packages/Swift/")
//    .appendingPathComponent("PixelKit/Resources/Metal Libs/")
//    .appendingPathComponent("PixelKitShaders-macOS.metallib")
frameLoopRenderThread = .background
PixelKit.main.render.engine.renderMode = .manual

// MARK: - PIXs

let polygonPix = PolygonPIX(at: .square(1000))
polygonPix.radius = 0.1
//polygonPix.cornerRadius = 0.1

let finalPix: PIX = polygonPix
let finalName: String = "pix"

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
