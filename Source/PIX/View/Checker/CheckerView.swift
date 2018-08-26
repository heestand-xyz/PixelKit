//
//  CheckerView.swift
//  Pixels
//
//  Created by Hexagons on 2017-12-18.
//  Copyright © 2017 Hexagons. All rights reserved.
//

import UIKit

class CheckerView: UIView {
    
    let checker: UIImage
    
    override var frame: CGRect { didSet { setNeedsDisplay() } }
    
    override init(frame: CGRect) {
        
        checker = UIImage(named: "checker", in: Bundle(identifier: Pixels.main.kBundleId), compatibleWith: nil)!
        
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext();
        
        context!.saveGState();
        
        let phase = CGSize(width: rect.width / 2, height: rect.height / 2)
        context!.setPatternPhase(phase)
        
        let color = UIColor(patternImage: checker).cgColor;
        context!.setFillColor(color);
        context!.fill(bounds);
        
        context!.restoreGState();
        
        super.draw(rect)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
