#
# Be sure to run `pod lib lint dkd-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MingKeMing'
  s.version          = '0.4.4'
  s.summary          = 'A Common Account Module For Decentralized User Identity Authentication'
  s.homepage         = 'https://github.com/dimchat'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DIM' => 'john.chen@dim.chat' }
  s.source           = { :git => 'https://github.com/dimchat/mkm-objc.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*', 'Framework/*.h'
  s.public_header_files = 'Classes/*.h', 'Classes/crypto/*.h', 'Classes/data/*.h', 'Classes/entity/*.h', 'Classes/types/*.h', 'Framework/*.h'
end
