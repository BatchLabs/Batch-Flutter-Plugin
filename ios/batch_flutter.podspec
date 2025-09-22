#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint batch_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'batch_flutter'
  s.version          = '3.0.0'
  s.summary          = 'Batch.com Flutter Plugin'
  s.homepage         = 'https://batch.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.authors = {
    "Batch.com" => "support@batch.com"
  }
  s.source           = { :path => '.' }
  s.source_files = 'batch_flutter/Sources/batch_flutter/**/*'
  s.dependency 'Flutter'
  s.dependency 'Batch', '~> 3.1.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.ios.deployment_target  = '15.0'
  s.swift_version = '5.0'

  # Unit Tests
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'batch_flutter/Tests/batch_flutter_test/**/*.{h,m,swift}'
  end
end
