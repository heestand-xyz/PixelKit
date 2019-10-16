//
//  extensions.swift
//  PixelKitTestMaker
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation
import Cocoa

extension NSBitmapImageRep {
    var png: Data? {
        return representation(using: .png, properties: [:])
    }
}
extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}
extension NSImage {
    var png: Data? {
        return tiffRepresentation?.bitmap?.png
    }
    func savePNG(to url: URL) -> Bool {
        do {
            try png?.write(to: url)
            return true
        } catch {
            print(error)
            return false
        }

    }
}
