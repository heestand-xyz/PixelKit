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

protocol PIXRes {
    var res: PIX.Res { get set }
    init(res: PIX.Res)
}


#if canImport(SwiftUI)

@available(iOS 13.0.0, *)
public protocol UIPIX {
    var pix: PIX { get }
}
public protocol UIPIXSingleEffect: UIPIX {
    var inPix: PIX & PIXOut { get }
}
public protocol UIPIXMergerEffect: UIPIX {
    var inPixA: PIX & PIXOut { get }
    var inPixB: PIX & PIXOut { get }
}
public protocol UIPIXMultiEffect: UIPIX {
    var inPixs: [PIX & PIXOut] { get }
}

@available(iOS 13.0.0, *)
@_functionBuilder
public struct UIPIXMergerEffectBuilder {
    public static func buildBlock(_ childA: UIPIX, _ childB: UIPIX) -> ((PIX & PIXOut)?, (PIX & PIXOut)?) {
        return (childA.pix as? PIX & PIXOut, childB.pix as? PIX & PIXOut)
    }
}

@available(iOS 13.0.0, *)
@_functionBuilder
public struct UIPIXMultiEffectBuilder {
    public static func buildBlock(_ children: UIPIX...) -> [PIX & PIXOut] {
        return children.compactMap { $0.pix as? PIX & PIXOut }
    }
}

#endif
