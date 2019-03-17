//
//  MIDIAssistant.swift
//  Pixel Nodes
//
//  Created by Hexagons on 2018-01-09.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreMIDI

class MIDIAssistant {
    
    static let shared = MIDIAssistant()
    
    var device: (index: Int, port: MIDIPortRef, src: MIDIEndpointRef)?
    var addresses: [String]
    
    var listenToAddesses: [(() -> ())]
    var listenToMIDI: [((String, UInt8?) -> ())]

    init() {
        self.device = nil
        self.addresses = []
        self.listenToAddesses = []
        self.listenToMIDI = []
    }
    
    func gotMidi(address: String, value: UInt8?) {
        DispatchQueue.main.async {
            var address_exists = false
            for i_address in self.addresses {
                if i_address == address {
                    address_exists = true
                    break
                }
            }
            if !address_exists {
                self.addresses.append(address)
                for listenToAddess in self.listenToAddesses {
                    listenToAddess()
                }
            }
            for i_listenToMIDI in self.listenToMIDI {
                i_listenToMIDI(address, value)
            }
        }
    }
    
    func listenToDevice(_ device_index: Int) {
        
        let myMIDIReadProc: MIDIReadProc = { pktList, readProcRefCon, srcConnRefCon in
            
            let packetList: MIDIPacketList = pktList.pointee
            let _: MIDIEndpointRef = srcConnRefCon!.load(as: MIDIEndpointRef.self)
            
            var packet: MIDIPacket = packetList.packet
            for _ in 1...packetList.numPackets {
                let bytes = Mirror(reflecting: packet.data).children
                var dumpStr = ""
                var dumpVal: UInt8? = nil
                
                var i = packet.length
                for (j, attr) in bytes.enumerated() {
                    if j == 2 {
                        dumpVal = attr.value as? UInt8
                    } else if j == 1 {
                        dumpStr += String(format:"#%02X", attr.value as! UInt8)
                    }
                    
                    i -= 1
                    if (i <= 0)
                    {
                        break
                    }
                }
                MIDIAssistant.shared.gotMidi(address: dumpStr, value: dumpVal)
//                print(dumpStr)
                packet = MIDIPacketNext(&packet).pointee
            }
        }
        
        
        var midiClient: MIDIClientRef = 0
        var inPort: MIDIPortRef = 0
        var src: MIDIEndpointRef = MIDIGetSource(device_index)
        
        MIDIClientCreate("MidiPIXNodesClient" as CFString, nil, nil, &midiClient)
        MIDIInputPortCreate(midiClient, "MidiPIXNodes_InPort" as CFString, myMIDIReadProc, nil, &inPort)
        
        MIDIPortConnectSource(inPort, src, &src)
        
        self.device = (index: device_index, port: inPort, src: src)
        
    }
    
    func unlistenToDevice(_ device_index: Int) {
        if self.device != nil {
            if self.device!.index == device_index {
                MIDIPortDisconnectSource(self.device!.port, self.device!.src)
                self.device = nil
            }
        }
    }
    
    func getSourceNames() -> [String] {
        var names:[String] = [];
        let count: Int = MIDIGetNumberOfSources();
        for i in 0..<count {
            let endpoint: MIDIEndpointRef = MIDIGetSource(i);
            if (endpoint != 0) {
                names.append(getDisplayName(endpoint));
            }
        }
        return names;
    }
    
    func getDisplayName(_ obj: MIDIObjectRef) -> String {
        var param: Unmanaged<CFString>?
        var name: String = "Error"
        let err: OSStatus = MIDIObjectGetStringProperty(obj, kMIDIPropertyDisplayName, &param)
        if err == OSStatus(noErr) {
            name =  param!.takeRetainedValue() as String
        }
        return name
    }
    
}
