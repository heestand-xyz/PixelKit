//
//  File.swift
//  
//
//  Created by Anton Heestand on 2022-01-03.
//

import RenderKit
import Resolution
import CoreGraphics
import AVFoundation

class VideoHelper: NSObject {
    
    var player: AVPlayer?
    
    var needsOrientation: Bool?
    
    lazy var playerItemVideoOutput: AVPlayerItemVideoOutput = {
        let attributes = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
        return AVPlayerItemVideoOutput(pixelBufferAttributes: attributes)
    }()
    
    var loaded: Bool = false
    var loadDate: Date?
    
    var setup: (Resolution) -> ()
    var update: (CVPixelBuffer, CGFloat) -> ()
    
    var loops: Bool
    var volume: Float {
        didSet {
            player?.volume = volume
        }
    }
    
    var bypass: Bool = false
    
    var doneCallback: (() -> ())?
    var frameCallback: (() -> ())?

    // MARK: Life Cycle
    
    init(loops: Bool, volume: Float, loaded: @escaping (Resolution) -> (), updated: @escaping (CVPixelBuffer, CGFloat) -> ()) {
        
        setup = loaded
        update = updated
        
        self.loops = loops
        self.volume = volume
        
        super.init()
        
        PixelKit.main.render.listenToFrames(callback: { [weak self] in
            if self?.loaded == true {
                guard !self!.bypass else { return }
                self!.readBuffer()
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
        player!.volume = volume
        player!.actionAtItemEnd = .none // CHECK fix smooth loop
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player!.addObserver(self, forKeyPath: "currentItem.presentationSize", options: [.new], context: nil)
        
        loaded = true
        loadDate = Date()
        
    }
    
    func load(data: Data) {
        
        let tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pixelkit.pix.video.temp.\(UUID().uuidString).mov") // CHECK format
        
        guard FileManager.default.createFile(atPath: tempVideoURL.path, contents: data, attributes: nil) else {
            PixelKit.main.logger.log(.error, .resource, "Video data load: File creation failed.")
            return
        }
        
        load(from: tempVideoURL)
        
    }
    
    func unload() {
        player = nil
        loaded = false
        loadDate = nil
    }
    
    // MARK: Read Buffer
    
    func readBuffer() {
        
        guard loadDate != nil else { return }
        
        let currentTime = player!.currentItem!.currentTime()
        let duration = player!.currentItem!.duration.seconds
        let fraction = currentTime.seconds / duration
        guard String(fraction) != "nan" else { return }
        
        let localRenderTime = CFAbsoluteTimeGetCurrent()
        if playerItemVideoOutput.hasNewPixelBuffer(forItemTime: currentTime) {
            if let pixelBuffer = playerItemVideoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
                let renderTime = CFAbsoluteTimeGetCurrent() - localRenderTime
                let renderTimeMs = Double(Int(round(renderTime * 1_000_000))) / 1_000
                PixelKit.main.logger.log(.debug, .resource, "Video Frame Time: [\(renderTimeMs)ms]")
                update(pixelBuffer, CGFloat(fraction))
                frameCallback?()
            }
        }
        
    }
    
    // MARK: Resolution Observe
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // CHECK wrong observeValue
        // FIXME: Called two times
        if keyPath == "currentItem.presentationSize" {
            guard let tracks = player?.currentItem?.tracks else {
                PixelKit.main.logger.log(.error, .resource, "Video tracks not found.")
                return
            }
            let sizes: [CGSize] = tracks.compactMap { track -> CGSize? in
                track.assetTrack?.naturalSize
            }
            guard let size: CGSize = sizes.filter({ size -> Bool in
                size.width > 0 && size.height > 0
            }).first else {
                PixelKit.main.logger.log(.error, .resource, "Video size not found.")
                return
            } // player?.currentItem?.presentationSize
            let res = Resolution(size: size)
//            var orientation: UIInterfaceOrientation? = nil
//            if needs_orientation! {
//                orientation = getOrientation(size: size)
//            }
            DispatchQueue.main.async { [weak self] in
                self?.setup(res)
            }
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
        doneCallback?()
        guard loops else { return }
//        player!.pause()
        player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
//        player!.play()
    }
    
}
