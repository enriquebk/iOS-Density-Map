#
# Be sure to run `pod lib lint iOS-Density-Map.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOS-Density-Map'
  s.version          = '0.1.2'
  s.summary          = 'iOS Density Map allows you to efficiently render thousands of points on a map.'

  s.description      = <<-DESC
By using OpenGL ES, iOS Density Map allows you to efficiently render thousands of particles over a map.
                       DESC

  s.homepage         = 'https://github.com/ebermudezcds/iOS-Density-Map'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ebermudezcds' => 'ebermudez.ing@gmail.com' }
  s.source           = { :git => 'https://github.com/ebermudezcds/iOS-Density-Map.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.requires_arc = true
  s.source_files = 'GLDensityMap/**/*.{h,m}'
  s.resource     = 'GLDensityMap/shaders.bundle'

end
