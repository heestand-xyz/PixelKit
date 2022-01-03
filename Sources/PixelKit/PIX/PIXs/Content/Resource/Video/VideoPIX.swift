//
//  VideoPIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-08-24.
//  Open Source - MIT License
//

import RenderKit
import Resolution
#if os(iOS) || os(tvOS)
import UIKit
#else
import CoreGraphics
#endif
import AVFoundation
#if canImport(SwiftUI)
import SwiftUI
#endif

final public class VideoPIX: PIXResource, PIXViewable {
    
    public typealias Model = VideoPixelModel
    
    private var model: Model {
        get { resourceModel as! Model }
        set { resourceModel = newValue }
    }
    
    override public var shaderName: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var helper: VideoHelper?
    var loadCallback: ((Resolution) -> ())?
    var seekCallback: (() -> ())?
    var frameCallback: (() -> ())?
    
    public override var bypass: Bool {
        didSet {
            helper?.bypass = bypass
        }
    }
    
    @Published public var isLoading: Bool = false
    @Published public var isLoaded: Bool = false
    
    // MARK: - Public Properties
    
    /// URL to Video File
    public var url: URL? {
        didSet {
            if url != nil {
                helper?.load(from: url!)
            } else {
                helper?.unload()
            }
        }
    }
    
    public var loops: Bool {
        get { model.loops }
        set {
            model.loops = newValue
            helper?.loops = newValue
        }
    }
    
    public var volume: CGFloat {
        get { model.volume }
        set {
            model.volume = newValue
            helper?.volume = Float(newValue)
        }
    }
    
    var _progressFraction: CGFloat = 0
    public var progressFraction: CGFloat { self._progressFraction }
    public var progressSeconds: CGFloat { self._progressFraction * CGFloat(self.duration ?? 0.0) }
    public var progressFrames: Int { Int(self._progressFraction * CGFloat(self.duration ?? 0.0) * CGFloat(self.fps ?? 1)) }
    
    public var duration: Double? {
        guard let duration = self.helper?.player?.currentItem?.duration.seconds else { return nil }
        guard String(duration) != "nan" else { return nil }
        guard duration != 0.0 else { return nil }
        return duration
    }
    public var frameCount: Int? {
        guard let duration = duration else { return nil }
        guard let fps = fps else { return nil }
        return Int(duration * Double(fps))
    }
    
    public var fps: Int? {
        guard let asset = self.helper?.player?.currentItem?.asset else { return nil }
        let tracks = asset.tracks(withMediaType: .video)
        guard let fps = tracks.first?.nominalFrameRate else { return nil }
        return Int(fps)
    }
    var _rate: CGFloat = 1.0
    public var rate: CGFloat { self._rate }
    
    var _playing: Bool = false
    public var playing: Bool { self._playing }
    
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
    
    public convenience init(url: URL) {
        self.init()
        helper?.load(from: url)
        play()
    }
    
    public convenience init(named fullName: String) {
        self.init()
        let parts = fullName.split(separator: ".")
        let name: String = String(parts.first ?? "")
        let ext: String = String(parts.count >= 2 ? parts.last! : "mov")
        if let url: URL = Bundle.main.url(forResource: name, withExtension: ext) {
            helper?.load(from: url)
            play()
        } else {
            pixelKit.logger.log(node: self, .error, .resource, "Video File \"\(fullName)\" Not Found")
        }
    }
    
    // MARK: - Setup
    
