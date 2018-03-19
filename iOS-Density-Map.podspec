#
# Be sure to run `pod lib lint iOS-Density-Map.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOS-Density-Map'
  s.version          = '0.1.0'
  s.summary          = 'iOS Density Map allows you to efficiently render thousands of points on a map.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
By using OpenGL ES, iOS Density Map allows you to efficiently render thousands of particles over a map.
                       DESC

  s.homepage         = 'https://github.com/ebermudezcds/iOS-Density-Map'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ebermudezcds' => 'ebermudez.ing@gmail.com' }
  s.source           = { :git => 'https://github.com/ebermudezcds/iOS-Density-Map.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GLDensityMap/**/*'
  
  s.resource_bundles = {
    'iOS-Density-Map' => ['GLDensityMap/Shaders/**/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
