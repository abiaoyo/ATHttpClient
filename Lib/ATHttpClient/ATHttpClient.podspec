#
# Be sure to run `pod lib lint ATHttpClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ATHttpClient'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ATHttpClient.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/abiaoyo/ATHttpClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'abiaoyo' => '347991555@qq.com' }
  s.source           = { :git => 'https://github.com/abiaoyo/ATHttpClient.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.swift_version = '5.0'

  s.source_files = 'ATHttpClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ATHttpClient' => ['ATHttpClient/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
#  s.default_subspecs = 'ForSwift'
#
  s.dependency 'HandyJSON', '~> 5.0'
  s.dependency 'JSONModel'
  s.dependency 'Alamofire', '~> 5.1'
  s.dependency 'ATMultiBlocks', '~> 0.3'
  s.dependency 'AnyCodable-FlightSchool'
#
#  s.subspec 'ForSwift' do |ss|
#    ss.source_files         = 'ATHttpClient/Classes/ForSwift/*'
#  end
#
#  s.subspec 'ForOC' do |ss|
#    ss.dependency 'ATHttpClient/ForSwift'
#    ss.source_files         = 'ATHttpClient/Classes/ForOC/*'
#  end
  
end
