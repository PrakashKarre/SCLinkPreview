#
#  Be sure to run `pod spec lint SCLinkPreview.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "SCLinkPreview"
  spec.version      = "0.0.1"
spec.summary = <<-DESC
  SCLinkPreview is common libraries providing APIs for:
  1. Extracting and fetching Web Link meta for preparing Custom Link previews.
  2. Adding Common Link previews to UIView.
  It includes a cache to store LinkMeta data, enabling default.
DESC

  spec.description  = "A library for link preview functionality in iOS, offering APIs for extracting and fetching web link metadata. It supports custom link previews and provides a default cache for storing LinkMeta data."


  spec.homepage     = "https://github.com/PrakashKarre/SCLinkPreview"



  spec.license      = { :type => "MIT" }


  spec.author             = { "Prakash" => "pra2kash2@gmail.com" }


   spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/PrakashKarre/SCLinkPreview.git", :tag => "0.0.1" }

  spec.source_files  = "Classes", "SCLinkPreview/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"


end

