//
//  Created by Cappuccino on 2020-07-16.
//

import Foundation
import Metal

extension PIX {
    
    func generateShaderName() -> String {
        typeName
            .replacingOccurrences(of: "pix-", with: "")
            .camelCased
            + "PIX"
    }
    
    enum ShaderError: Error {
        case metalFileNotFound
        case metalDeviceNotFound
        case metalFunctionMakeFail
    }
    
    func loadShaderFunction() throws -> MTLFunction {
        guard let url: URL = Bundle.module.url(forResource: typeName, withExtension: "metal") else {
            throw ShaderError.metalFileNotFound
        }
        guard let device: MTLDevice = pixelKit.render.metalDevice else {
            throw ShaderError.metalDeviceNotFound
        }
        let library: MTLLibrary = try device.makeLibrary(URL: url)
        guard let function: MTLFunction = library.makeFunction(name: shaderName) else {
            throw ShaderError.metalFunctionMakeFail
        }
        return function
    }

}
