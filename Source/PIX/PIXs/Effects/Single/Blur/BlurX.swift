//
//  Created by Anton Heestand on 2021-06-13.
//

import SwiftUI

@available(iOS 14.0, *)
public struct BlurX<Content: View>: View, X {
    
    @Environment(\.effects) var effects: [Effect]

    let content: () -> (Content)
    
    let radius: CGFloat
    
    var effect: Effect {
        print("X Effect Blur ~ ~ ~ ~ ~ ~ ~ ~")
        return Effect(type: .single(.blur), form: BlurForm(radius: radius))
    }
    
    public init(radius: CGFloat, content: @escaping () -> (Content)) {
        self.radius = radius
        self.content = content
    }
    
    public var body: some View {
        content()
//            .onChange(of: radius) { newValue in
//                print("X Change Blur - Radius:", newValue)
//            }
            .environment(\.effects, [effect] + effects)
    }
    
}

@available(iOS 14.0, *)
extension View {
    
    public func xBlur(radius: CGFloat) -> BlurX<Self> {
        BlurX(radius: radius) { self }
    }
}
