//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit

protocol PX {}

struct PXHelper {
    
    static func animate(animation: Animation, timer: inout Timer?, loop: @escaping (CGFloat) -> ()) {
        
        func extract(_ name: String, in text: String) -> String? {
            if text.contains("\(name): ") {
                if let subText: String.SubSequence = text.components(separatedBy: "\(name): ").last?
                    .split(separator: ")").first?
                    .split(separator: ",").first {
                    return String(subText)
                }
            }
            return nil
        }
        
        func extract(_ name: String, in text: String) -> Double? {
            if let valueText: String = extract(name, in: text) {
                if let value: Double = Double(valueText) {
                    return value
                }
            }
            return nil
        }
        
        let duration: Double = extract("duration", in: animation.description) ?? 0.0
        let bx: Double = extract("bx", in: animation.description) ?? 1.0
        
        let startTime: Date = .init()
        let interval: Double = 1.0 / Double(PixelKit.main.render.fpsMax)
        
        timer?.invalidate()
        
        enum Ease {
            case linear
            case easeIn
            case easeOut
            case easeInOut
        }
        var ease: Ease = .linear
        if bx == 3.0 {
            ease = .linear
        } else if bx < 0.0 {
            ease = .easeInOut
        } else if bx < 1.0 {
            ease = .easeIn
        } else if bx > 1.0 {
            ease = .easeOut
        }
        
        timer = Timer(timeInterval: interval, repeats: true) { timer in
            let rawFraction: CGFloat = CGFloat(-startTime.timeIntervalSinceNow / duration)
            var fraction: CGFloat = rawFraction
            if animation == .easeIn(duration: 0.0) {
                print("Aa")
                fraction = cos(-.pi + fraction * .pi / 2)
            }
            switch ease {
            case .easeIn:
                fraction = cos(-.pi + fraction * .pi / 2) + 1.0
            case .easeOut:
                fraction = cos(-.pi / 2 + fraction * .pi / 2)
            case .easeInOut:
                fraction = cos(.pi + fraction * .pi) / 2.0 + 0.5
            case .linear:
                break
            }
            if fraction > 1.0 {
                fraction = 1.0
            }
            loop(fraction)
            if rawFraction >= 1.0 {
                timer.invalidate()
            }
        }
        
        RunLoop.current.add(timer!, forMode: .common)
        
    }

    static func motion<F: Floatable, Pix: PIX, Px: PX>(pxKeyPath: KeyPath<Px, F>,
                                                pixKeyPath: WritableKeyPath<Pix, F>,
                                                px: Px,
                                                pix: Pix,
                                                at fraction: CGFloat) {
        let oldValue: F = pix[keyPath: pixKeyPath]
        let newValue: F = px[keyPath: pxKeyPath]
        guard newValue.floats != oldValue.floats else { return }
        var pix: Pix = pix
        let floats: [CGFloat] = zip(oldValue.floats, newValue.floats)
            .map { (current, new) in
                current * (1.0 - fraction) + new * fraction
            }
        let value: F = F(floats: floats)
        pix[keyPath: pixKeyPath] = value
    }
    
}
