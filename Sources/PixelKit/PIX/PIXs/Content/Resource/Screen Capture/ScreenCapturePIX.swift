//
//  ScreenCapturePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-07-26.
//  Open Source - MIT License
//

#if os(macOS) && !targetEnvironment(macCatalyst)

import AVKit
import RenderKit
import Resolution
import CoreMediaIO

final public class ScreenCapturePIX: PIXResource, PIXViewable {
    
    public typealias Model = ScreenCapturePixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { return "contentResourcePIX" }
    
    // MARK: - Private Properties
    
    var helper: ScreenCaptureHelper?
    
    // MARK: - Public Properties
    
    @LiveInt("screenIndex", range: 0...9) public var screenIndex: Int = 0
    
    public override var liveList: [LiveWrap] {
        super.liveList + [_screenIndex]
    }
    
    // MARK: - Life Cycle -
    
    public init(model: Model) {
        super.init(model: model)
        setup()
    }
    
    public required init() {
        let model = Model()
        super.init(model: model)
        setup()
    }
    
    deinit {
        helper?.stop()
    }
    
    public override func destroy() {
        super.destroy()
        helper?.stop()
        helper = nil
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        
        screenIndex = model.screenIndex
        
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        
        model.screenIndex = screenIndex
        
        super.liveUpdateModelDone()
    }
    
    // MARK: Setup
    
    func setup() {
        
        guard NSScreen.screens.indices.contains(screenIndex) else {
            PixelKit.main.logger.log(node: self, .info, .resource, "Can't Setup Screen Captrue at index \(screenIndex)")
            return
        }
        
        PixelKit.main.logger.log(node: self, .info, .resource, "Setup Screen Captrue at index \(screenIndex)")
        
        helper?.stop()
        
        helper = ScreenCaptureHelper(screenIndex: screenIndex, setup: { [weak self] _ in
            guard let self = self else { return }
            PixelKit.main.logger.log(node: self, .info, .resource, "Screen Capture setup.")
        }, captured: { [weak self] pixelBuffer in
            guard let self = self else { return }
            PixelKit.main.logger.log(node: self, .info, .resource, "Screen Capture frame captured.", loop: true)
            let isFirstPixelBuffer: Bool = self.resourcePixelBuffer == nil
            self.resourcePixelBuffer = pixelBuffer
            if isFirstPixelBuffer || Resolution(pixelBuffer: pixelBuffer) != self.finalResolution {
                self.applyResolution { [weak self] in
                    self?.render()
                }
            } else {
                self.render()
            }
        })
        
        _screenIndex.didSetValue = { [weak self] in
            self?.setup()
        }
    }
    
}

#endif
