//
//  PIXAuto.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

//
//  cd ~/Documents/hexagons/all-of-pixels/pixels/Source/PIX
//  sourcery --sources .. --output . --templates . --watch
//

import Foundation

protocol PIXAutoParent {}
protocol PIXAuto {}

public protocol AutoProperty {
    var name: String { get }
}

public class AutoLiveFloatProperty: AutoProperty {
    public let name: String
    public var value: LiveFloat {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveFloat)
    let setCallback: (LiveFloat) -> ()
    init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveIntProperty: AutoProperty {
    public let name: String
    public var value: LiveInt {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveInt)
    let setCallback: (LiveInt) -> ()
    init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveBoolProperty: AutoProperty {
    public let name: String
    public var value: LiveBool {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveBool)
    let setCallback: (LiveBool) -> ()
    init(name: String, getCallback: @escaping () -> (LiveBool), setCallback: @escaping (LiveBool) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveColorProperty: AutoProperty {
    public let name: String
    public var value: LiveColor {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveColor)
    let setCallback: (LiveColor) -> ()
    init(name: String, getCallback: @escaping () -> (LiveColor), setCallback: @escaping (LiveColor) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLivePointProperty: AutoProperty {
    public let name: String
    public var value: LivePoint {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LivePoint)
    let setCallback: (LivePoint) -> ()
    init(name: String, getCallback: @escaping () -> (LivePoint), setCallback: @escaping (LivePoint) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveSizeProperty: AutoProperty {
    public let name: String
    public var value: LiveSize {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveSize)
    let setCallback: (LiveSize) -> ()
    init(name: String, getCallback: @escaping () -> (LiveSize), setCallback: @escaping (LiveSize) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoLiveRectProperty: AutoProperty {
    public let name: String
    public var value: LiveRect {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (LiveRect)
    let setCallback: (LiveRect) -> ()
    init(name: String, getCallback: @escaping () -> (LiveRect), setCallback: @escaping (LiveRect) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}

public class AutoEnumProperty: AutoProperty {
    public let name: String
    public let cases: [String]
    public var value: String {
        get { return getCallback() }
        set { setCallback(newValue) }
    }
    let getCallback: () -> (String)
    let setCallback: (String) -> ()
    init(name: String, cases: [String], getCallback: @escaping () -> (String), setCallback: @escaping (String) -> ()) {
        self.name = name
        self.cases = cases
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
}
