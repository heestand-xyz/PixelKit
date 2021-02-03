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

#if os(macOS)
public typealias UINSViewController = NSViewController
public typealias UINSHostingView = NSHostingView
public typealias UINSViewRepresentable = NSViewRepresentable
#else
public typealias UINSViewController = UIViewController
public typealias UINSHostingView = UIHostingController
public typealias UINSViewRepresentable = UIViewRepresentable
#endif


public protocol BodyViewRepresentable: UINSViewRepresentable {
    var bodyView: UINSView { get }
}

extension BodyViewRepresentable {
    
    public func makeView(context: Context) -> UINSView {
        bodyView
    }
    public func updateView(_ view: UINSView, context: Context) {
        print("<<< PixelKit SwiftUI Update >>>")
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> UINSView {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: UINSView, context: Context) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: Context) -> UINSView {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: UINSView, context: Context) {
        updateView(uiView, context: context)
    }
    #endif
    
}
