#
# Be sure to run `pod lib lint mkm-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'MingKeMing'
    s.version               = '1.0.7'
    s.summary               = 'Decentralized User Identity Authentication'
    s.description           = <<-DESC
        A Common Account Module For Decentralized User Identity Authentication
                              DESC
    s.homepage              = 'https://github.com/dimchat/mkm-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/mkm-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "12.0"
    s.ios.deployment_target = '12.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m}', 'MingKeMing/MingKeMing/*.h'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/**/*.h', 'MingKeMing/MingKeMing/*.h'
  
    # s.frameworks          = 'Security'
    # s.requires_arc        = true
end
