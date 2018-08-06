//
//  PIXProtocols.swift
//  Hexagon Pixel Engine
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

protocol PIXable {
    var kind: HxPxE.PIXKind { get }
}

public protocol PIXIn {}
public protocol PIXOut {
    var outPixs: [PIX & PIXIn] { get }
}

public protocol PIXInSingle: PIXIn {
    var inPix: (PIX & PIXOut)? { get set } // weak?
}
public protocol PIXInMerger: PIXIn {
    var inPixA: (PIX & PIXOut)? { get set } // weak?
    var inPixB: (PIX & PIXOut)? { get set } // weak?
}
public protocol PIXInMulti: PIXIn {
    var inPixs: [PIX & PIXOut] { get set } // weak?
}


