//
//  Logger.swift
//  HxPxE
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

class Logger {
    
    static let main = Logger()
    
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
    }
    
    enum Category: String {
        case engine = "Engine"
        case render = "Render"
        case metalRender = "Metal Render"
        case resource = "Resource"
        case generator = "Generator"
        case effect = "Effect"
        case connection = "Connection"
        case view = "View"
        case res = "Res"
    }
    
    let loopFrameCountLimit = HxPxE.main.fpsMax
    
    func log(pix: PIX? = nil, _ level: Level, _ category: Category?, _ message: String, loop: Bool = false, e error: Error? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        
        if loop && HxPxE.main.frameIndex < loopFrameCountLimit {
            return
        }
        
        var logList: [String] = []
        
        logList.append("HxPxE")
        
        #if DEBUG
        logList.append("#\(HxPxE.main.frameIndex)")
        #else
        if [.debug, .info].contains(level) { return }
        #endif
        
        logList.append(level.rawValue)
        
        if let p = pix {
            logList.append(String(String(describing: p).split(separator: ".").last ?? ""))
        }
        
        if let c = category {
            logList.append(c.rawValue)
        }
        
        logList.append(">>>")
        
        logList.append(message)
        
        if let e = error {
            logList.append("Error: \"\(e.localizedDescription)\"")
        }
        
        logList.append("<<<")

        #if DEBUG
        let fileName = file.split(separator: "/").last!
        logList.append("\(fileName) \(function) \(line)")
        #endif
        
        var log = ""
        for (i, subLog) in logList.enumerated() {
            if i > 0 { log += " " }
            log += subLog
        }
        
        print(log)
        
        if level == .fatal {
            assert(false, message)
        }
        
    }
    
}
