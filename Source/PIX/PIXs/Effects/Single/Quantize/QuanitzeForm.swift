//
//  Created by Anton Heestand on 2021-06-13.
//

import CoreGraphics

struct QuantizeForm: EffectForm {
    
    let fraction: CGFloat
    
    func updateForm(pix: PIXEffect) {
        guard let pix = pix as? QuantizePIX else { return }
        pix.fraction = fraction
    }
}
