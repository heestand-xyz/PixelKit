//
//  PixelsLog.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-16.
//  Open Source - MIT License
//

import Foundation

extension Pixels {
    
    public struct Log {
        public let signature: Signature
        public let prefix: String
        public let level: LogLevel
        public let category: LogCategory?
        public let time: Date
        public let codeRef: CodeRef
        public let pixRef: PIXRef?
        public let message: String
        public let error: Error?
        public let loop: Bool
    }
    
    public struct PIXRef {
        public let id: UUID
        public let name: String?
        public let type: String
        public let linkIndex: Int?
        init(for pix: PIX) {
            id = pix.id
            name = pix.name
            type = String(String(describing: pix).split(separator: ".").last ?? "")
            linkIndex = Pixels.main.linkIndex(of: pix)
        }
    }
    
    public struct CodeRef {
        public let file: String
        public let function: String
        public let line: Int
    }
    
    public enum LogLevel: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case fatal = "FATAL"
        case detail = "DETAIL"
        case debug = "DEBUG"
        public var index: Int {
            switch self {
            case .info: return 0
            case .warning: return 1
            case .error: return 2
            case .fatal: return 3
            case .detail: return 4
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
    
    public func logAll() {
        Pixels.main.logLoopLimitActive = false
        Pixels.main.logTime = true
        Pixels.main.logPadding = true
        Pixels.main.logSource = true
    }
    
    public func log(prefix: String = "Pixels", pix: PIX? = nil, _ level: LogLevel, _ category: LogCategory?, _ message: String, loop: Bool = false, clean: Bool = false, e error: Error? = nil, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        
        let time = Date()
        let pixRef = pix != nil ? PIXRef(for: pix!) : nil
        let codeRef = CodeRef(file: file, function: function, line: line)
        
        let log = Log(signature: signature, prefix: prefix, level: level, category: category, time: time, codeRef: codeRef, pixRef: pixRef, message: message, error: error, loop: loop)
        
        guard level != .fatal else {
            logCallback?(log)
            fatalError(formatClean(log: log))
        }
        
        guard logActive && level.index <= logLevel.index else {
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
            print(formatClean(log: log))
            logCallback?(log)
            return
        }
        
        #if !DEBUG
        if level == .debug {
            return
        }
        #endif
        
        print(format(log: log))
        
        logCallback?(log)
        
    }
    
    public func formatClean(log: Log) -> String {
        var cleanLog = "\(log.prefix) "
        if log.pixRef != nil {
            cleanLog += "\(log.pixRef!.type) "
        }
        cleanLog += log.message
        if let e = log.error {
            cleanLog += " Error: \(e)"
        }
        return cleanLog
    }
    
    public func format(log: Log) -> String {
        
        var logList: [String] = []
        
        var padding = 0
        
        logList.append(log.prefix)
        
        logList.append("#\(frame < 10 ? "0" : "")\(frame)")
        
        var tc = 0
        if logTime {
            let df = DateFormatter()
            let f = "HH:mm:ss.SSS"
            tc = f.count + 2
            df.dateFormat = f
            let ts = df.string(from: log.time)
            logList.append(ts)
        }
        
        logList.append(log.level.rawValue)
        
        var ext = 0
        if logExtra {
            ext += 5
            if log.level == .warning {
                logList.append("⚠️"); ext -= 1
            } else if log.level == .error {
                logList.append("❌"); ext -= 1
            }
        }
        
        if logPadding { padding += 20; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if let pixRef = log.pixRef {
            if let nr = pixRef.linkIndex {
                logList.append("[\(nr + 1)]")
            }
            logList.append(pixRef.type)
        }
        
        if logPadding { padding += 30; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if let pixRef = log.pixRef {
            if let pixName = pixRef.name {
                logList.append("\"\(pixName)\"")
            }
        }
        
        if logPadding { padding += 30; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        
        if let c = log.category {
            logList.append(c.rawValue)
        }
        
        if logPadding { padding += 20; logList.append(spaces(tc + ext + padding - logLength(logList))) }
        else { logList.append(">>>") }
        
        logList.append(log.message)
        
        if let e = log.error {
            logList.append("Error: \(e) LD: \"\(e.localizedDescription)\"")
        }
        
        if logSource {
            if logPadding { padding += 50; logList.append(spaces(tc + ext + padding - logLength(logList))) }
            else { logList.append("<<<") }
            let fileName = log.codeRef.file.split(separator: "/").last!
            logList.append("\(fileName):\(log.codeRef.function):\(log.codeRef.line)")
        }
        
        var log = ""
        for (i, subLog) in logList.enumerated() {
            if i > 0 { log += " " }
            log += subLog
        }
        
        return log
        
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
