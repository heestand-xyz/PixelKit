//
//  VideoPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import AVFoundation

public class VideoPIX: PIXResource, PIXofaKind {
    
    var kind: PIX.Kind = .video
    
    override var shader: String { return "nilPIX" }
    
    var helper: VideoHelper!
    
    public var url: URL? { didSet { if url != nil { helper.load(from: url!) } } }
    public var volume: CGFloat = 1 { didSet { helper.player?.volume = Float(volume) } }

    public override init() {
        super.init()
        helper = VideoHelper(loaded: { res in }, updated: { pixelBuffer in
            self.pixelBuffer = pixelBuffer
            if self.view.res == nil || self.view.res! != self.resolution! {
                self.applyRes { self.setNeedsRender() }
            } else {
                self.setNeedsRender()
            }
        })
        if url != nil { helper.load(from: url!) }
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws { self.init() }
    override public func encode(to encoder: Encoder) throws {}
    
    // MARK: Load
    
    public func load(fileNamed name: String, withExtension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            Pixels.main.log(.error, .resource, "Video file named \"\(name)\" could not be found.")
            return
        }
        self.url = url
    }
    
    func find(video named: String, withExtension ext: String?) -> URL? {
        return Bundle.main.url(forResource: named, withExtension: ext)
    }
    
    // MARK - Playback
    
    public func play() {
        guard let p = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't play. Video not loaded.")
            return
        }
        p.play()
    }
    
    public func pause() {
        guard let player = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't pause. Video not loaded.")
            return
        }
        player.pause()
    }
    
    public func seek(toTime time: CMTime) {
        guard let player = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't seek to time. Video not loaded.")
            return
        }
        player.seek(to: time)
    }
    
    public func seek(toFraction fraction: CGFloat) {
        guard let player = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't seek to fraction. Video not loaded.")
            return
        }
        guard let item = player.currentItem else {
            pixels.log(pix: self, .warning, .resource, "Can't seek to fraction. Video item not found.")
            return
        }
        let seconds = item.duration.seconds * Double(fraction)
        let timescale = item.asset.tracks[0].naturalTimeScale
        let time = CMTime(seconds: seconds, preferredTimescale: timescale)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    public func restart() {
        guard let player = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't restart. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.play()
    }
    
    public func reset() {
        guard let player = helper.player else {
            pixels.log(pix: self, .warning, .resource, "Can't reset. Video not loaded.")
            return
        }
        player.seek(to: .zero)
        player.pause()
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
    
    lazy var displayLink: CADisplayLink = {
        let dl = CADisplayLink(target: self, selector: #selector(readBuffer(_:)))
        dl.add(to: .current, forMode: .default)
        dl.isPaused = true
        return dl
    }()
    
    var setup: (PIX.Res) -> ()
    var update: (CVPixelBuffer) -> ()

    // MARK: Life Cycle
    
    init(loaded: @escaping (PIX.Res) -> (), updated: @escaping (CVPixelBuffer) -> ()) {
        
        setup = loaded
        update = updated
        
        super.init()
        
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
        
        displayLink.isPaused = false
        
    player?.play()
        
    }
    
    func load(data: Data) {
        
        let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(Pixels.main.kBundleId).pix.video.temp.\(UUID().uuidString).mov") // CHECK format
        
        guard FileManager.default.createFile(atPath: tempVideoURL.path, contents: data, attributes: nil) else {
            Pixels.main.log(.error, .resource, "Video data load: File creation failed.")
            return
        }
        
        load(from: tempVideoURL)
        
    }
    
    // MARK: Read Buffer
    
    @objc private func readBuffer(_ sender: CADisplayLink) {
        
        var currentTime: CMTime = .invalid
        let nextVSync = sender.timestamp + sender.duration
        currentTime = playerItemVideoOutput.itemTime(forHostTime: nextVSync)
        
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime), let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            update(pixelBuffer)
        }
        
    }
    
    // MARK: Res Observe
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // CHECK wrong observeValue
        if keyPath == "currentItem.presentationSize" {
            guard let size = player?.currentItem?.tracks[0].assetTrack?.naturalSize else {
                Pixels.main.log(.error, .resource, "Video size not found.")
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
        player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(1.0)))
    }
    
}
