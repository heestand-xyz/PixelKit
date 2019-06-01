//
//  Motion.swift
//  MetalPerformanceShadersProxy
//
//  Created by Anton Heestand on 2019-05-28.
//

import CoreMotion
import CoreGraphics

class PixelMotion {
    
    static let main = PixelMotion()
    
    let motionManager: CMMotionManager
    
    var gyroX: CGFloat = 0.0
    var gyroY: CGFloat = 0.0
    var gyroZ: CGFloat = 0.0
    var accelerationX: CGFloat = 0.0
    var accelerationY: CGFloat = 0.0
    var accelerationZ: CGFloat = 0.0
    var magneticFieldX: CGFloat = 0.0
    var magneticFieldY: CGFloat = 0.0
    var magneticFieldZ: CGFloat = 0.0
    var deviceAttitudeX: CGFloat = 0.0
    var deviceAttitudeY: CGFloat = 0.0
    var deviceAttitudeZ: CGFloat = 0.0
    var deviceGravityX: CGFloat = 0.0
    var deviceGravityY: CGFloat = 0.0
    var deviceGravityZ: CGFloat = 0.0
    var deviceHeading: CGFloat = 0.0
    
    init() {
        
        motionManager = CMMotionManager()
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 1.0 / TimeInterval(PixelKit.main.fpsMax)
            motionManager.startGyroUpdates()
            PixelKit.main.listenToFrames {
                if let data = self.motionManager.gyroData {
                    self.gyroX = CGFloat(data.rotationRate.x)
                    self.gyroY = CGFloat(data.rotationRate.y)
                    self.gyroZ = CGFloat(data.rotationRate.z)
                }
            }
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / TimeInterval(PixelKit.main.fpsMax)
            motionManager.startAccelerometerUpdates()
            PixelKit.main.listenToFrames {
                if let data = self.motionManager.accelerometerData {
                    self.accelerationX = CGFloat(data.acceleration.x)
                    self.accelerationY = CGFloat(data.acceleration.y)
                    self.accelerationZ = CGFloat(data.acceleration.z)
                }
            }
        }
        
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 1.0 / TimeInterval(PixelKit.main.fpsMax)
            motionManager.startMagnetometerUpdates()
            PixelKit.main.listenToFrames {
                if let data = self.motionManager.magnetometerData {
                    self.magneticFieldX = CGFloat(data.magneticField.x)
                    self.magneticFieldY = CGFloat(data.magneticField.y)
                    self.magneticFieldZ = CGFloat(data.magneticField.z)
                }
            }
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / TimeInterval(PixelKit.main.fpsMax)
            motionManager.startDeviceMotionUpdates()
            PixelKit.main.listenToFrames {
                if let data = self.motionManager.deviceMotion {
                    self.deviceAttitudeX = CGFloat(data.attitude.quaternion.x)
                    self.deviceAttitudeY = CGFloat(data.attitude.quaternion.y)
                    self.deviceAttitudeZ = CGFloat(data.attitude.quaternion.z)
                    self.deviceGravityX = CGFloat(data.gravity.x)
                    self.deviceGravityY = CGFloat(data.gravity.y)
                    self.deviceGravityZ = CGFloat(data.gravity.z)
                    self.deviceHeading = CGFloat(data.heading)
                }
            }
        }
        
    }
    
}
