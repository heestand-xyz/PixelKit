//
//  NODEViewExtension.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-10-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import RenderKit

public class PIXView: NODEView {
    
    #if os(iOS)
    let liveTouchView: LiveTouchView
    #elseif os(macOS)
    public let liveMouseView: LiveMouseView
    #endif
    
    override init(with render: Render) {
        
        #if os(iOS)
        liveTouchView = LiveTouchView()
        #elseif os(macOS)
        liveMouseView = LiveMouseView()
        #endif
        
        super.init(with: render)
        
        #if os(iOS)
        addSubview(liveTouchView)
        #elseif os(macOS)
        addSubview(liveMouseView)
        #endif
        
        subAutoLayout()
        
    }
    
    func subAutoLayout() {
        
        #if os(iOS)
        liveTouchView.translatesAutoresizingMaskIntoConstraints = false
        liveTouchView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        liveTouchView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        liveTouchView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        liveTouchView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        #elseif os(macOS)
        liveMouseView.translatesAutoresizingMaskIntoConstraints = false
        liveMouseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        liveMouseView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        liveMouseView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        liveMouseView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        #endif

    }

    #if !os(tvOS)
    public func liveTouch(active: Bool) {
        #if os(iOS)
        liveTouchView.isUserInteractionEnabled = active
        #elseif os(macOS)
        // CHECK
//        liveMouseView.isUserInteractionEnabled = active
        #endif
    }
    #endif
    
    #if os(iOS)
    
    public func touchEvent(_ callback: @escaping (Bool) -> ()) {
        liveTouchView.touchEvent { touch in
            callback(touch)
        }
    }
    
    public func touchPointEvent(_ callback: @escaping (CGPoint) -> ()) {
        liveTouchView.touchPointEvent { point in
            callback(point)
        }
    }
    
    public func touchUVEvent(_ callback: @escaping (CGPoint) -> ()) {
        liveTouchView.touchPointEvent { point in
            guard self.boundsReady else { return }
            let aspect = self.bounds.width / self.bounds.height
            let uv = CGPoint(x: (point.x + aspect / 2) / aspect, y: point.y + 0.5)
            callback(uv)
        }
    }
    
    #elseif os(macOS)
    
    public func liveMouse(active: Bool) {
        liveMouseView.isHidden = !active
    }
    
    #endif
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
