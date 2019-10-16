//
//  ViewController.swift
//  PixelKitMaker
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Cocoa
import PixelKit_macOS

class ViewController: NSViewController {
    
    let outputPath = "Code/Frameworks/Production/PixelKit/Resources/Tests/Renders"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(">>>>>>>>> test maker started")
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        PixelKit.main.render.engine.renderMode = .manual

        let documentsUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let rendersUrl = documentsUrl.appendingPathComponent(outputPath)
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: rendersUrl.path, isDirectory: &isDir) else { fatalError() }
        
        print(">>>>>> generators")
        let generatorsUrl = rendersUrl.appendingPathComponent("generators")
        if !FileManager.default.fileExists(atPath: generatorsUrl.path, isDirectory: &isDir) {
            try! FileManager.default.createDirectory(at: generatorsUrl, withIntermediateDirectories: false, attributes: nil)
        }
        var autos = AutoPIXGenerator.allCases
        func render(auto: AutoPIXGenerator) {
            print(">>> generator \(auto.name)")
            let pix = auto.pixType.init(at: ._128)
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = pix.renderedImage else { fatalError() }
                let imageUrl = generatorsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                if !autos.isEmpty {
                    render(auto: autos.remove(at: 0))
                }
            }
        }
        render(auto: autos.remove(at: 0))

        func done() {
            print(">>>>>>>>> test maker done")
        }
        
    }

}

