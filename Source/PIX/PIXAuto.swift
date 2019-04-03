//
//  PIXAuto.swift
//  Pixels
//
//  Created by Anton Heestand on 2019-04-03.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public protocol AutoProperty {
    var name: String { get }
}

public class AutoFloatProperty: AutoProperty {
    public let name: String
    let getCallback: () -> (LiveFloat)
    let setCallback: (LiveFloat) -> ()
    init(name: String, getCallback: @escaping () -> (LiveFloat), setCallback: @escaping (LiveFloat) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
    public func get() -> LiveFloat {
        return getCallback()
    }
    public func set(_ value: LiveFloat) {
        setCallback(value)
    }
}

public class AutoIntProperty: AutoProperty {
    public let name: String
    let getCallback: () -> (LiveInt)
    let setCallback: (LiveInt) -> ()
    init(name: String, getCallback: @escaping () -> (LiveInt), setCallback: @escaping (LiveInt) -> ()) {
        self.name = name
        self.getCallback = getCallback
        self.setCallback = setCallback
    }
    public func get() -> LiveInt {
        return getCallback()
    }
    public func set(_ value: LiveInt) {
        setCallback(value)
    }
}

public protocol AutoBoolProperty: AutoProperty {
    func get() -> LiveBool
    func set(_ value: LiveBool)
}

public protocol AutoColorProperty: AutoProperty {
    func get() -> LiveColor
    func set(_ value: LiveColor)
}

public protocol AutoPointProperty: AutoProperty {
    func get() -> LivePoint
    func set(_ value: LivePoint)
}

public protocol AutoSizeProperty: AutoProperty {
    func get() -> LiveSize
    func set(_ value: LiveSize)
}

public protocol AutoRectProperty: AutoProperty {
    func get() -> LiveRect
    func set(_ value: LiveRect)
}
