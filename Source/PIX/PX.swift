//
//  File.swift
//  
//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI
import RenderKit

public protocol PX: ViewRepresentable {
    var object: PXObject { get }
    func getPix() -> PIX
//    var pix: PIX { get }
}

public protocol PXOut: PX {}

protocol PXIn: PX {
    associatedtype PXB = PX
    var inPx: () -> (PXB) { get }
//    init(inPx: @escaping () -> (PXB))
}

public class PXObject: ObservableObject {
    let pix: PIX
    init(pix: PIX) {
        print(".. Object of \(pix.name)")
        self.pix = pix
    }
}

//extension PX {
//
//    func pixRender() -> some View {
//        PXRenderView()
//    }
//
//}

//struct PXRenderView: UINSViewRepresentable {
//
//    func makeUIView(context: Context) -> PIXView {
//
//    }
//
//    func updateUIView(_ uiView: PIXView, context: Context) {
//
//    }
//
//}


//class PXHub {
//
//    static let shared: PXHub = .init()
//
//    private var pixs: [PIX] = []
//
//    func add(pix: PIX) {
//        print(".. PXHub Add", pix.name, pix.id)
//        pixs.append(pix)
//    }
//
//    func pix(id: UUID) -> PIX? {
//        print(".. PXHub PIX", id)
//        return pixs.first(where: { $0.id == id })
//    }
//
//}

//class PXConnector {
//    static let shared: PXConnector = .init()
//    var waitList: [(pxOut: PXOut, pxIn: PXIn)] = []
//    var connectList: [(pxOut: PXOut, pixOut: PIX & NODEOut, pxIn: PXIn)] = []
//    func add(_ pxOut: PXOut, to pxIn: PXIn) {
//        print("PXConnector Add from \(type(of: pxOut)) to \(type(of: pxIn))")
//        waitList.append((pxOut: pxOut, pxIn: pxIn))
//    }
//    func check(pxOut: PXOut, pixOut: PIX & NODEOut) {
//        print("PXConnector Check \(type(of: pxOut))")
//        if let index: Int = waitList.firstIndex(where: { $0.pxOut.id == pxOut.id }) {
//            print("PXConnector Check Success")
//            let item = waitList[index]
//            waitList.remove(at: index)
//            connectList.append((pxOut: pxOut, pixOut: pixOut, pxIn: item.pxIn))
//        }
//    }
//    func fetch(pxIn: PXIn) -> (PIX & NODEOut)? {
//        print("PXConnector Fetch \(type(of: pxIn))")
//        if let index: Int = connectList.firstIndex(where: { $0.pxIn.id == pxIn.id }) {
//            print("PXConnector Fetch Success")
//            let item = connectList[index]
//            connectList.remove(at: index)
//            return item.pixOut
//        }
//        return nil
//    }
//}

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
