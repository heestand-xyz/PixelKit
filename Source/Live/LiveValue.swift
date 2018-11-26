//
//  LiveValue.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

protocol LiveValue {
//    associatedtype LiveValueType
    //    var futureValue: () -> (CGFloat) { get set }
    //    var value: CGFloat { get }
    
//    var pxv: LiveValueType { mutating get }
    var pxvIsNew: Bool { get }
//    var pxvCache: LiveValueType? { get set }
    
}
