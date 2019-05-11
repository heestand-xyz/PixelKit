#
#  Be sure to run `pod spec lint Pixels.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "PixelKit"
  spec.version      = "0.5.4"
  spec.summary      = "a Live Graphics for iOS & macOS."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
  					a collection of live graphics tools for realtime editing.
                   DESC

  spec.homepage     = "http://pixels.software"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  # spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "Hexagons" => "anton@hexagons.se" }
  # Or just: spec.author    = "Hexagons"
  # spec.authors            = { "Hexagons" => "anton.heestand@gmail.com" }
  spec.social_media_url   = "https://twitter.com/anton_hexagons"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  # spec.platform     = :ios, "11.0"
  # spec.platforms = { :ios => "8.0", :osx => "10.7", 

  #  When using multiple platforms
  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.13"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"
  
  spec.swift_version = '5.0'

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.source       = { :git => "https://github.com/hexagons/pixels.git", :branch => "master", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  spec.source_files  = "Source", "Source/**/*.swift"

  spec.ios.exclude_files = "Source/PIX/PIXs/Content/Resource/ScreenCapturePIX.swift",
                           "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                           "Source/PIX/PIXs/Output/SyphonOutPIX.swift",
  						             "Source/PIX/View/LiveMouseView.swift"

  spec.osx.exclude_files = "Source/PIX/PIXs/Content/Resource/StreamInPIX.swift",
  						             "Source/PIX/PIXs/Output/StreamOutPIX.swift",
                           "Source/PIX/PIXs/Content/Resource/SyphonInPIX.swift",
                           "Source/PIX/PIXs/Output/SyphonOutPIX.swift",
  						             "Source/PIX/PIXs/Output/AirPlayPIX.swift",
                           "Source/PIX/View/LiveTouchView.swift",
                           "Source/PIX/IO/Peer.swift"
  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  spec.ios.resources = "Resources/Metal Libs/PixelKitShaders.metallib"
  spec.osx.resources = "Resources/Metal Libs/PixelKitShaders-macOS.metallib"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "UIKit" #, "AnotherFramework"

  # spec.library   = "PixelsShaders.metallib"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.ios.dependency "MetalPerformanceShadersProxy", "~> 0.3"

end
