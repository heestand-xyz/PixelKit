//
//  Created by Anton Heestand on 2021-02-04.
//

import SwiftUI

import RenderKit

public protocol X {}

public protocol XContent: X, ViewRepresentable {}

struct Effect: Hashable {
    let type: EffectType
    let form: EffectForm
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        lhs.type == rhs.type
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

protocol EffectForm {
    func updateForm(pix: PIXEffect)
}

enum EffectType: Hashable {
    case single(PIXSingleEffectType)
    case merger(PIXMergerEffectType)
    case multi(PIXMultiEffectType)
    var name: String {
        switch self {
        case .single(let pixSingleEffectType):
            return pixSingleEffectType.name
        case .merger(let pixMergerEffect):
            return pixMergerEffect.name
        case .multi(let pixMultiEffect):
            return pixMultiEffect.name
        }
    }
    func pixEffect() -> PIXEffect {
        switch self {
        case .single(let pixSingleEffectType):
            return pixSingleEffectType.type.init()
        case .merger(let pixMergerEffect):
            return pixMergerEffect.type.init()
        case .multi(let pixMultiEffect):
            return pixMultiEffect.type.init()
        }
    }
}

private struct EffectEnvironmentKey: EnvironmentKey {
    static var defaultValue: [Effect] = []
}

extension EnvironmentValues {
    var effects: [Effect] {
        get { self[EffectEnvironmentKey.self] }
        set { self[EffectEnvironmentKey.self] = newValue }
    }
}

public protocol PX {
//    var object: PXObject { get }
    func animate(object: PXObject, transaction: Transaction)
}

struct PXStore {
    static var store: [String: PXObject] = [:]
}

public protocol PXOut: PX {}
public protocol PXOOutRep: PXOut, ViewRepresentable {}

public protocol PXIn: PX {
    associatedtype PXO: PXOut
    var inPx: PXO { get }
}

public protocol PXInAB: PX {
    associatedtype PXOA: PXOut
    associatedtype PXOB: PXOut
    var inPxA: PXOA { get }
    var inPxB: PXOB { get }
}

public protocol PXIns: PX {
    associatedtype PXO: PXOOutRep
    var inPxs: [PXO] { get }
}

public class PXObject {
    let pix: PIX
    var timer: Timer?
//    var update: ((Transaction, PX) -> ())?
    init(pix: PIX) {
        print("PX Object Init \(pix.name) < -- --- ---- -----")
        self.pix = pix
    }
}

public class PXObjectEffect: PXObject {
    var inputObject: PXObject?
}

public class PXObjectMergerEffect: PXObject {
    var inputObjectA: PXObject?
    var inputObjectB: PXObject?
}

public class PXObjectMultiEffect: PXObject {
    var inputObjects: [PXObject] = []
}

public class XObject {
    let pix: PIX
    var effectPixs: [Effect: PIXEffect] = [:]
    var timer: Timer?
    var update: ((Transaction, PX) -> ())?
    init(pix: PIX) {
        print("PX Object Init \(pix.name) <<< --- --- ---")
        self.pix = pix
    }
}

@resultBuilder
public struct PXBuilder {
    public static func buildBlock<PXO: PXOOutRep>(_ components: PXO...) -> [PXO] {
        components
    }
}
//    public static func buildBlock<A: PXOOutRep>(_ a: A) -> A {
//        (a)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep>(_ a: A, _ b: B) -> (A, B) {
//        (a, b)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep>(_ a: A, _ b: B, _ c: C) -> (A, B, C) {
//        (a, b, c)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D) -> (A, B, C, D) {
//        (a, b, c, d)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> (A, B, C, D, E) {
//        (a, b, c, d, e)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep, F: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> (A, B, C, D, E, F) {
//        (a, b, c, d, e, f)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep, F: PXOOutRep, G: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> (A, B, C, D, E, F, G) {
//        (a, b, c, d, e, f, g)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep, F: PXOOutRep, G: PXOOutRep, H: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> (A, B, C, D, E, F, G, H) {
//        (a, b, c, d, e, f, g, h)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep, F: PXOOutRep, G: PXOOutRep, H: PXOOutRep, I: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> (A, B, C, D, E, F, G, H, I) {
//        (a, b, c, d, e, f, g, h, i)
//    }
//    public static func buildBlock<A: PXOOutRep, B: PXOOutRep, C: PXOOutRep, D: PXOOutRep, E: PXOOutRep, F: PXOOutRep, G: PXOOutRep, H: PXOOutRep, I: PXOOutRep, J: PXOOutRep>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> (A, B, C, D, E, F, G, H, I, J) {
//        (a, b, c, d, e, f, g, h, i, j)
//    }


class PXObjectExtractor {
    var object: PXObject?
}

private struct PXObjectEnvironmentKey: EnvironmentKey {
    static var defaultValue: PXObjectExtractor = PXObjectExtractor()
}

extension EnvironmentValues {
    var pxObjectExtractor: PXObjectExtractor {
        get { self[PXObjectEnvironmentKey.self] }
        set { self[PXObjectEnvironmentKey.self] = newValue }
    }
}

struct PXObjectExtractorView<PXO: PXOOutRep>: View {
    
    @Environment(\.pxObjectExtractor) var pxObjectExtractor: PXObjectExtractor
    
    var pxo: PXO
    @Binding var object: PXObject?
    
    var body: some View {
        pxo
            .environment(\.pxObjectExtractor, pxObjectExtractor)
            .onAppear {
                print("Extractor >> > >> > >> Appear", pxObjectExtractor.object?.pix.name ?? "nil")
                object = pxObjectExtractor.object
            }
    }
}


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
