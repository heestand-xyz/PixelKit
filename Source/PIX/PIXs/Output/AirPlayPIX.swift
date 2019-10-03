//
//  AirPlayPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2017-12-09.
//  Open Source - MIT License
//

import UIKit

public class AirPlayPIX: NODEOutput {
    
    // MARK: - Private Properties
    
    public var isConnected: Bool
    public var connectionCallback: ((Bool) -> ())?
    
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
        
        name = "airPlay"
        
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
        pixelKit.logger.log(node: self, .info, nil, slug + " " + message)
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
        connectionCallback?(true)
        
    }
    
    func disconnectAirPlay() {
        
        view.removeFromSuperview()
        
        window?.isHidden = true
        window = nil
        
        isConnected = false
        connectionCallback?(false)
        
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
