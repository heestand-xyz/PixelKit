//
//  Enum.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-11.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

public protocol EnumList : Hashable {}

public extension EnumList {
    
    public static func cases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
    
}
