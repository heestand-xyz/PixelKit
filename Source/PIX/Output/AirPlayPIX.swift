//
//  AirPlayPIX.swift
//  Pixels
//
//  Created by Hexagons on 2017-12-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

public class AirPlayPIX: PIXOutput {
    
    // MARK: - Private Properties
    
    var isConnected: Bool
    var window: UIWindow?
    var queueConnect: Bool
    
    // MARK: - Life Cycle
    
    override public init() {
        
        isConnected = false
        window = nil
        queueConnect = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenConnect), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDisconnect), name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        log()
        
    }
    
    // MARK:  Methods
    
    func log() {
        let slug = "AirPlay"
        let message: String
        if isConnected {
            message = "Connected."
        } else if UIScreen.screens.count > 1 {
            message = "Enabled."
        } else {
            message = "Not enabled (mirroring)."
        }
        pixels.log(pix: self, .info, nil, slug + " " + message)
    }
    
    func addAirPlayView(bounds: CGRect) {
        view.frame = bounds
        window?.addSubview(view)
    }
    
    func connectAirPlay(screen: UIScreen) {
        
        window = UIWindow(frame: screen.bounds)
        window?.screen = screen
        
        addAirPlayView(bounds: screen.bounds)
        
        window?.isHidden = false
        
        isConnected = true
        
    }
    
    func disconnectAirPlay() {
        
        view.removeFromSuperview()
        
        window?.isHidden = true
        window = nil
        
        isConnected = false
        
    }
    
    @objc func screenConnect(sender: NSNotification) {
        if !isConnected {
            if UIApplication.shared.applicationState == .active {
                let new_screen = sender.object as! UIScreen
                connectAirPlay(screen: new_screen)
            } else {
                queueConnect = true
            }
        }
        log()
    }
    
    @objc func screenDisconnect() {
        if isConnected {
            disconnectAirPlay()
        }
        log()
    }
    
    @objc func appActive() {
        if queueConnect {
            let second_screen = UIScreen.screens[1]
            connectAirPlay(screen: second_screen)
            log()
            queueConnect = false
        }
    }
    
    func check() {
        if !isConnected {
            if UIScreen.screens.count > 1 {
                let second_screen = UIScreen.screens[1]
                connectAirPlay(screen: second_screen)
                log()
            }
        }
    }
    
    func disconnect() {
        if isConnected {
            disconnectAirPlay()
        }
        log()
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
