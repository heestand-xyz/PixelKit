//
//  Files.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-17.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

class Files {

    static let outputPath = "Code/Frameworks/Production/PixelKit/Resources/Tests/Renders"
        
    static func outputUrl() -> URL? {
        let documentsUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let rendersUrl = documentsUrl.appendingPathComponent(outputPath)
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: rendersUrl.path, isDirectory: &isDir) else { return nil }
        return rendersUrl
    }
    
}
