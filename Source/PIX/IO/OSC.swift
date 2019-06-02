//
//  OSC.swift
//  PixelKit
//
//  Created by Hexagons on 2019-06-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import OSCKit

public class OSC: NSObject, OSCServerDelegate {
    
    public static let main = OSC()
    
    public var port: Int = 10_000
    
    var server: OSCServer {
        didSet {
            server.listen(port)
        }
    }
    
    public var firstAny: CGFloat?
    public var list: [String: CGFloat] = [:]
    
    public var log: Bool = false
    
    struct Listener {
        let address: String
        let callback: (CGFloat) -> ()
    }
    var listeners: [Listener] = []

    override init() {
        
        server = OSCServer()
        
        super.init()
        
        server.delegate = self
        server.listen(port)
        
    }
    
    public func handle(_ message: OSCMessage!) {
        guard var address = message.address else { return }
        address = address.replacingOccurrences(of: "/", with: "")
        guard let value = message.arguments[0] as? CGFloat else { return }
        if address != "_samplerate" {
            firstAny = value
        }
        list[address] = value
        for listener in listeners {
            if address == listener.address {
                listener.callback(value)
            }
        }
        if self.log { print("OSC:", address, value) }
    }
    
    public func listen(to address: String, callback: @escaping (CGFloat) -> ()) {
        listeners.append(Listener(address: address, callback: callback))
    }
    
}
