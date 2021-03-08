//
//  PIXContent.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

import RenderKit
import SwiftUI

open class PIXContent: PIX, NODEContent, NODEOutIO {
    
    public var outputPathList: [NODEOutPath] = []
    public var connectedOut: Bool { return !outputPathList.isEmpty }
    
}
