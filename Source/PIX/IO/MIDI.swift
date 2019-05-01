//
//  SignalContentMIDINode.swift
//  Pixel Nodes
//
//  Created by Hexagons on 2018-01-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class MIDI {
    
    public static let main = MIDI()
    
    public var firstAny: CGFloat?
    var firstAnyRaw: Int?
    
    public var list: [String: CGFloat] = [:]
    var listRaw: [String: Int] = [:]

    public var log: Bool = false
    
    struct Listener {
        let address: String
        let callback: (CGFloat) -> ()
    }
    var listeners: [Listener] = []

    init() {
        
        MIDIAssistant.shared.listenToDevice(0)
        
        MIDIAssistant.shared.listenToMIDI.append { address, value in
            if self.log { print("MIDI:", address, value ?? 0) }
            let floatVal = value != nil ? CGFloat(value!) / 127.0 : -1.0
            let intVal = value != nil ? Int(value!) : -1
            for listener in self.listeners {
                if address == listener.address {
                    if floatVal != self.list[address] {
                        listener.callback(floatVal)
                    }
                }
            }
            self.firstAny = floatVal
            self.list[address] = floatVal
            self.firstAnyRaw = intVal
            self.listRaw[address] = intVal
        }
        
    }
    
    func pick(device index: Int) {
//        if self.device_index != nil {
//            MIDIAssistant.shared.unlistenToDevice(self.device_index!)
//            self.device_index = nil
//        }
//        MIDIAssistant.shared.listenToDevice(index!)
//        self.device_index = index
    }
    
    public func listen(to address: String, callback: @escaping (CGFloat) -> ()) {
        listeners.append(MIDI.Listener(address: address, callback: callback))
    }
    
}

