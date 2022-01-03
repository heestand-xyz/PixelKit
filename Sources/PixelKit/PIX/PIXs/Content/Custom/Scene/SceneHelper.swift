//
//  SceneHelper.swift
//  PixelKit
//
//  Created by Anton Heestand on 2022-01-03.
//

import RenderKit
import SceneKit

class SceneHelper: NSObject, SCNSceneRendererDelegate {
    
    let renderCallback: () -> ()
    
    init(render: @escaping () -> ()) {
        renderCallback = render
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        PixelKit.main.logger.log(.info, nil, "willRenderScene atTime \(time)")
        renderCallback()
    }
    
}
