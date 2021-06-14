//
//  Created by Anton Heestand on 2021-06-13.
//

import CoreGraphics

struct BlurForm: EffectForm {
    
    var radius: CGFloat
    
    func updateForm(pix: PIXEffect) {
        guard let pix = pix as? BlurPIX else { return }
        pix.radius = radius
    }
}
