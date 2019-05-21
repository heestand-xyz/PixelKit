//
//  Links.swift
//  PixelKit
//
//  Created by Anton Heestand on 2019-05-16.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

public extension PIX {
    
    public class Link {
        /*weak*/ var pix: PIX?
        init(pix: PIX) {
            self.pix = pix
        }
    }
    
    public struct Links: Collection {
        private var links: [Link] = []
        init(_ pixs: [PIX]) {
            links = pixs.map { Link(pix: $0) }
        }
        public var startIndex: Int { return links.startIndex }
        public var endIndex: Int { return links.endIndex }
        public subscript(_ index: Int) -> PIX? {
            return links[index].pix
        }
        public func index(after idx: Int) -> Int {
            return links.index(after: idx)
        }
        public mutating func append(_ pix: PIX) {
            links.append(Link(pix: pix))
        }
        public mutating func remove(_ pix: PIX) {
            for (i, link) in links.enumerated() {
                if link.pix != nil && link.pix! == pix {
                    links.remove(at: i)
                    break
                }
            }
        }
    }
    
}
