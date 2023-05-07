#
# Be sure to run `pod lib lint mkm-objc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                  = 'MingKeMing'
    s.version               = '0.6.4'
    s.summary               = 'Decentralized User Identity Authentication'
    s.description           = <<-DESC
        A Common Account Module For Decentralized User Identity Authentication
                              DESC
    s.homepage              = 'https://github.com/dimchat/mkm-objc'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'Albert Moky' => 'albert.moky@gmail.com' }
    s.source                = { :git => 'https://github.com/dimchat/mkm-objc.git', :tag => s.version.to_s }
    # s.platform            = :ios, "11.0"
    s.ios.deployment_target = '11.0'

    s.source_files          = 'Classes', 'Classes/**/*.{h,m}'
    # s.exclude_files       = 'Classes/Exclude'
    s.public_header_files   = 'Classes/*.h', 'Classes/crypto/*.h', 'Classes/data/*.h', 'Classes/types/*.h'
  
    # s.frameworks          = 'Security'
    # s.requires_arc        = true
end
