//
//  ViewController.swift
//  PixelKitMaker
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Cocoa
import LiveValues
import RenderKit
import PixelKit_macOS

class ViewController: NSViewController {
    
    var rendersUrl: URL!
    var testPix: (PIX & NODEOut)!
    var testPixA: (PIX & NODEOut)!
    var testPixB: (PIX & NODEOut)!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
        PixelKit.main.render.engine.renderMode = .manual

        rendersUrl = Files.outputUrl()
        guard rendersUrl != nil else { fatalError() }
        
        (testPix, testPixA, testPixB) = Files.makeTestPixs()
        
        if check() {
            self.makeGenerators {
                self.makeSingleEffects {
                    self.makeMergerEffects {
                        self.makeRandomGenerators {
                            self.makeRandomSingleEffects {
                                self.makeRandomMergerEffects {
                                    self.done()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func check() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Render?"
        alert.informativeText = "All files will be replaced."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func done() {
        let alert = NSAlert()
        alert.messageText = "Render Done"
        alert.informativeText = "All files has been rendered."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    // MARK: - Standard
    
    func makeGenerators(done: @escaping () -> ()) {
        print(">>>>>> generators started")
        let generatorsUrl = rendersUrl.appendingPathComponent("generators")
        makeDirectory(at: generatorsUrl)
        var autos = AutoPIXGenerator.allCases
        func render(auto: AutoPIXGenerator) {
            print(">>> generator \(auto.name)")
            let pix = auto.pixType.init(at: ._128)
            let bgPix = .black & pix
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                let imageUrl = generatorsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                bgPix.destroy()
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
            let bgPix = .black & pix
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                let imageUrl = singleEffectsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                bgPix.destroy()
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
            let bgPix = .black & pix
            try! PixelKit.main.render.engine.manuallyRender {
                guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                let imageUrl = mergerEffectsUrl.appendingPathComponent("\(auto.name).png")
                guard image.savePNG(to: imageUrl) else { fatalError() }
                print(">>> saved \(auto.name)")
                pix.destroy()
                bgPix.destroy()
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
    
    // MARK: - Random
    
    func makeRandomGenerators(done: @escaping () -> ()) {
        print(">>>>>> random generators started")
        let generatorsUrl = rendersUrl.appendingPathComponent("randomGenerators")
        makeDirectory(at: generatorsUrl)
        var autos = AutoPIXGenerator.allCases
        func renderAuto(_ auto: AutoPIXGenerator) {
            print(">>> random generator \(auto.name)")
            let pix = auto.pixType.init(at: ._128)
            let bgPix = .black & pix
            func renderIndex(_ index: Int) {
                Randomize.randomizeGenerator(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                    let imageUrl = generatorsUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < Randomize.randomCount - 1 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
                        bgPix.destroy()
                        if !autos.isEmpty {
                            renderAuto(autos.remove(at: 0))
                        } else {
                            print(">>>>>> random generators done")
                            done()
                        }
                    }
                }
            }
            renderIndex(0)
        }
        renderAuto(autos.remove(at: 0))
    }
    
    func makeRandomSingleEffects(done: @escaping () -> ()) {
        print(">>>>>> random single effects started")
        let singleEffectUrl = rendersUrl.appendingPathComponent("randomSingleEffects")
        makeDirectory(at: singleEffectUrl)
        var autos = AutoPIXSingleEffect.allCases
        func renderAuto(_ auto: AutoPIXSingleEffect) {
            print(">>> random single effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.input = testPix
            let bgPix = .black & pix
            func renderIndex(_ index: Int) {
                Randomize.randomizeSingleEffect(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                    let imageUrl = singleEffectUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < Randomize.randomCount - 1 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
                        bgPix.destroy()
                        if !autos.isEmpty {
                            renderAuto(autos.remove(at: 0))
                        } else {
                            print(">>>>>> random single effects done")
                            done()
                        }
                    }
                }
            }
            renderIndex(0)
        }
        renderAuto(autos.remove(at: 0))
    }
    
    func makeRandomMergerEffects(done: @escaping () -> ()) {
        print(">>>>>> random merger effects started")
        let mergerEffectUrl = rendersUrl.appendingPathComponent("randomMergerEffects")
        makeDirectory(at: mergerEffectUrl)
        var autos = AutoPIXMergerEffect.allCases
        func renderAuto(_ auto: AutoPIXMergerEffect) {
            print(">>> random merger effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.inputA = testPixA
            pix.inputB = testPixB
            let bgPix = .black & pix
            func renderIndex(_ index: Int) {
                Randomize.randomizeMergerEffect(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = bgPix.renderedImage else { fatalError() }
                    let imageUrl = mergerEffectUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < Randomize.randomCount - 1 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
                        bgPix.destroy()
                        if !autos.isEmpty {
                            renderAuto(autos.remove(at: 0))
                        } else {
                            print(">>>>>> random merger effects done")
                            done()
                        }
                    }
                }
            }
            renderIndex(0)
        }
        renderAuto(autos.remove(at: 0))
    }
    
    func makeDirectory(at url: URL) {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
    }

}

