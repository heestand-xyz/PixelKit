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
        NODERepView(node: main.finalPix)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Main())
    }
}
