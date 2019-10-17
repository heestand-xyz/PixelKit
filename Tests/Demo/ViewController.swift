//
//  ViewController.swift
//  PixelKitTestDemo
//
//  Created by Anton Heestand on 2019-10-17.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Cocoa
import LiveValues
import PixelKit_macOS

class ViewController: NSViewController {
    
    var finalPix: PIX!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PixelKit.main.logger.logAll()
        PixelKit.main.render.logger.logAll()
        PixelKit.main.render.engine.logger.logAll()
//        PixelKit.main.render.engine.renderMode = .manual
        
        let polygonPix = PolygonPIX() //(at: .square(40))
        polygonPix.name = "demo-polygon"
        
        finalPix = polygonPix
        view.addSubview(finalPix.view)
        
        finalPix.view.translatesAutoresizingMaskIntoConstraints = false
        finalPix.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finalPix.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        finalPix.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        finalPix.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
//        try! PixelKit.main.render.engine.manuallyRender {
//            self.imageView.image = self.finalPix.renderedImage!
//            self.log()
//        }
        
    }
    
//    func log() {
//        guard let pixels = self.finalPix.renderedPixels else { return }
//        var text = ""
//        for row in pixels.raw {
//            if text != "" {
//                text += "\n"
//            }
//            for pixel in row {
//                let c = pixel.color.lum.cg
//                text += c <= 0.0 ? "◾️" : c <= 0.25 ? "▫️" : c <= 0.5 ? "◽️" : c <= 0.75 ? "◻️" : "⬜️"
//            }
//        }
//        print(text)
//    }
    
}

