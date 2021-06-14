//
//  Created by Anton Heestand on 2021-06-13.
//

import SwiftUI

public struct QuantizeX<Content: View>: View, X {
    
    @Environment(\.effects) var effects: [Effect]
    
    let content: () -> (Content)
    
    let fraction: CGFloat
    
    public init(fraction: CGFloat, content: @escaping () -> (Content)) {
        self.fraction = fraction
        self.content = content
    }
    
    public var body: some View {
        content()
            .environment(\.effects, [
                Effect(type: .single(.quantize), form: QuantizeForm(fraction: fraction))
            ] + effects)
    }
    
}

extension View {
    
    public func xQuantize(fraction: CGFloat) -> QuantizeX<Self> {
        QuantizeX(fraction: fraction) { self }
    }
}
