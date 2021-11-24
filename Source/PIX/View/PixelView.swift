//
//  PixelView.swift
//  
//
//  Created by Anton Heestand on 2021-06-20.
//

import SwiftUI

@available(*, deprecated, renamed: "PixelViewRepresentable")
typealias PixelView = PixelViewRepresentable

#if os(macOS)

public struct PixelViewRepresentable: NSViewRepresentable {
    
    private let pix: PIX
    
    public init(pix: PIX) {
        self.pix = pix
    }
    
    public func makeNSView(context: Context) -> PIXView {
        pix.pixView
    }
    
    public func updateNSView(_ pixView: PIXView, context: Context) {}
}

#else

public struct PixelViewRepresentable: UIViewRepresentable {
    
    private let pix: PIX
    
    public init(pix: PIX) {
        self.pix = pix
    }
    
    public func makeUIView(context: Context) -> PIXView {
        pix.pixView
    }
    
    public func updateUIView(_ pixView: PIXView, context: Context) {}
}

#endif
