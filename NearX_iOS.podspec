#
# Be sure to run `pod lib lint NearX_iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'NearX_iOS'
    s.version          = '1.0.1'
    s.summary          = 'Geo-fencing library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

   s.description  = 'Use this library for implementing Geo-fences'

  s.homepage         = 'https://getwalk.in/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kushS21' => 'kushagra@getwalk.in' }
  s.source           = { :git => 'https://github.com/kushS21/NearX_iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'  
  s.platform = :ios, "9.0"

  # s.source_files = 'NearX_iOS/Classes/**/*'
  s.source_files = 'NearX_iOS','Classes/**/*.swift'
  # s.source_files = 'NearX_iOS','**/*.swift'
  s.exclude_files = 'Constrictor/Constrictor/*.plist'
  
  # s.resource_bundles = {
  #   'NearX_iOS' => ['NearX_iOS/Assets/*.png']
  # }
  
  s.swift_versions = '4.2'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'Alamofire'
  s.dependency 'AlamofireObjectMapper'
  s.dependency 'ObjectMapper' ,'3.3'
  s.dependency 'SwiftyJSON', '~> 4.2.0'
  
end
