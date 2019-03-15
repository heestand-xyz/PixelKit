//
//  LiveMouseView.swift
//  Pixels-macOS
//
//  Created by Anton Heestand on 2019-03-15.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import AppKit

class LiveMouseView: NSView {
    
    var mousePoint: CGPoint?
    var mouseLeft: Bool = false
    var mouseRight: Bool = false
    var mouseInView: Bool = false

    var trackingArea : NSTrackingArea?
    
    override func updateTrackingAreas() {
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .mouseMoved,
            .activeInKeyWindow
        ]
        trackingArea = NSTrackingArea(rect: bounds, options: options,
                                      owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }
    
    override func mouseMoved(with event: NSEvent) {
        moved(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        moved(with: event)
    }
    
    func moved(with event: NSEvent) {
        let point = convert(event.locationInWindow, to: self)
        let coord = getCoord(from: point)
        mousePoint = coord
    }
    
    override func mouseDown(with event: NSEvent) {
        mouseLeft = true
    }
    
    override func mouseUp(with event: NSEvent) {
        mouseLeft = false
    }
    
    override func rightMouseDown(with event: NSEvent) {
        mouseRight = true
    }
    
    override func rightMouseUp(with event: NSEvent) {
        mouseRight = false
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseInView = true
    }
    
    override func mouseExited(with event: NSEvent) {
        mouseInView = false
    }
    
    func getCoord(from localPoint: CGPoint) -> CGPoint {
        let uv = CGPoint(x: localPoint.x / bounds.width, y: localPoint.y / bounds.height)
        let aspect = bounds.width / bounds.height
        let point = CGPoint(x: (uv.x - 0.5) * aspect, y: uv.y - 0.5)
        return point
    }
    
}
