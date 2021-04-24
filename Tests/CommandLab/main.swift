import Foundation
import Cocoa
import RenderKit
import Resolution
import PixelKit

// MARK: - Setup

frameLoopRenderThread = .background
PixelKit.main.render.engine.renderMode = .manual
PixelKit.main.render.bits = ._16

// MARK: - PIXs

let polygonPix = PolygonPIX(at: ._1024)
polygonPix.radius = 0.5

let colorPix = ColorPIX(at: ._1024)
colorPix.color = .red
var pix: PIX & NODEOut = colorPix
if #available(OSX 10.13.4, *) {
    
    let reducePix = ReducePIX()
    reducePix.axis = .horizontal
    reducePix.method = .average
    reducePix.input = polygonPix
    pix = reducePix
    
}

let resolutionPix = ResolutionPIX(at: .custom(w: 1024, h: 32))
resolutionPix.input = pix
resolutionPix.placement = .stretch
resolutionPix.extend = .hold

var finalPix: PIX = resolutionPix
let finalName: String = "reduce"

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
