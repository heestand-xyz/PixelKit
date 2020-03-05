//
//  LiveMouseView.swift
//  PixelKit-macOS
//
//  Created by Anton Heestand on 2019-03-15.
//  Copyright © 2019 Hexagons. All rights reserved.
//

#if os(macOS) && !targetEnvironment(macCatalyst)

import AppKit

public class LiveMouseView: NSView {
    
    var mousePoint: CGPoint?
    var mouseLeft: Bool = false
    var mouseRight: Bool = false
    var mouseInView: Bool = false

    var trackingArea : NSTrackingArea?
    
    var mousePointCallbacks: [(CGPoint) -> ()] = []
    var mouseLeftCallbacks: [(Bool) -> ()] = []
    var mouseRightCallbacks: [(Bool) -> ()] = []
    var mouseInViewCallbacks: [(Bool) -> ()] = []
    
    public func listenToMousePoint(_ callback: @escaping (CGPoint) -> ()) {
        mousePointCallbacks.append(callback)
    }
    public func listenToMouseLeft(_ callback: @escaping (Bool) -> ()) {
        mouseLeftCallbacks.append(callback)
    }
    public func listenToMouseRight(_ callback: @escaping (Bool) -> ()) {
        mouseRightCallbacks.append(callback)
    }
    public func listenToMouseInView(_ callback: @escaping (Bool) -> ()) {
        mouseInViewCallbacks.append(callback)
    }
    
    override public func updateTrackingAreas() {
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
    
    override public func mouseMoved(with event: NSEvent) {
        moved(with: event)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        moved(with: event)
    }
    
    override public func rightMouseDragged(with event: NSEvent) {
        moved(with: event)
    }
    
    func moved(with event: NSEvent) {
        let point = convert(event.locationInWindow, to: self)
        let coord = getCoord(from: point)
        mousePoint = coord
        for mousePointCallback in mousePointCallbacks {
            mousePointCallback(coord)
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        mouseLeft = true
        for mouseLeftCallback in mouseLeftCallbacks {
            mouseLeftCallback(true)
        }
    }
    
    override public func mouseUp(with event: NSEvent) {
        mouseLeft = false
        for mouseLeftCallback in mouseLeftCallbacks {
            mouseLeftCallback(false)
        }
    }
    
    override public func rightMouseDown(with event: NSEvent) {
        mouseRight = true
        for mouseRightCallback in mouseRightCallbacks {
            mouseRightCallback(true)
        }
    }
    
    override public func rightMouseUp(with event: NSEvent) {
        mouseRight = false
        for mouseRightCallback in mouseRightCallbacks {
            mouseRightCallback(false)
        }
    }
    
    override public func mouseEntered(with event: NSEvent) {
        mouseInView = true
        for mouseInViewCallback in mouseInViewCallbacks {
            mouseInViewCallback(true)
        }
    }
    
    override public func mouseExited(with event: NSEvent) {
        mouseInView = false
        for mouseInViewCallback in mouseInViewCallbacks {
            mouseInViewCallback(false)
        }
    }
    
    func getCoord(from localPoint: CGPoint) -> CGPoint {
        let uv = CGPoint(x: localPoint.x / bounds.width, y: localPoint.y / bounds.height)
        let aspect = bounds.width / bounds.height
        let point = CGPoint(x: (uv.x - 0.5) * aspect, y: uv.y - 0.5)
        return point
    }
    
}

#endif
