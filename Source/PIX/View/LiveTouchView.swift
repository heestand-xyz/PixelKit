//
//  LiveTouchView.swift
//  Pixels
//
//  Created by Hexagons on 2019-02-22.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class LiveTouchView: UIView {
    
    var touchDown: Bool = false
    
    init() {
        super.init(frame: .zero)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = false
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDown = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
