#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint batch_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'batch_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Batch.com Flutter Plugin'
  s.homepage         = 'https://batch.com'
  s.license          = { :file => '../LICENSE' }
  "authors": [
    {
      "Batch.com": "support@batch.com"
    },
    "Batch.com iOS SDK"
  ],
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Batch', '~> 1.17.0'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.static_framework = true
end
