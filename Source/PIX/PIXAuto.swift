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

public protocol AutoFloatProperty: AutoProperty {
    func get() -> LiveFloat
    func set(_ value: LiveFloat)
}

public protocol AutoIntProperty: AutoProperty {
    func get() -> LiveInt
    func set(_ value: LiveInt)
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
