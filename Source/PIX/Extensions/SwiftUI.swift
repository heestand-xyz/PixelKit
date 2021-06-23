//
//  SwiftUI.swift
//  
//
//  Created by Anton Heestand on 2021-01-15.
//

import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftUI

#if os(macOS)
public typealias UINSView = NSView
#else
public typealias UINSView = UIView
#endif

#if canImport(SwiftUI)
#if os(macOS)
public typealias UINSViewController = NSViewController
public typealias UINSHostingView = NSHostingView
public typealias UINSViewRepresentable = NSViewRepresentable
#else
public typealias UINSViewController = UIViewController
public typealias UINSHostingView = UIHostingController
public typealias UINSViewRepresentable = UIViewRepresentable
#endif
#endif

public protocol ViewRepresentable: UINSViewRepresentable {
    associatedtype V: UINSView
    func makeView(context: Self.Context) -> V
    func updateView(_ view: V, context: Self.Context)
}

#if os(macOS)
extension ViewRepresentable {
    public func makeNSView(context: Self.Context) -> V {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: V, context: Self.Context) {
        updateView(nsView, context: context)
    }
}
#else
extension ViewRepresentable {
    public func makeUIView(context: Self.Context) -> V {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: V, context: Self.Context) {
        updateView(uiView, context: context)
    }
}
#endif

#if os(macOS)
extension NSHostingView {
    var view: NSView? {
        self
    }
}
#endif

public protocol PIXViewable: UINSViewRepresentable {
    var pixView: PIXView! { get }
}

extension PIXViewable {
    
    public func makeView(context: Context) -> PIXView {
        pixView
    }
    public func updateView(_ pixView: PIXView, context: Context) {
        guard let pix: PIX = pixView.pix else { return }
        pix.render()
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> PIXView {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: PIXView, context: Context) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: Context) -> PIXView {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: PIXView, context: Context) {
        updateView(uiView, context: context)
    }
    #endif
    
}
