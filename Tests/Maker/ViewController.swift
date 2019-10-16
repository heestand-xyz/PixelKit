//
//  ViewController.swift
//  PixelKitMaker
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Cocoa
import RenderKit
import PixelKit_macOS

class ViewController: NSViewController {
    
    let outputPath = "Code/Frameworks/Production/PixelKit/Resources/Tests/Renders"
    var rendersUrl: URL!
    var testPix: (PIX & NODEOut)!
    var testPixA: (PIX & NODEOut)!
    var testPixB: (PIX & NODEOut)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(">>>>>>>>> test maker started")
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        PixelKit.main.render.engine.renderMode = .manual

        let documentsUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        rendersUrl = documentsUrl.appendingPathComponent(outputPath)
        var isDir: ObjCBool = true
        guard FileManager.default.fileExists(atPath: rendersUrl.path, isDirectory: &isDir) else { fatalError() }
        
        makeTestPix()
        
        self.makeGenerators {
            self.makeSingleEffects {
                self.makeMergerEffects {
                    print(">>>>>>>>> test maker done")
                }
            }
        }
        
    }
    
    func makeTestPix() {
        let polygonPix = PolygonPIX(at: ._128)
        let noisePix = NoisePIX(at: ._128)
        noisePix.colored = true
        testPix = polygonPix + noisePix
        testPixA = polygonPix
        testPixB = noisePix
    }
    
    func makeGenerators(done: @escaping () -> ()) {
        print(">>>>>> generators started")
        let generatorsUrl = rendersUrl.appendingPathComponent("generators")
        makeDirectory(at: generatorsUrl)
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
                } else {
                    print(">>>>>> generators done")
                    done()
                }
            }
        }
        render(auto: autos.remove(at: 0))
    }
    
    func makeSingleEffects(done: @escaping () -> ()) {
        print(">>>>>> single effects started")
        let singleEffectsUrl = rendersUrl.appendingPathComponent("singleEffects")
        makeDirectory(at: singleEffectsUrl)
        var autos = AutoPIXSingleEffect.allCases
        func render(auto: AutoPIXSingleEffect) {
            print(">>> single effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.input = testPix
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = pix.renderedImage else { fatalError() }
                let imageUrl = singleEffectsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                if !autos.isEmpty {
                    render(auto: autos.remove(at: 0))
                } else {
                    print(">>>>>> single effects done")
                    done()
                }
            }
        }
        render(auto: autos.remove(at: 0))
    }
    
    func makeMergerEffects(done: @escaping () -> ()) {
        print(">>>>>> merger effects started")
        let mergerEffectsUrl = rendersUrl.appendingPathComponent("mergerEffects")
        makeDirectory(at: mergerEffectsUrl)
        var autos = AutoPIXMergerEffect.allCases
        func render(auto: AutoPIXMergerEffect) {
            print(">>> merger effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.inputA = testPixA
            pix.inputB = testPixB
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = pix.renderedImage else { fatalError() }
                let imageUrl = mergerEffectsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                if !autos.isEmpty {
                    render(auto: autos.remove(at: 0))
                } else {
                    print(">>>>>> merger effects done")
                    done()
                }
            }
        }
        render(auto: autos.remove(at: 0))
    }
    
    func makeDirectory(at url: URL) {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
    }

}

