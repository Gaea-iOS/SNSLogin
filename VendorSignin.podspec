#
# Be sure to run `pod lib lint VendorSignin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VendorSignin'
  s.version          = '0.2.0'
  s.summary          = 'Vendor Signin '
  s.description      = 'Vendor Signin'
  s.homepage         = 'https://github.com/lzc1104/VendorSignin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lzc1104' => '527004184@QQ.COM' }
  s.source           = { :git => 'https://github.com/lzc1104/VendorSignin.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'VendorSignin/Classes/**/*'
  s.dependency 'MonkeyKing' ,'~> 1.4.0'

end
