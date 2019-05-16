//
//  PIXProtocols.swift
//  PixelKit
//
//  Created by Hexagons on 2018-07-26.
//  Open Source - MIT License
//

import CoreGraphics

public protocol PIXDelegate: class {
//    func pixResChanged(_ pix: PIX, to res: PIX.Res)
    func pixDidRender(_ pix: PIX)
}

public protocol PIXIn {}
public protocol PIXOut {}

public protocol PIXInSingle: PIXIn {
    var inPix: (PIX & PIXOut)? { get set }
}
public protocol PIXInMerger: PIXIn {
    var inPixA: (PIX & PIXOut)? { get set }
    var inPixB: (PIX & PIXOut)? { get set }
}
public protocol PIXInMulti: PIXIn {
    var inPixs: [PIX & PIXOut] { get set }
}

protocol PIXInIO: PIXIn {
    var pixInList: [PIX & PIXOut] { get set }
    var connectedIn: Bool { get }
}
protocol PIXOutIO: PIXOut {
//    var pixOutPathList: PIX.WeakOutPaths { get set }
    var pixOutPathList: [PIX.OutPath] { get set }
    var connectedOut: Bool { get }
}

protocol PIXMetal {
    var metalFileName: String { get }
    var metalCode: String? { get }
    var metalUniforms: [MetalUniform] { get }
}
