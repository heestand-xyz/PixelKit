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
                self.makeRandomGenerators {
                    self.makeRandomSingleEffects {
                        self.makeRandomMergerEffects {
                            print(">>>>>>>>> test maker done")
                        }
                    }
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
    
    // MARK: - Standard
    
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
    
    // MARK: - Random
    
    func makeRandomGenerators(done: @escaping () -> ()) {
        print(">>>>>> random generators started")
        let generatorsUrl = rendersUrl.appendingPathComponent("randomGenerators")
        makeDirectory(at: generatorsUrl)
        var autos = AutoPIXGenerator.allCases
        func renderAuto(_ auto: AutoPIXGenerator) {
            print(">>> random generator \(auto.name)")
            let pix = auto.pixType.init(at: ._128)
            func renderIndex(_ index: Int) {
                randomizeGenerator(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = pix.renderedImage else { fatalError() }
                    let imageUrl = generatorsUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < 10 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
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
        let singleEffectUrl = rendersUrl.appendingPathComponent("randomSingleEffect")
        makeDirectory(at: singleEffectUrl)
        var autos = AutoPIXSingleEffect.allCases
        func renderAuto(_ auto: AutoPIXSingleEffect) {
            print(">>> random single effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.input = testPix
            func renderIndex(_ index: Int) {
                randomizeSingleEffect(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = pix.renderedImage else { fatalError() }
                    let imageUrl = singleEffectUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < 10 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
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
        let mergerEffectUrl = rendersUrl.appendingPathComponent("randomMergerEffect")
        makeDirectory(at: mergerEffectUrl)
        var autos = AutoPIXMergerEffect.allCases
        func renderAuto(_ auto: AutoPIXMergerEffect) {
            print(">>> random merger effect \(auto.name)")
            let pix = auto.pixType.init()
            pix.inputA = testPixA
            pix.inputB = testPixB
            func renderIndex(_ index: Int) {
                randomizeMergerEffect(auto: auto, with: pix, at: index)
                try! PixelKit.main.render.engine.manuallyRender {
                    guard let image: NSImage = pix.renderedImage else { fatalError() }
                    let imageUrl = mergerEffectUrl.appendingPathComponent("\(auto.name)_\(index).png")
                    guard image.savePNG(to: imageUrl) else { fatalError() }
                    print(">>> saved \(index) \(auto.name)")
                    if index < 10 {
                        renderIndex(index + 1)
                    } else {
                        pix.destroy()
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
    
    func randomizeGenerator(auto: AutoPIXGenerator, with pix: PIXGenerator, at index: Int) {
        randomzeFloats(auto.autoLiveFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoLivePoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoLiveColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    func randomizeSingleEffect(auto: AutoPIXSingleEffect, with pix: PIXSingleEffect, at index: Int) {
        randomzeFloats(auto.autoLiveFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoLivePoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoLiveColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    func randomizeMergerEffect(auto: AutoPIXMergerEffect, with pix: PIXMergerEffect, at index: Int) {
        randomzeFloats(auto.autoLiveFloats(for: pix), at: index)
        randomzeInts(auto.autoLiveInts(for: pix), at: index)
        randomzeBools(auto.autoLiveBools(for: pix), at: index)
        randomzePoints(auto.autoLivePoints(for: pix), at: index)
        randomzeSizes(auto.autoLiveSizes(for: pix), at: index)
        randomzeRects(auto.autoLiveRects(for: pix), at: index)
        randomzeColors(auto.autoLiveColors(for: pix), at: index)
        randomzeEnums(auto.autoEnums(for: pix), at: index)
    }
    
    func randomzeFloats(_ values: [AutoLiveFloatProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 1_000 + UInt64(index))
        for value in values {
            let random: CGFloat = .random(in: value.value.min...value.value.max, using: &gen)
            value.value = LiveFloat(random)
        }
    }
    
    func randomzeInts(_ values: [AutoLiveIntProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 2_000 + UInt64(index))
        for value in values {
            let random: Int = .random(in: value.value.min...value.value.max, using: &gen)
            value.value = LiveInt(random)
        }
    }
    
    func randomzeBools(_ values: [AutoLiveBoolProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 3_000 + UInt64(index))
        for value in values {
            let random: Bool = .random(using: &gen)
            value.value = LiveBool(random)
        }
    }
    
    func randomzePoints(_ values: [AutoLivePointProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 4_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 4_100 + UInt64(index))
        for value in values {
            let randomX: CGFloat = .random(in: -0.5...0.5, using: &gen1)
            let randomY: CGFloat = .random(in: -0.5...0.5, using: &gen2)
            value.value = LivePoint(CGPoint(x: randomX, y: randomY))
        }
    }
    
    func randomzeSizes(_ values: [AutoLiveSizeProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 5_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 5_100 + UInt64(index))
        for value in values {
            let randomW: CGFloat = .random(in: 0.0...1.0, using: &gen1)
            let randomH: CGFloat = .random(in: 0.0...1.0, using: &gen2)
            value.value = LiveSize(CGSize(width: randomW, height: randomH))
        }
    }
    
    func randomzeRects(_ values: [AutoLiveRectProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 6_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 6_100 + UInt64(index))
        var gen3 = ArbitraryRandomNumberGenerator(seed: 6_200 + UInt64(index))
        var gen4 = ArbitraryRandomNumberGenerator(seed: 6_300 + UInt64(index))
        for value in values {
            let randomX: CGFloat = .random(in: -0.5...0.5, using: &gen1)
            let randomY: CGFloat = .random(in: -0.5...0.5, using: &gen2)
            let randomW: CGFloat = .random(in: 0.0...1.0, using: &gen3)
            let randomH: CGFloat = .random(in: 0.0...1.0, using: &gen4)
            value.value = LiveRect(CGRect(x: randomX, y: randomY, width: randomW, height: randomH))
        }
    }
    
    func randomzeColors(_ values: [AutoLiveColorProperty], at index: Int) {
        var gen1 = ArbitraryRandomNumberGenerator(seed: 7_000 + UInt64(index))
        var gen2 = ArbitraryRandomNumberGenerator(seed: 7_100 + UInt64(index))
        var gen3 = ArbitraryRandomNumberGenerator(seed: 7_200 + UInt64(index))
        var gen4 = ArbitraryRandomNumberGenerator(seed: 7_300 + UInt64(index))
        for value in values {
            let randomR: CGFloat = .random(in: 0.0...1.0, using: &gen1)
            let randomG: CGFloat = .random(in: 0.0...1.0, using: &gen2)
            let randomB: CGFloat = .random(in: 0.0...1.0, using: &gen3)
            let randomA: CGFloat = .random(in: 0.0...1.0, using: &gen4)
            value.value = LiveColor(NSColor(deviceRed: randomR, green: randomG, blue: randomB, alpha: randomA))
        }
    }
    
    func randomzeEnums(_ values: [AutoEnumProperty], at index: Int) {
        var gen = ArbitraryRandomNumberGenerator(seed: 8_000 + UInt64(index))
        for value in values {
            let random: Int = .random(in: 0..<value.cases.count, using: &gen)
            value.value = value.cases[random]
        }
    }
    
    func makeDirectory(at url: URL) {
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
    }

}

