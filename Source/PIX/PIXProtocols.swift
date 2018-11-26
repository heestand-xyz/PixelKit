//
//  PIXProtocols.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public protocol PIXDelegate: class {
    func pixResChanged(_ pix: PIX, to res: PIX.Res)
    func pixDidRender(_ pix: PIX)
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

public class MetalUniform/*: Codable*/ {
    public let name: String
    public var value: CGFloat
    public init(name: String, value: CGFloat = 0.0) {
        self.name = name
        self.value = value
    }
}
protocol PIXMetal {
    var metalFileName: String { get }
    var metalCode: String? { get }
    var metalUniforms: [MetalUniform] { get }
}
