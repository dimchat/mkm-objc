#
# Be sure to run `pod lib lint dkd-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'mkm-objc'
  s.version          = '0.4.1'
  s.summary          = 'A Common Account Module For Decentralized User Identity Authentication'
  s.homepage         = 'https://github.com/dimchat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dim' => 'john.chen@infothinker.com' }
  s.source           = { :git => 'https://github.com/dimchat/mkm-objc.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/*.h', 'Classes/crypto/*.h', 'Classes/data/*.h', 'Classes/entity/*.h', 'Classes/types/*.h'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
