//
//  PIXProtocols.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public protocol PIXDelegate: class {
    func pixWillRender(_ pix: PIX)
    func pixDidRender(_ pix: PIX)
}

protocol PIXofaKind {
    var kind: PIX.Kind { get }
}

public protocol PIXIn {}
public protocol PIXOut {}

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

protocol PIXInIO: PIXIn {
    var pixInList: [PIX & PIXOut] { get set }
    var connectedIn: Bool { get }
}
protocol PIXOutIO: PIXOut {
    var pixOutPathList: [PIX.OutPath] { get set }
    var connectedOut: Bool { get }
}
