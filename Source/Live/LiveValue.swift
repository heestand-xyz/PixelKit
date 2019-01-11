//
//  LiveValue.swift
//  Pixels
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation

protocol LiveValue {
//    associatedtype LiveValueType
    //    var futureValue: () -> (CGFloat) { get set }
    //    var value: CGFloat { get }
    
//    var uniform: LiveValueType { mutating get }
    var uniformIsNew: Bool { get }
//    var uniformCache: LiveValueType? { get set }
    
}
