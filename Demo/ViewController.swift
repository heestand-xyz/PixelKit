//
//  ViewController.swift
//  PixelKitDemo
//
//  Created by Anton Heestand on 2019-10-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import PixelKit

class ViewController: UIViewController {

    var finalPix: PIX!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let polygonPix = PolygonPIX()
        
        finalPix = polygonPix
        view.addSubview(finalPix.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        finalPix.view.translatesAutoresizingMaskIntoConstraints = false
        finalPix.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finalPix.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        finalPix.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        finalPix.view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
    }

}

