//
//  PIXConvenience.swift
//  Pixels
//
//  Created by Hexagons on 2018-11-25.
//  Copyright © 2018 Hexagons. All rights reserved.
//

extension PIXOut {
    
    func rm(pureColors: [PIX.Color.Pure], as chanName: String) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "\(chanName):channelMix"
        channelMixPix.inPix = self as? PIX & PIXOut
        for pureColor in pureColors {
            switch pureColor {
            case .red: channelMixPix.red = .clear
            case .green: channelMixPix.green = .clear
            case .blue: channelMixPix.blue = .clear
            default: break
            }
        }
        return channelMixPix
    }
    
    func only(pureColor: PIX.Color.Pure, as chanName: String) -> ChannelMixPIX {
        let channelMixPix = ChannelMixPIX()
        channelMixPix.name = "\(chanName):channelMix"
        channelMixPix.inPix = self as? PIX & PIXOut
        channelMixPix.red = pureColor.color
        channelMixPix.green = pureColor.color
        channelMixPix.blue = pureColor.color
        return channelMixPix
    }
    
}

public extension PIXOut {
    
    var _r: ChannelMixPIX { return rm(pureColors: [.green, .blue], as: "r") }
    var _y: ChannelMixPIX { return rm(pureColors: [.blue], as: "y") }
    var _g: ChannelMixPIX { return rm(pureColors: [.red, .blue], as: "g") }
    var _c: ChannelMixPIX { return rm(pureColors: [.red], as: "c") }
    var _b: ChannelMixPIX { return rm(pureColors: [.red, .green], as: "b") }
    var _m: ChannelMixPIX { return rm(pureColors: [.green], as: "m") }
    
    var _rw: ChannelMixPIX { return only(pureColor: .red, as: "rw") }
    var _gw: ChannelMixPIX { return only(pureColor: .green, as: "gw") }
    var _bw: ChannelMixPIX { return only(pureColor: .blue, as: "bw") }
    
}
