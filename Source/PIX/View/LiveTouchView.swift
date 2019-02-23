//
//  LiveTouchView.swift
//  Pixels
//
//  Created by Hexagons on 2019-02-22.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class LiveTouchView: UIView {
    
    var touch: Bool = false
    var touchPoint: CGPoint?
    
    init() {
        super.init(frame: .zero)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = true
        moved(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moved(touches)
    }
    
    func moved(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let uv = CGPoint(x: location.x / bounds.width, y: location.y / bounds.height)
        let point = CGPoint(x: uv.x - 0.5, y: uv.y - 0.5)
        touchPoint = point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = false
        touchPoint = nil
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touch = false
        touchPoint = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
