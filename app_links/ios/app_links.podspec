#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint app_links.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'app_links'
  s.version          = '0.0.2'
  s.summary          = 'iOS Universal Links and Custom URL schemes.'
  s.description      = <<-DESC
  iOS Universal Links and Custom URL schemes.
                       DESC
  s.homepage         = 'https://github.com/llfbandit/app_links'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  # Privacy manifest
  s.resource_bundles = {'app_links_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
