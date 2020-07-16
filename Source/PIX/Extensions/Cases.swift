//
//  Cases.swift
//  
//
//  Created by Cappuccino on 2020-07-16.
//

import Foundation

fileprivate let badChars = CharacterSet.alphanumerics.inverted

public extension String {
    
    var camelToTitleCased: String {
        if self.count <= 1 {
            return self.uppercased()
        }
        let regex = try! NSRegularExpression(pattern: "(?=\\S)[A-Z]", options: [])
        let range = NSMakeRange(1, self.count - 1)
        var titlecased = regex.stringByReplacingMatches(in: self, range: range, withTemplate: " $0")
        for i in titlecased.indices {
            if i == titlecased.startIndex || titlecased[titlecased.index(before: i)] == " " {
                titlecased.replaceSubrange(i...i, with: String(titlecased[i]).uppercased())
            }
        }
        return titlecased
    }
    
    var lowercasingFirst: String {
        guard !isEmpty else { return "" }
        return String(first!).lowercased() + dropFirst()
    }
    var uppercasingFirst: String {
        guard !isEmpty else { return "" }
        return String(first!).uppercased() + dropFirst()
    }
    
    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = self.components(separatedBy: badChars)
        let first = String(describing: parts.first!).lowercasingFirst
        let rest = parts.dropFirst().map({String($0).uppercasingFirst})
        return ([first] + rest).joined(separator: "")
    }
    
    var camelToSnakeCased: String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return regex(pattern: acronymPattern, template: "$1_$2")?.regex(pattern: normalPattern, template: "$1_$2")?.lowercased() ?? lowercased()
    }
    
    var camelToSentenceCased: String {
        guard var result: String = regex(pattern: "([A-Z][a-z]+)", template: " $1")?.regex(pattern: "([A-Z]{2,})", template: " $1")?.regex(pattern: "\\s{2,}", template: " ") else { return "" }
        guard !result.isEmpty else { return "" }
        if result.first! == " " {
            result = "\(result.dropFirst())"
        }
        if result.first!.lowercased() == String(result.first!) {
            result = "\(result.first!.uppercased())\(result.dropFirst())"
        }
        return result
    }
    
    fileprivate func regex(pattern: String, template: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(location: 0, length: count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }
    
    var titleToSnakeCased: String {
        camelCased.camelToSnakeCased
    }
    
}
