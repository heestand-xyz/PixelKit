import CoreGraphics
import SwiftUI
import RenderKit

public struct CircleX: XContent {
    
    @Environment(\.effects) var effects: [Effect]

    let radius: CGFloat
    
    public init(radius: CGFloat) {
        self.radius = radius
    }
    
    public func makeView(context: Context) -> PIXView {
        print("X Make Circle <-=-=-=-=-=-=-=-=-=-=-=-=-")
        var pix: PIX & NODEOut = context.coordinator.pix as! CirclePIX
        for effect in effects {
            print("X Make Circle - Effect \"\(effect.type.name)\"")
            guard let effectPix: PIXSingleEffect = effect.type.pixEffect() as? PIXSingleEffect else { continue }
            effectPix.input = pix
            pix = effectPix
            context.coordinator.effectPixs[effect] = effectPix
        }
        return pix.pixView
    }
    
    public func updateView(_ view: PIXView, context: Context) {
        print("X Update Circle . . . . . . . . . .")
        let pix = context.coordinator.pix as! CirclePIX
        pix.radius = radius
        for effect in effects {
            print("X Update Circle - Effect \"\(effect.type.name)\"")
            guard let effectPix: PIXEffect = context.coordinator.effectPixs[effect] else { continue }
            effect.form.updateForm(pix: effectPix)
        }
    }
    
    public func makeCoordinator() -> XObject {
        XObject(pix: CirclePIX())
    }
}
