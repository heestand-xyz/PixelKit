import CoreGraphics

extension Int {
    static var frameIndex: Int {
        PixelKit.main.render.frame
    }
}

extension CGFloat {
    static var frameIndex: CGFloat {
        CGFloat(Int.frameIndex)
    }
}
