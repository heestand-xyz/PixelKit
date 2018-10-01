//
//  PixelsLog.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension Pixels {
    
    public enum LogLevel: String {
        case none = ""
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
        case debug = "DEBUG"
        var index: Int {
            switch self {
            case .none: return 0
            case .info: return 1
            case .warning: return 2
            case .error: return 3
            case .fatal: return 4
            case .debug: return 5
            }
        }
    }
    
    public enum LogCategory: String {
        case pixels = "Pixels"
        case render = "Render"
        case texture = "Texture"
        case resource = "Resource"
        case generator = "Generator"
        case effect = "Effect"
        case connection = "Connection"
        case view = "View"
        case res = "Res"
        case fileIO = "File IO"
        case metal = "Metal"
    }
    
    public func log(prefix: String = "Pixels", pix: PIX? = nil, _ level: LogLevel, _ category: LogCategory?, _ message: String, loop: Bool = false, clean: Bool = false, e error: Error? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        
        var pixType: String?
        if let p = pix {
            pixType = String(String(describing: p).split(separator: ".").last ?? "")
        }
        
        var cleanLog = "\(prefix) "
        if pixType != nil {
            cleanLog += "\(pixType!) "
        }
        cleanLog += message
        if let e = error {
            cleanLog += " Error: \(e)"
        }
        
        guard level != .fatal else {
            fatalError(cleanLog)
        }
        
        if level.index > logLevel.index {
            return
        }
        
        if loop && logLoopLimitActive && frame > logLoopLimitFrameCount {
            if !logLoopLimitIndicated {
                print("Pixels Running...")
                logLoopLimitIndicated = true
            }
            return
        }
        
        if clean {
            print(cleanLog)
            return
        }
        
        // MARK: Log List
        
        var logList: [String] = []
        
        var padding = 0
        
        logList.append(prefix)
        
        #if DEBUG
        logList.append("#\(frame < 10 ? "0" : "")\(frame)")
        #else
        if level == .debug { return }
        #endif
        
        var tc = 0
        if logTime {
            let t = Date()
            let df = DateFormatter()
            let f = "HH:mm:ss.SSS"
            tc = f.count + 2
            df.dateFormat = f
            let ts = df.string(from: t)
            logList.append(ts)
        }
        
        logList.append(level.rawValue)
        
        var ext = 0
        if logExtra {
            ext += 5
            if level == .warning {
                logList.append("⚠️"); ext -= 1
            } else if level == .error {
                logList.append("❌"); ext -= 1
            }
        }
        
        if logPadding { padding += 20; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if pix != nil && pixType != nil {
            let nr = linkIndex(of: pix!)
            let nrstr = nr != nil ? "\(nr! + 1)" : "#"
            logList.append("[\(nrstr)] \(pixType!)")
        }
        
        if logPadding { padding += 30; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if let pixName = pix?.name {
            logList.append("\"\(pixName)\"")
        }
        
        if logPadding { padding += 30; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if let c = category {
            logList.append(c.rawValue)
        }
        
        if logPadding { padding += 20; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        else { logList.append(">>>") }
        
        logList.append(message)
        
        if let e = error {
            logList.append("Error: \"\(e)\"")
        }
        
        if logPadding { padding += 50; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        else { logList.append("<<<") }
        
        #if DEBUG
        let fileName = file.split(separator: "/").last!
        logList.append("\(fileName):\(function):\(line)")
        #endif
        
        var log = ""
        for (i, subLog) in logList.enumerated() {
            if i > 0 { log += " " }
            log += subLog
        }
        
        print(log)
        
    }
    
    func logLength(_ logList: [String]) -> Int {
        var length = -1
        for log in logList {
            length += log.count + 1
        }
        return length
    }
    
    func spaces(_ count: Int) -> String {
        guard count > 0 else { return "" }
        var spaces = ""
        for _ in 0..<count {
            spaces += " "
        }
        return spaces
    }
    
}
