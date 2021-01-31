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
public typealias MultiView = NSView
#else
public typealias MultiView = UIView
#endif

#if os(macOS)
public typealias MultiViewController = NSViewController
public typealias MultiHostingView = NSHostingView
public typealias MultiViewRepresentable = NSViewRepresentable
#else
public typealias MultiViewController = UIViewController
public typealias MultiHostingView = UIHostingController
public typealias MultiViewRepresentable = UIViewRepresentable
#endif


protocol BodyViewRepresentable: MultiViewRepresentable {
    var bodyView: MultiView { get }
}

extension BodyViewRepresentable {
    
    public func makeView(context: Context) -> MultiView {
        bodyView
    }
    public func updateView(_ view: MultiView, context: Context) {
        print("<<< PixelKit SwiftUI Update >>>")
    }
    
    #if os(macOS)
    public func makeNSView(context: Context) -> MultiView {
        makeView(context: context)
    }
    public func updateNSView(_ nsView: MultiView, context: Context) {
        updateView(nsView, context: context)
    }
    #else
    public func makeUIView(context: Context) -> MultiView {
        makeView(context: context)
    }
    public func updateUIView(_ uiView: MultiView, context: Context) {
        updateView(uiView, context: context)
    }
    #endif
    
}
