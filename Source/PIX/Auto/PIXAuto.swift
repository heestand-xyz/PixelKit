//
//  PIXAuto.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-04-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

//
//  cd ~/Documents/hexagons/all-of-pixelKit/pixelKit/Source/PIX
//  sourcery --sources .. --output . --templates . --watch
//

import Foundation
import LiveValues
import RenderKit

protocol PIXAutoParent {}
protocol PIXAuto {}

struct PIXAutoList {
    static func getAll() -> [PIX] {
        var pixs: [PIX] = []
        for auto in AutoPIXGenerator.allCases {
            let pix: PIX = auto.pixType.init(at: ._1024)
            pixs.append(pix)
        }
        for auto in AutoPIXSingleEffect.allCases {
            let pix: PIX = auto.pixType.init()
            pixs.append(pix)
        }
        for auto in AutoPIXMergerEffect.allCases {
            let pix: PIX = auto.pixType.init()
            pixs.append(pix)
        }
        for auto in AutoPIXMultiEffect.allCases {
            let pix: PIX = auto.pixType.init()
            pixs.append(pix)
        }
        return pixs
    }
}

public class AutoProperty<T> {
    public let name: String
    public var value: T {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (T)
    let setCallback: (T) -> ()
    init(name: String, getCallback: @escaping () -> (T), setCallback: @escaping (T) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveFloatProperty: AutoProperty<LiveFloat> {}
public class AutoLiveIntProperty: AutoProperty<LiveInt> {}
public class AutoLiveBoolProperty: AutoProperty<LiveBool> {}
public class AutoLiveColorProperty: AutoProperty<LiveColor> {}
public class AutoLivePointProperty: AutoProperty<LivePoint> {}
public class AutoLiveSizeProperty: AutoProperty<LiveSize> {}
public class AutoLiveRectProperty: AutoProperty<LiveRect> {}
public class AutoEnumProperty: AutoProperty<String> {
    public let cases: [String]
    init(name: String, cases: [String], getCallback: @escaping () -> (String), setCallback: @escaping (String) -> ()) {
        self.cases = cases
        super.init(name: name, getCallback: getCallback, setCallback: setCallback)
    }
}
public class AutoLiveVecProperty: AutoProperty<LiveVec> {}

public extension AutoPIXGenerator {

    func allAutoLivePropertyNames(for pix: PIXGenerator) -> [String] {
        var all: [String] = []
        all.append(contentsOf: autoLiveFloats(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveInts(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveBools(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveColors(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLivePoints(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveSizes(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveRects(for: pix).map({ $0.name }))
        return all
    }

    func allAutoPropertyNames(for pix: PIXGenerator) -> [String] {
        var all: [String] = []
        all.append(contentsOf: allAutoLivePropertyNames(for: pix))
        all.append(contentsOf: autoEnums(for: pix).map({ $0.name }))
        return all
    }
        
}

public extension AutoPIXMultiEffect {

    func allAutoLivePropertyNames(for pix: PIXMultiEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: autoLiveFloats(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveInts(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveBools(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveColors(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLivePoints(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveSizes(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveRects(for: pix).map({ $0.name }))
        return all
    }

    func allAutoPropertyNames(for pix: PIXMultiEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: allAutoLivePropertyNames(for: pix))
        all.append(contentsOf: autoEnums(for: pix).map({ $0.name }))
        return all
    }
        
}

public extension AutoPIXMergerEffect {

    func allAutoLivePropertyNames(for pix: PIXMergerEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: autoLiveFloats(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveInts(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveBools(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveColors(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLivePoints(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveSizes(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveRects(for: pix).map({ $0.name }))
        return all
    }

    func allAutoPropertyNames(for pix: PIXMergerEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: allAutoLivePropertyNames(for: pix))
        all.append(contentsOf: autoEnums(for: pix).map({ $0.name }))
        return all
    }
        
}

public extension AutoPIXSingleEffect {
    
    func allAutoLivePropertyNames(for pix: PIXSingleEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: autoLiveFloats(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveInts(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveBools(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveColors(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLivePoints(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveSizes(for: pix).map({ $0.name }))
        all.append(contentsOf: autoLiveRects(for: pix).map({ $0.name }))
        return all
    }
    
    func allAutoPropertyNames(for pix: PIXSingleEffect) -> [String] {
        var all: [String] = []
        all.append(contentsOf: allAutoLivePropertyNames(for: pix))
        all.append(contentsOf: autoEnums(for: pix).map({ $0.name }))
        return all
    }
    
    func allAutoLivePropertiesAsFloats(for pix: PIXSingleEffect) -> [AutoLiveFloatProperty] {
        var all: [AutoLiveFloatProperty] = []
        all.append(contentsOf: autoLiveFloats(for: pix))
        all.append(contentsOf: autoLiveInts(for: pix).map { auto -> AutoLiveFloatProperty in
            AutoLiveFloatProperty(name: auto.name, getCallback: {
                LiveFloat(auto.value)
            }) { value in
                auto.value = LiveInt(value)
            }
        })
        all.append(contentsOf: autoLiveBools(for: pix).map { auto -> AutoLiveFloatProperty in
            AutoLiveFloatProperty(name: auto.name, getCallback: {
                auto.value <?> 1.0 <=> 0.0
            }) { value in
                auto.value = value > 0.0
            }
        })
        for auto in autoLiveColors(for: pix) {
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-red", getCallback: { () -> (LiveFloat) in
                auto.value.r
            }, setCallback: { value in
                auto.value.r = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-green", getCallback: { () -> (LiveFloat) in
                auto.value.r
            }, setCallback: { value in
                auto.value.r = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-blue", getCallback: { () -> (LiveFloat) in
                auto.value.r
            }, setCallback: { value in
                auto.value.r = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-alpha", getCallback: { () -> (LiveFloat) in
                auto.value.a
            }, setCallback: { value in
                auto.value.a = value
            }))
        }
        for auto in autoLivePoints(for: pix) {
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-x", getCallback: { () -> (LiveFloat) in
                auto.value.x
            }, setCallback: { value in
                auto.value.x = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-y", getCallback: { () -> (LiveFloat) in
                auto.value.y
            }, setCallback: { value in
                auto.value.y = value
            }))
        }
        for auto in autoLiveSizes(for: pix) {
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-w", getCallback: { () -> (LiveFloat) in
                auto.value.w
            }, setCallback: { value in
                auto.value.w = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-h", getCallback: { () -> (LiveFloat) in
                auto.value.h
            }, setCallback: { value in
                auto.value.h = value
            }))
        }
        for auto in autoLiveRects(for: pix) {
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-x", getCallback: { () -> (LiveFloat) in
                auto.value.x
            }, setCallback: { value in
                auto.value.x = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-y", getCallback: { () -> (LiveFloat) in
                auto.value.y
            }, setCallback: { value in
                auto.value.y = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-w", getCallback: { () -> (LiveFloat) in
                auto.value.w
            }, setCallback: { value in
                auto.value.w = value
            }))
            all.append(AutoLiveFloatProperty(name: "\(auto.name)-h", getCallback: { () -> (LiveFloat) in
                auto.value.h
            }, setCallback: { value in
                auto.value.h = value
            }))
        }
        return all
    }
    
}
