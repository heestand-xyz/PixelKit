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
    
    var firstAny: CGFloat?
    var firstAnyRaw: Int?
    
    var list: [String: CGFloat?] = [:]
    var listRaw: [String: Int?] = [:]

    public var log: Bool = true

    init() {
        
        MIDIAssistant.shared.listenToDevice(0)
        
        MIDIAssistant.shared.listenToMIDI.append { address, value in
            if self.log { print("MIDI:", address, value ?? 0) }
            let floatVal = value != nil ? CGFloat(value!) / 127.0 : nil
            self.firstAny = floatVal
            self.list[address] = floatVal
            let intVal = value != nil ? Int(value!) : nil
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
    
}

