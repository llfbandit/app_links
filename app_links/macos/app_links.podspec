#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint app_links_macos.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'app_links'
  s.version          = '6.4.1'
  s.summary          = 'App Links MacOS implementation for app_links package.'
  s.description      = <<-DESC
  App Links MacOS implementation for app_links package.
                       DESC
  s.homepage         = 'https://github.com/llfbandit/app_links'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'app_links/Sources/app_links/**/*.swift'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  # Privacy manifest
  s.resource_bundles = {'app_links_macos_privacy' => ['app_links/Sources/app_links/PrivacyInfo.xcprivacy']}
end