    func setup() {
        helper = VideoHelper(loops: loops, volume: Float(volume), loaded: { [weak self] resolution in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .detail, .resource, "Video loaded.")
            self.loadCallback?(resolution)
            self.loadCallback = nil
            self.isLoading = false
            self.isLoaded = true
        }, updated: { [weak self] pixelBuffer, fraction in
            guard let self = self else { return }
            self.pixelKit.logger.log(node: self, .detail, .resource, "Video pixel buffer available.")
            self.resourcePixelBuffer = pixelBuffer
            guard let res = self.derivedResolution else {
                self.pixelKit.logger.log(node: self, .error, .resource, "Video resolution not found.")
                return
            }
            if self.view.resolution == nil || self.view.resolution! != res {
                self.applyResolution { [weak self] in
                    self?.render()
                }
            } else {
                self.render()
            }
            self._progressFraction = fraction
            self.seekCallback?()
            self.seekCallback = nil
            self.frameCallback?()
            self.frameCallback = nil
        })
        self.applyResolution { [weak self] in
            self?.render()
        }
    }
    
    // MARK: - Live Model
    
    override func modelUpdateLive() {
        super.modelUpdateLive()
        super.modelUpdateLiveDone()
    }
    
    override func liveUpdateModel() {
        super.liveUpdateModel()
        super.liveUpdateModelDone()
    }
    
    // MARK: - Load
    
    public func load(fileNamed name: String, withExtension ext: String, done: ((Resolution) -> ())? = nil) {
        guard let url = find(video: name, withExtension: ext) else { return }
        self.url = url
        isLoading = true
        loadCallback = done
    }
    
    public func load(url: URL, done: ((Resolution) -> ())? = nil) {
        self.url = url
        isLoading = true
        loadCallback = done
    }
    
    public func load(data: Data, done: ((Resolution) -> ())? = nil) {
        // CHECK format
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pixelKit_temp_video.mov")
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        self.url = url
        isLoading = true
        loadCallback = done
    }
    
    public func unload() {
        url = nil
        resourcePixelBuffer = nil
        render()
        isLoaded = false
    }
    
    func find(video named: String, withExtension ext: String?) -> URL? {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext) else {
            PixelKit.main.logger.log(.error, .resource, "Video file named \"\(named)\" could not be found.")
            return nil
        }
        return url
    }
    
    public func nextFrame(done: @escaping () -> ()) {
        frameCallback = done
    }
    
    // MARK - Playback
    
    public func play() {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't play. Video not loaded.")
            return
        }
        player.playImmediately(atRate: Float(_rate))
        _playing = true
    }
    
    public func pause() {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't pause. Video not loaded.")
            return
        }
        player.pause()
        _playing = false
    }
    
    public func seekSeconds(to seconds: CGFloat, done: (() -> ())? = nil) {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to time. Video not loaded.")
            return
        }
        guard progressSeconds != seconds else {
            pixelKit.logger.log(node: self, .warning, .resource, "Time already at seek.")
            return
        }
        let time = CMTime(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        guard player.currentTime() != time else {
            pixelKit.logger.log(node: self, .warning, .resource, "Time already at time.")
            return
        }
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        seekCallback = done
    }
    
    public func seekFrame(to frame: Int, done: (() -> ())? = nil) {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to frame. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to frame. Video item not found.")
            return
        }
        let currentFrame = progressFrames
        guard currentFrame != frame else {
            pixelKit.logger.log(node: self, .warning, .resource, "Frame already at seek.")
            return
        }
        guard let frameCount = frameCount else {
            pixelKit.logger.log(node: self, .warning, .resource, "Frame count not found.")
            return
        }
        let fraction = CGFloat(frame) / CGFloat(frameCount - 1)
        let seconds = item.duration.seconds * Double(fraction)
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        guard player.currentTime() != time else {
            pixelKit.logger.log(node: self, .warning, .resource, "Frame already at time.")
            return
        }
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        seekCallback = done
    }
    
    public func seekFraction(to fraction: CGFloat, done: (() -> ())? = nil) {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to fraction. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to fraction. Video item not found.")
            return
        }
        guard progressFraction != fraction else {
            pixelKit.logger.log(node: self, .warning, .resource, "Fraction already at seek.")
            return
        }
        let seconds = item.duration.seconds * Double(fraction)
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        guard player.currentTime() != time else {
            pixelKit.logger.log(node: self, .warning, .resource, "Fraction already at time.")
            return
        }
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        seekCallback = done
    }
    
    public func setRate(to rate: CGFloat) {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to fraction. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't seek to fraction. Video item not found.")
            return
        }
        pixelKit.render.listenToFramesUntil { () -> (Render.ListenState) in
            let ready = player.status == .readyToPlay
            if ready {            
                let currentTime = item.currentTime()
                let masterClock = CMClockGetTime(CMClockGetHostTimeClock());
                player.automaticallyWaitsToMinimizeStalling = false
                player.setRate(Float(rate), time: currentTime, atHostTime: masterClock)
            }
            return ready ? .done : .continue
        }
        _rate = rate
    }

    public func restart() {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't restart. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.playImmediately(atRate: Float(_rate))
        _playing = true
    }
    
    public func reset() {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't reset. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.pause()
        _playing = false
    }
    
    public func listenToDone(_ callback: @escaping () -> ()) {
        helper?.doneCallback = callback
    }
    
    public func listenToFrames(_ callback: @escaping () -> ()) {
        helper?.frameCallback = callback
    }
    
    #if os(iOS) || os(tvOS)
    public func thumbnail(fraction: CGFloat, at size: CGSize, placement: Texture.ImagePlacement = .fill) -> UIImage? {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't make thumbnail. Video not loaded.")
            return nil
        }
        guard let item = player.currentItem else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't make thumbnail. Video item not found.")
            return nil
        }
        // FIXME: item.duration.seconds is NaN
        let seconds = item.duration.seconds * Double(fraction)
        return thumbnail(seconds: seconds, at: size, placement: placement)
    }
    
    public func thumbnail(seconds: Double, at size: CGSize, placement: Texture.ImagePlacement = .fill) -> UIImage? {
        guard let player = helper?.player else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't make thumbnail. Video not loaded.")
            return nil
        }
        guard let asset = player.currentItem?.asset else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't make thumbnail. Asset not found.")
            return nil
        }
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.requestedTimeToleranceBefore = .zero
        imgGenerator.requestedTimeToleranceAfter = .zero
        let time = CMTime(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        guard let cgImage = try? imgGenerator.copyCGImage(at: time, actualTime: nil) else {
            pixelKit.logger.log(node: self, .warning, .resource, "Can't make thumbnail. Image fail.")
            return nil
        }
        let uiImage = UIImage(cgImage: cgImage)
        return Texture.resize(uiImage, to: size, placement: placement)
    }
    #endif
    
    public override func destroy() {
        super.destroy()
        pause()
        helper = nil
    }
    
}
