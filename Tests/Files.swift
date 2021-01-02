//
//  Files.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-17.
//

import RenderKit
import PixelKit_macOS

class Files {

    static let outputPath = "Code/Frameworks/Production/PixelKit/Resources/Tests/Renders"
        
    static func outputUrl() -> URL? {
        let documentsUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let rendersUrl = documentsUrl.appendingPathComponent(outputPath)
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: rendersUrl.path, isDirectory: &isDir) else { return nil }
        return rendersUrl
    }
    
    static func makeTestPixs() -> (main: PIX & NODEOut, a: PIX & NODEOut, b: PIX & NODEOut) {
        let polygonPix = PolygonPIX(at: ._128)
        polygonPix.vertexCount = 3
        let noisePix = NoisePIX(at: ._128)
        noisePix.colored = true
        return (main: polygonPix + noisePix, a: polygonPix, b: noisePix)
    }
    
}
