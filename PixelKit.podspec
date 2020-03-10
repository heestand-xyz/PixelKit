Pod::Spec.new do |spec|

  spec.name         = "PixelKit"
  spec.version      = "1.0.2"

  spec.summary      = "a Live Graphics for iOS & macOS."
  spec.description  = <<-DESC
            					a collection of live graphics tools for realtime editing.
                      DESC

  spec.homepage     = "http://pixelkit.dev"
  
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Hexagons" => "anton@hexagons.se" }
  spec.social_media_url   = "https://twitter.com/anton_hexagons"

  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.13"
  spec.tvos.deployment_target = "11.0"
  
  spec.swift_version = '5.0'

  spec.source       = { :git => "https://github.com/hexagons/pixelkit.git", :branch => "master", :tag => "#{spec.version}" }

  spec.source_files  = "Source", "Source/**/*.swift",
                       "Resources/Models/*"

  # spec.osx.xcconfig = { 'SWIFT_OBJC_BRIDGING_HEADER' => 'Source/Other/Bridging-Header-macOS.h' } 
  # spec.osx.xcconfig = { 'SWIFT_ENABLE_BATCH_MODE' => 'NO' } 

  spec.ios.exclude_files = "Source/PIX/PIXs/Content/Resource/ScreenCapturePIX.swift",
                           "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                           "Source/PIX/PIXs/Output/SyphonOutPIX.swift",
                           "Source/PIX/View/LiveMouseView.swift",
                           "Source/PIX/PIXs/Content/Resource/NDIPIX.swift"

  spec.osx.exclude_files = "Source/PIX/PIXs/Content/Resource/StreamInPIX.swift",
  						             "Source/PIX/PIXs/Output/StreamOutPIX.swift",
                           "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                           "Source/PIX/PIXs/Output/AirPlayPIX.swift",
                           "Source/PIX/PIXs/Output/SyphonOutPIX.swift",
                           "Source/PIX/View/LiveTouchView.swift",
                           "Source/PIX/PIXs/Content/Resource/VectorPIX.swift",
                           "Source/PIX/IO/Peer.swift",
                           "Source/Other/Motion.swift",
                           "Source/PIX/PIXs/Content/Resource/ViewPIX.swift",
                           "Source/PIX/PIXs/Content/Resource/DepthCameraPIX.swift",
                           "Source/PIX/PIXs/Content/Resource/MultiCameraPIX.swift",
                           "Source/PIX/PIXs/Content/Resource/PaintPIX.swift"

  spec.tvos.exclude_files = "Source/PIX/PIXs/Content/Resource/ScreenCapturePIX.swift",
                            "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                            "Source/PIX/PIXs/Output/SyphonOutPIX.swift",
                            "Source/PIX/View/LiveMouseView.swift",
                            "Source/PIX/PIXs/Content/Resource/StreamInPIX.swift",
                            "Source/PIX/PIXs/Output/StreamOutPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/VectorPIX.swift",
                            "Source/PIX/PIXs/Output/AirPlayPIX.swift",
                            "Source/PIX/View/LiveTouchView.swift",
                            "Source/Other/Motion.swift",
                            "Source/PIX/PIXs/Content/Resource/WebPIX.swift",
                            "Source/PIX/PIXs/Output/RecordPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/CameraPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/DepthCameraPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/MultiCameraPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/NDIPIX.swift",
                            "Source/PIX/PIXs/Content/Resource/PaintPIX.swift"

  spec.ios.resources = "Resources/Metal Libs/PixelKitShaders-iOS.metallib",
                       "Resources/Metal Libs/PixelKitShaders-iOS-Simulator.metallib",
                       "Resources/Metal Libs/PixelKitShaders-macCatalyst.metallib"
  spec.osx.resources = "Resources/Metal Libs/PixelKitShaders-macOS.metallib",
                       "Resources/Frameworks/Syphon.framework"
  spec.tvos.resources = "Resources/Metal Libs/PixelKitShaders-tvOS.metallib",
                        "Resources/Metal Libs/PixelKitShaders-tvOS-Simulator.metallib"
  spec.resources = "Source/PIX/PIXs/Content/Generator/Metal/ContentGeneratorMetalPIX.metal.txt",
                   "Source/PIX/PIXs/Effects/Single/Metal/EffectSingleMetalPIX.metal.txt",
                   "Source/PIX/PIXs/Effects/Merger/Metal/EffectMergerMetalPIX.metal.txt",
                   "Source/PIX/PIXs/Effects/Multi/Metal/EffectMultiMetalPIX.metal.txt"
  
  spec.dependency 'LiveValues', '~> 1.1.7'
  spec.dependency 'RenderKit', '~> 0.3.9'

end
