//
//  VideoPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-24.
//  Open Source - MIT License
//
import CoreGraphics//x
import AVFoundation

public class VideoPIX: PIXResource {
    
    override open var shader: String { return "nilPIX" }
    
    // MARK: - Private Properties
    
    var helper: VideoHelper!
    
    // MARK: - Public Properties
    
    public var loops: Bool = true { didSet { helper.player?.loops = loops } }
    public var url: URL? { didSet { if url != nil { helper.load(from: url!) } } }
    public var volume: CGFloat = 1 { didSet { helper.player?.volume = Float(volume) } }
    var _progress: CGFloat = 0
    public var progress: LiveFloat { return LiveFloat({ return self._progress }) }
    var _rate: CGFloat = 1.0
    public var rate: LiveFloat { return LiveFloat({ return self._rate }) }
    var _playing: Bool = false
    public var playing: LiveBool { return LiveBool({ return self._playing }) }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        helper = VideoHelper(loaded: { res in }, updated: { pixelBuffer, fraction in
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
            self._progress = fraction
        })
    }
    
    // MARK: - Load
    
    public func load(fileNamed name: String, withExtension ext: String) {
        guard let url = find(video: name, withExtension: ext) else { return }
        self.url = url
    }
    
    public func load(url: URL) {
        self.url = url
    }
    
    public func load(data: Data) {
        // CHECK format
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pixelKit_temp_video.mov")
        FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        self.url = url
    }
    
    func find(video named: String, withExtension ext: String?) -> URL? {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext) else {
            PixelKit.main.log(.error, .resource, "Video file named \"\(named)\" could not be found.")
            return nil
        }
        return url
    }
    
    // MARK - Playback
    
    public func play() {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't play. Video not loaded.")
            return
        }
        player.playImmediately(atRate: Float(_rate))
        _playing = true
    }
    
    public func pause() {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't pause. Video not loaded.")
            return
        }
        player.pause()
        _playing = false
    }
    
    public func seekSeconds(to seconds: CGFloat) {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't seek to time. Video not loaded.")
            return
        }
        let time = CMTime(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func seekFraction(to fraction: CGFloat) {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't seek to fraction. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixelKit.log(pix: self, .warning, .resource, "Can't seek to fraction. Video item not found.")
            return
        }
        let seconds = item.duration.seconds * Double(fraction)
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func setRate(to rate: CGFloat) {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't seek to fraction. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixelKit.log(pix: self, .warning, .resource, "Can't seek to fraction. Video item not found.")
            return
        }
        pixelKit.listenToFramesUntil { () -> (PixelKit.ListenState) in
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
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't restart. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.playImmediately(atRate: Float(_rate))
        _playing = true
    }
    
    public func reset() {
        guard let player = helper.player else {
            pixelKit.log(pix: self, .warning, .resource, "Can't reset. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.pause()
        _playing = false
    }
    
}

// MARK: - Helper

class VideoHelper: NSObject {
    
    var player: AVPlayer?
    
    var needsOrientation: Bool?
    
    lazy var playerItemVideoOutput: AVPlayerItemVideoOutput = {
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        return AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
    }()
    
    var loaded: Bool = false
    var loadDate: Date?
    
    var setup: (PIX.Res) -> ()
    var update: (CVPixelBuffer, CGFloat) -> ()
    
    var loops: Bool = true

    // MARK: Life Cycle
    
    init(loaded: @escaping (PIX.Res) -> (), updated: @escaping (CVPixelBuffer, CGFloat) -> ()) {
        
        setup = loaded
        update = updated
        
        super.init()
        
        PixelKit.main.listenToFrames(callback: {  
            if self.loaded {
                self.readBuffer()
            }
        })
        
    }
    
    // MARK: Load
    
    func load(from url: URL, needsOrientation: Bool = false) {
        
        self.needsOrientation = needsOrientation
        
        let asset = AVURLAsset(url: url)
        
        let item = AVPlayerItem(asset: asset)
        item.add(playerItemVideoOutput)
        player = AVPlayer(playerItem: item)
        player!.actionAtItemEnd = .none // CHECK fix smooth loop
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player!.addObserver(self, forKeyPath: "currentItem.presentationSize", options: [.new], context: nil)
        
        loaded = true
        loadDate = Date()
        
    }
    
    func load(data: Data) {
        
        let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(PixelKit.main.kBundleId).pix.video.temp.\(UUID().uuidString).mov") // CHECK format
        
        guard FileManager.default.createFile(atPath: tempVideoURL.path, contents: data, attributes: nil) else {
            PixelKit.main.log(.error, .resource, "Video data load: File creation failed.")
            return
        }
        
        load(from: tempVideoURL)
        
    }
    
    // MARK: Read Buffer
    
    func readBuffer() {
        
        guard loadDate != nil else { return }
        
        let currentTime = player!.currentItem!.currentTime()
        let duration = player!.currentItem!.duration.seconds
        let fraction = currentTime.seconds / duration
        
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime) {
            if let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                update(pixelBuffer, CGFloat(fraction))
            }
        }
        
    }
    
    // MARK: Res Observe
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // CHECK wrong observeValue
        if keyPath == "currentItem.presentationSize" {
            guard let size = player?.currentItem?.tracks[0].assetTrack?.naturalSize else {
                PixelKit.main.log(.error, .resource, "Video size not found.")
                return
            } // player?.currentItem?.presentationSize
            let res = PIX.Res(size: size)
//            var orientation: UIInterfaceOrientation? = nil
//            if needs_orientation! {
//                orientation = getOrientation(size: size)
//            }
            setup(res)
        }
    }
    
    // MARK: Orientation
    
//    func getOrientation(size: CGSize) -> UIInterfaceOrientation {
//        let asset_track = player!.currentItem!.asset.tracks[0]
//        let txf = asset_track.preferredTransform;
//        if (size.width == txf.tx && size.height == txf.ty) {
//            return .landscapeRight
//        } else if (txf.tx == 0 && txf.ty == 0) {
//            return .landscapeLeft
//        } else if (txf.tx == 0 && txf.ty == size.width) {
//            return .portraitUpsideDown
//        } else {
//            return .portrait
//        }
//    }
    
    // MARK: Loop
    
    @objc func playerItemDidReachEnd() {
        guard loops else { return }
//        player!.pause()
        player!.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
//        player!.play()
    }
    
}
