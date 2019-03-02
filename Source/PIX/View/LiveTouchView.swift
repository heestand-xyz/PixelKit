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
    var force: CGFloat = 0
    var touchPointMain: CGPoint?
//    var touchPoint: CGPoint? {
//        return touchPoints.first
//    }
//    var touchPoints: [CGPoint] {
//        return allTouches.map({ touch -> CGPoint in
//            return point(of: touch)
//        })
//    }
//    var allTouches: [UITouch] = []
    
    var touchEventCallback: ((Bool) -> ())?
    var touchPointEventCallback: ((CGPoint) -> ())?
    
    init() {
        super.init(frame: .zero)
    }
    
    func touchEvent(_ callback: @escaping (Bool) -> ()) {
        touchEventCallback = callback
    }
    
    func touchPointEvent(_ callback: @escaping (CGPoint) -> ()) {
        touchPointEventCallback = callback
    }
    
    func point(of touch: UITouch) -> CGPoint {
        let location = touch.location(in: self)
        let uv = CGPoint(x: location.x / bounds.width, y: location.y / bounds.height)
        let aspect = bounds.width / bounds.height
        let point = CGPoint(x: (uv.x - 0.5) * aspect, y: (uv.y - 0.5) * -1)
        return point
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        began(touches)
        moved(touches)
    }
    func began(_ touches: Set<UITouch>) {
        touch = true
//        for touch in touches {
//            allTouches.append(touch)
//        }
        touchEventCallback?(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moved(touches)
    }
    func moved(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchPoint = point(of: touch)
        force = touch.force / touch.maximumPossibleForce
        touchPointMain = touchPoint
        touchPointEventCallback?(touchPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        ended(touches)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        ended(touches)
    }
    func ended(_ touches: Set<UITouch>) {
        touch = false
        force = 0.0
        touchPointMain = nil
//        for touch in touches {
//            for (i, oldTouch) in allTouches.enumerated() {
//                if oldTouch == touch {
//                    allTouches.remove(at: i)
//                    break
//                }
//            }
//        }
        touchEventCallback?(false)
    }
    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        return false
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
