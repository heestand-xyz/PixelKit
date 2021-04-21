//
//  AirPlayPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2017-12-09.
//  Open Source - MIT License
//

#if os(iOS)

import UIKit
import RenderKit

final public class AirPlayPIX: PIXOutput, PIXViewable, ObservableObject {
    
    // MARK: - Private Properties
    
    public var isConnected: Bool
    public var connectionCallback: ((Bool) -> ())?
    
    var window: UIWindow?
    var queueConnect: Bool
    
    var tempView: UIView?
    
    let nilPix: NilPIX
    
    // MARK: - Life Cycle
    
    public required init() {
        
        isConnected = false
        window = nil
        queueConnect = false
        
        nilPix = NilPIX()
        
        super.init(name: "AirPlay", typeName: "pix-output-air-play")
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenConnect), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDisconnect), name: UIScreen.didDisconnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        log()
        
        name = "airPlay"
        
        check()
        
    }
    
    override func connected() {
        super.connected()
        #if DEBUG
        print("AirPlayDebug connected input", input != nil)
        #endif
        nilPix.input = input
        if let bounds: CGRect = window?.screen.bounds {
            addAirPlayView(bounds: bounds)
        }
    }
    
    override func disconnected() {
        super.disconnected()
        #if DEBUG
        print("AirPlayDebug disconnected")
        #endif
        nilPix.input = nil
        removeAirPlayView()
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
        #if DEBUG
        print("AirPlayDebug log \(message)")
        #endif
    }
    
    func addAirPlayView(bounds: CGRect) {
        #if DEBUG
        print("AirPlayDebug", "addAirPlayView")
        #endif
        nilPix.view.frame = bounds
        window?.addSubview(nilPix.view)
    }
    
    func connectAirPlay(screen: UIScreen) {
        #if DEBUG
        print("AirPlayDebug", "connectAirPlay")
        #endif
        
        window = UIWindow(frame: screen.bounds)
        window!.screen = screen
        
        if connectedIn {
            addAirPlayView(bounds: screen.bounds)
        }
        
        window!.isHidden = false
        
        isConnected = true
        connectionCallback?(true)
        
    }
    
    func removeAirPlayView() {
        nilPix.view.removeFromSuperview()
    }
    
    func disconnectAirPlay() {
        #if DEBUG
        print("AirPlayDebug", "disconnectAirPlay")
        #endif
        
        removeAirPlayView()
        
        window?.isHidden = true
        window = nil
        
        isConnected = false
        connectionCallback?(false)
        
    }
    
    @objc func screenConnect(sender: NSNotification) {
        #if DEBUG
        print("AirPlayDebug", "screenConnect", "isConnected:\(isConnected)", "appState:\(UIApplication.shared.applicationState == .active)")
        #endif
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
        #if DEBUG
        print("AirPlayDebug", "screenDisconnect", "isConnected:\(isConnected)")
        #endif
        if isConnected {
            disconnectAirPlay()
        }
        log()
    }
    
    @objc func appActive() {
        #if DEBUG
        print("AirPlayDebug", "appActive", "queueConnect:\(queueConnect)")
        #endif
        if queueConnect {
            let second_screen = UIScreen.screens[1]
            connectAirPlay(screen: second_screen)
            log()
            queueConnect = false
        }
    }
    
    func check() {
        #if DEBUG
        print("AirPlayDebug", "check", "isConnected:\(isConnected)")
        #endif
        if !isConnected {
            if UIScreen.screens.count > 1 {
                let second_screen = UIScreen.screens[1]
                connectAirPlay(screen: second_screen)
                log()
            }
        }
    }
    
    func disconnect() {
        #if DEBUG
        print("AirPlayDebug", "disconnect", "isConnected:\(isConnected)")
        #endif
        if isConnected {
            disconnectAirPlay()
        }
        log()
    }
    
    public override func destroy() {
        super.destroy()
        disconnect()
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}

public extension NODEOut {
    
    func pixAirPlay() -> AirPlayPIX {
        let airPlayPix = AirPlayPIX()
        airPlayPix.name = ":airplay:"
        airPlayPix.input = self as? PIX & NODEOut
        return airPlayPix
    }
    
}

#endif
