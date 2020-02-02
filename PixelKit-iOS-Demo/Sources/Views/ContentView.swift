//
//  ContentView.swift
//  PixelKit-iOS-Demo
//
//  Created by Anton Heestand on 2020-01-20.
//  Copyright © 2020 Hexagons. All rights reserved.
//

import SwiftUI
import RenderKit

struct ContentView: View {
    @EnvironmentObject var main: Main
    var body: some View {
        VStack {
            RepView(view: main.finalView)
            NODERepView(node: main.finalPix)
        }
    }
}

struct RepView: UIViewRepresentable {
    let view: UIView
    func makeUIView(context: Self.Context) -> UIView { view }
    func updateUIView(_ uiView: UIView, context: Self.Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Main())
    }
}
